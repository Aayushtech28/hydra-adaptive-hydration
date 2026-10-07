import '../../core/units/volume_unit.dart';
import '../models/enums.dart';
import 'types.dart';

/// Computes [PaceSnapshot]s from a [PlanTrajectory]. Pure and deterministic.
abstract final class PaceCalculator {
  static const double aheadThreshold = -0.05;
  static const double onTrackThreshold = 0.08;
  static const double slightlyBehindThreshold = 0.20;
  static const int closingLeadMinutes = 60;
  static const double closingGapThreshold = 0.10;

  /// Upper bound for any per-check-in suggestion. Beyond this the app does
  /// not suggest catch-up volumes at all ("no panic drinking").
  static const int maxSuggestedMl = 500;

  static PaceSnapshot compute({
    required PlanTrajectory trajectory,
    required int consumedMl,
    required DateTime now,
    required int baseIntervalMin,
  }) {
    final target = trajectory.targetMl;
    final expected = trajectory.expectedMlAt(now);
    final gap = expected - consumedMl;
    final goalReached = consumedMl >= target;
    final beforeWake = now.isBefore(trajectory.window.wake);
    final remainingPlan = trajectory.planEnd.difference(now).inMinutes;

    final PaceState state;
    if (goalReached) {
      state = PaceState.ahead;
    } else if (!now.isBefore(trajectory.planEnd)) {
      state = PaceState.dayClosing;
    } else if (remainingPlan <= closingLeadMinutes &&
        gap > closingGapThreshold * target) {
      state = PaceState.dayClosing;
    } else if (gap <= aheadThreshold * target) {
      state = PaceState.ahead;
    } else if (gap < onTrackThreshold * target) {
      state = PaceState.onTrack;
    } else if (gap < slightlyBehindThreshold * target) {
      state = PaceState.slightlyBehind;
    } else {
      state = PaceState.significantlyBehind;
    }

    DateTime? finish;
    var beyond = false;
    if (!goalReached) {
      final pStar = PlanTrajectory.progressForFraction(consumedMl / target);
      final tStar = trajectory.window.wake.add(
        Duration(seconds: (pStar * trajectory.planLength.inSeconds).round()),
      );
      final effectiveNow = beforeWake ? trajectory.window.wake : now;
      var lag = effectiveNow.difference(tStar);
      final maxLag = trajectory.window.length;
      if (lag > maxLag) lag = maxLag;
      DateTime f = trajectory.planEnd.add(lag);
      if (f.isBefore(now)) f = now;
      finish = f;
      beyond = f.isAfter(trajectory.window.sleep);
    }

    int? suggested;
    final remaining = (target - consumedMl).clamp(0, target);
    if (remaining > 0 && remainingPlan > 0) {
      final slots = (remainingPlan / baseIntervalMin).floor() + 1;
      final per = remaining / slots;
      if (per <= maxSuggestedMl) {
        suggested = roundMlForSuggestion(per).clamp(10, maxSuggestedMl);
      }
    }

    return PaceSnapshot(
      now: now,
      targetMl: target,
      consumedMl: consumedMl,
      expectedMl: expected,
      gapMl: gap,
      remainingMl: remaining,
      elapsedFraction: trajectory.progressAt(now),
      state: state,
      goalReached: goalReached,
      beforeWake: beforeWake,
      estimatedFinish: finish,
      finishBeyondWindow: beyond,
      remainingPlanMinutes: remainingPlan < 0 ? 0 : remainingPlan,
      suggestedPerCheckInMl: suggested,
    );
  }
}
