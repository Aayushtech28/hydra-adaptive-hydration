import 'dart:math' as math;

import '../../core/time/local_date.dart';
import '../models/enums.dart';
import 'consistency.dart';
import 'day_stats.dart';

enum MomentumComponent { consistency, stability, response, timing, independence }

enum MomentumTier { building, steady, strong, excellent }

class MomentumReason {
  const MomentumReason(this.component, this.deltaPoints);
  final MomentumComponent component;

  /// Signed contribution (points) — change vs previous window, or the
  /// component's standing contribution when no previous window exists.
  final int deltaPoints;
}

class MomentumResult {
  const MomentumResult({
    required this.score,
    required this.tier,
    required this.trend,
    required this.reasons,
    required this.sufficient,
    required this.components,
  });
  static const MomentumResult insufficient = MomentumResult(
    score: null,
    tier: MomentumTier.building,
    trend: null,
    reasons: [],
    sufficient: false,
    components: {},
  );

  /// 0–100 behavioural score (NOT a medical or health score).
  final int? score;
  final MomentumTier tier;

  /// Points change versus the previous window, when both are measurable.
  final int? trend;
  final List<MomentumReason> reasons;
  final bool sufficient;
  final Map<MomentumComponent, double> components;
}

/// ## Hydration Momentum (behavioural metric)
/// Over a 14-day window of eligible days:
/// consistency 0.40 · reminder response 0.20 · routine stability 0.15 ·
/// plan timing 0.15 · self-initiated logging 0.10. Components without data
/// are dropped and weights renormalised. Needs ≥ [minActiveDays] active days.
abstract final class MomentumCalculator {
  static const int windowDays = 14;
  static const int minActiveDays = 5;
  static const int minResolvedReminders = 5;
  static const Map<MomentumComponent, double> weights = {
    MomentumComponent.consistency: 0.40,
    MomentumComponent.response: 0.20,
    MomentumComponent.stability: 0.15,
    MomentumComponent.timing: 0.15,
    MomentumComponent.independence: 0.10,
  };

  static MomentumTier tierFor(int score) => score >= 85
      ? MomentumTier.excellent
      : score >= 65
          ? MomentumTier.strong
          : score >= 40
              ? MomentumTier.steady
              : MomentumTier.building;

  static Map<MomentumComponent, double>? _components(List<DayStats> win) {
    final active = win.where((d) => d.active).toList();
    if (active.length < minActiveDays) return null;
    final c = <MomentumComponent, double>{};
    c[MomentumComponent.consistency] =
        win.fold<double>(0, (s, d) => s + d.adherence) / win.length;
    c[MomentumComponent.timing] =
        active.fold<double>(0, (s, d) => s + d.timing) / active.length;
    c[MomentumComponent.independence] =
        active.fold<double>(0, (s, d) => s + d.selfInitiatedShare) /
            active.length;
    final delays = active
        .map((d) => d.firstLogDelayMin)
        .whereType<int>()
        .map((e) => e.toDouble())
        .toList();
    if (delays.length >= 4) {
      final mean = delays.reduce((a, b) => a + b) / delays.length;
      final variance =
          delays.fold<double>(0, (s, v) => s + (v - mean) * (v - mean)) /
              delays.length;
      c[MomentumComponent.stability] =
          (1 - math.sqrt(variance) / 90).clamp(0.0, 1.0);
    }
    final resolved = win.fold<int>(0, (s, d) => s + d.remindersResolved);
    if (resolved >= minResolvedReminders) {
      final logged = win.fold<int>(0, (s, d) => s + d.remindersLogged);
      final opened = win.fold<int>(0, (s, d) => s + d.remindersOpened);
      c[MomentumComponent.response] =
          ((logged + 0.5 * opened) / resolved).clamp(0.0, 1.0);
    }
    return c;
  }

  static double _score(Map<MomentumComponent, double> c) {
    var wSum = 0.0, v = 0.0;
    c.forEach((k, val) {
      final w = weights[k]!;
      wSum += w;
      v += w * val;
    });
    return 100 * v / wSum;
  }

  /// [days] must be contiguous eligible days, oldest → newest, ending at the
  /// last completed day.
  static MomentumResult compute(List<DayStats> days) {
    if (days.length < minActiveDays) return MomentumResult.insufficient;
    final cur = days.length > windowDays
        ? days.sublist(days.length - windowDays)
        : days;
    final comps = _components(cur);
    if (comps == null) return MomentumResult.insufficient;
    final score = _score(comps).round().clamp(0, 100);

    int? trend;
    var reasons = <MomentumReason>[];
    final prevEnd = days.length - windowDays;
    Map<MomentumComponent, double>? prevComps;
    if (prevEnd >= minActiveDays) {
      final prev = days.sublist(math.max(0, prevEnd - windowDays), prevEnd);
      prevComps = _components(prev);
    }
    if (prevComps != null) {
      trend = score - _score(prevComps).round();
      for (final k in comps.keys) {
        if (!prevComps.containsKey(k)) continue;
        final wSum = comps.keys.fold<double>(0, (s, e) => s + weights[e]!);
        final delta = (100 * weights[k]! / wSum * (comps[k]! - prevComps[k]!)).round();
        if (delta != 0) reasons.add(MomentumReason(k, delta));
      }
      reasons.sort((a, b) => b.deltaPoints.abs().compareTo(a.deltaPoints.abs()));
    }
    if (reasons.isEmpty) {
      final wSum = comps.keys.fold<double>(0, (s, e) => s + weights[e]!);
      reasons = [
        for (final e in comps.entries)
          MomentumReason(e.key, (100 * weights[e.key]! / wSum * (e.value - 0.5)).round()),
      ]..sort((a, b) => b.deltaPoints.abs().compareTo(a.deltaPoints.abs()));
    }
    return MomentumResult(
      score: score,
      tier: tierFor(score),
      trend: trend,
      reasons: reasons.take(3).toList(),
      sufficient: true,
      components: comps,
    );
  }
}

class ReminderIndependenceResult {
  const ReminderIndependenceResult({
    required this.reductionPercent,
    required this.baselinePerDay,
    required this.recentPerDay,
    required this.sufficient,
    required this.celebrate,
  });
  static const ReminderIndependenceResult none = ReminderIndependenceResult(
    reductionPercent: null,
    baselinePerDay: 0,
    recentPerDay: 0,
    sufficient: false,
    celebrate: false,
  );

  /// Positive = fewer reminders than the baseline period.
  final int? reductionPercent;
  final double baselinePerDay;
  final double recentPerDay;
  final bool sufficient;

  /// True when reminders dropped ≥10% *while consistency held*.
  final bool celebrate;
}

/// ## Reminder Independence
/// Compares reminders per active day in the first 14 eligible days
/// (baseline) with the most recent 14. Needs ≥ 28 eligible days, ≥ 7 active
/// baseline days and ≥ 10 baseline reminders. Celebrated only if consistency
/// did not fall by more than 5 points. The engine never suppresses
/// reminders to improve this number.
abstract final class ReminderIndependenceCalculator {
  static const int minHistory = 28;

  static ReminderIndependenceResult compute(List<DayStats> days) {
    if (days.length < minHistory) return ReminderIndependenceResult.none;
    final base = days.sublist(0, 14);
    final recent = days.sublist(days.length - 14);
    final baseActive = base.where((d) => d.active).length;
    final recActive = recent.where((d) => d.active).length;
    final baseSent = base.fold<int>(0, (s, d) => s + d.remindersSent);
    if (baseActive < 7 || baseSent < 10 || recActive < 5) {
      return ReminderIndependenceResult.none;
    }
    final recSent = recent.fold<int>(0, (s, d) => s + d.remindersSent);
    final bRate = baseSent / baseActive;
    final rRate = recSent / recActive;
    final reduction = ((1 - rRate / bRate) * 100).round();
    final bCons = base.fold<double>(0, (s, d) => s + d.adherence) / base.length;
    final rCons = recent.fold<double>(0, (s, d) => s + d.adherence) / recent.length;
    return ReminderIndependenceResult(
      reductionPercent: reduction,
      baselinePerDay: bRate,
      recentPerDay: rRate,
      sufficient: true,
      celebrate: reduction >= 10 && rCons >= bCons - 0.05,
    );
  }
}

class HabitResult {
  const HabitResult(this.stage, this.nextStage, this.progress);
  final HabitStage stage;
  final HabitStage? nextStage;

  /// 0–1 progress toward the next stage (best-effort, for display).
  final double progress;
}

/// ## Habit maturity (behavioural — never tied to volume)
/// Remember → Respond (≥7 days, response ≥50%) → Predict (≥14 days,
/// consistency ≥65, stable first drink) → Routine (≥28 days, consistency ≥75,
/// stability ≥0.6) → Automatic (≥56 days, consistency ≥80 and ≥60%
/// self-initiated logs or reminder independence celebrated).
abstract final class HabitCalculator {
  static HabitResult compute({
    required int eligibleDays,
    required int? consistency,
    required double? response,
    required double? stability,
    required double? selfInitiated,
    required bool independenceCelebrated,
  }) {
    final c = consistency ?? 0;
    HabitStage stage = HabitStage.remember;
    if (eligibleDays >= 7 && (response ?? 0) >= 0.5) {
      stage = HabitStage.respond;
    }
    if (stage == HabitStage.respond && eligibleDays >= 14 && c >= 65 && (stability ?? 0) >= 0.4) {
      stage = HabitStage.predict;
    }
    if (stage == HabitStage.predict && eligibleDays >= 28 && c >= 75 && (stability ?? 0) >= 0.6) {
      stage = HabitStage.routine;
    }
    if (stage == HabitStage.routine &&
        eligibleDays >= 56 &&
        c >= 80 &&
        ((selfInitiated ?? 0) >= 0.6 || independenceCelebrated)) {
      stage = HabitStage.automatic;
    }
    final next = stage == HabitStage.automatic
        ? null
        : HabitStage.values[stage.index + 1];
    final needDays = switch (next) {
      HabitStage.respond => 7,
      HabitStage.predict => 14,
      HabitStage.routine => 28,
      HabitStage.automatic => 56,
      _ => 1,
    };
    return HabitResult(stage, next, (eligibleDays / needDays).clamp(0.0, 1.0));
  }
}

/// Eligible-day helpers shared by engines.
abstract final class EligibleDays {
  /// Contiguous list from [firstDay] to [lastDay] inclusive, filling gaps
  /// with empty stats; trimmed to [maxDays] most recent.
  static List<DayStats> fill({
    required LocalDate firstDay,
    required LocalDate lastDay,
    required Map<LocalDate, DayStats> byDate,
    required int targetMl,
    int maxDays = 400,
  }) {
    final out = <DayStats>[];
    var d = firstDay;
    while (!d.isAfter(lastDay)) {
      out.add(byDate[d] ?? DayStats.empty(d, targetMl));
      d = d.addDays(1);
    }
    return out.length > maxDays ? out.sublist(out.length - maxDays) : out;
  }
}

/// Convenience for consumers needing the standing consistency alongside.
ConsistencyResult consistencyFor(List<DayStats> days, LocalDate asOf) =>
    ConsistencyCalculator.compute(days, asOf);
