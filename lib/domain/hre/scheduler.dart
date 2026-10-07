import 'package:timezone/timezone.dart' as tz;

import '../../core/time/hydra_time.dart';
import '../models/entities.dart';
import '../models/enums.dart';
import 'copy_selector.dart';
import 'pace.dart';
import 'types.dart';

/// HRE_V1 — the Hydration Rhythm Engine scheduler.
///
/// Deterministic and explainable: every decision carries structured
/// [ReasonCode]s and an [ExplanationKey] derived from the branch that
/// actually produced the time. The engine adjusts *spacing of reminders*, never
/// the user's target, and never suggests a large catch-up volume.
class HydrationScheduler {
  const HydrationScheduler();

  /// Minimum lead so a reminder is never scheduled in the past.
  static const int minLeadMin = 2;

  /// Lead used when a reminder is overdue (avoid pinging the instant the app
  /// is opened).
  static const int overdueLeadMin = 10;

  static const double _aheadMult = 1.5;
  static const double _slightMult = 0.8;
  static const double _significantMult = 0.65;
  static const double _hotMult = 0.85;
  static const int _maxIntervalMin = 240;

  SchedulerDecision decide(SchedulerInput i) {
    final traj = PlanTrajectory(targetMl: i.targetMl, window: i.today.window);
    final snap = PaceCalculator.compute(
      trajectory: traj,
      consumedMl: i.consumedMl,
      now: i.now,
      baseIntervalMin: i.policy.baseIntervalMin,
    );
    final confidence = (i.historyDays / 14).clamp(0.0, 1.0);

    SchedulerDecision make({
      required DateTime? next,
      required List<ReasonCode> reasons,
      required ExplanationKey explanation,
      Adjustment adjustment = Adjustment.none,
      bool tomorrow = false,
      int? interval,
    }) {
      final pick = CopySelector.select(
        tone: i.tone,
        mode: i.policy.mode,
        snapshot: snap,
        reasons: reasons,
        seed: i.copySeed,
      );
      return SchedulerDecision(
        nextReminder: next,
        snapshot: snap,
        reasons: reasons,
        adjustment: adjustment,
        explanation: explanation,
        copy: pick.$1,
        copyVariant: pick.$2,
        confidence: confidence,
        deferredToTomorrow: tomorrow,
        intervalMinutes: interval,
      );
    }

    if (!i.remindersEnabled) {
      return make(
        next: null,
        reasons: const [ReasonCode.userPreference],
        explanation: ExplanationKey.remindersOff,
      );
    }
    if (i.pausedUntilNextLog) {
      return make(
        next: null,
        reasons: const [ReasonCode.paused],
        explanation: ExplanationKey.pausedUntilLog,
      );
    }

    // Floor imposed by snooze / timed pause.
    var floor = i.now.add(const Duration(minutes: minLeadMin));
    var floorReason = _Binding.none;
    final snoozeActive =
        i.snoozeUntil != null && i.snoozeUntil!.isAfter(i.now);
    if (i.pausedUntil != null && i.pausedUntil!.isAfter(floor)) {
      floor = i.pausedUntil!;
      floorReason = _Binding.pause;
    }

    SchedulerDecision tomorrowFirst(
      List<ReasonCode> reasons,
      ExplanationKey explanation,
    ) {
      final t = _firstOfDay(i.tomorrow, i.policy, floor);
      return make(
        next: t.time,
        reasons: [...reasons, if (t.shifted) ReasonCode.quietHoursExit],
        explanation: explanation,
        adjustment: Adjustment.deferredToTomorrow,
        tomorrow: true,
      );
    }

    if (snap.goalReached) {
      return tomorrowFirst(
        const [ReasonCode.goalReached],
        ExplanationKey.goalReachedTomorrow,
      );
    }
    if (i.consecutiveUnanswered >= i.policy.maxUnanswered) {
      return tomorrowFirst(
        const [ReasonCode.fatigue],
        ExplanationKey.fatigueQuiet,
      );
    }

    final reasons = <ReasonCode>[];
    var explanation = ExplanationKey.onTrackScheduled;
    DateTime candidate;
    int? appliedInterval;
    var adjustment = Adjustment.none;

    final window = i.today.window;
    final firstOfDayTime = window.wake
        .add(Duration(minutes: i.policy.firstOffsetMin));

    if (i.now.isBefore(firstOfDayTime) &&
        i.lastLogAt == null &&
        i.lastReminderAt == null) {
      candidate = firstOfDayTime;
      reasons.add(ReasonCode.firstOfDay);
      explanation = ExplanationKey.firstOfDay;
    } else {
      final hadActivity = i.lastLogAt != null || i.lastReminderAt != null;
      DateTime anchor;
      if (!hadActivity) {
        // Fresh start mid-day (e.g. just installed): first check-in one
        // base interval from now rather than an instant ping.
        anchor = i.now;
        reasons.add(ReasonCode.firstOfDay);
        explanation = ExplanationKey.firstOfDay;
      } else {
        anchor = _latest([
          window.wake,
          if (i.lastLogAt != null) i.lastLogAt!,
          if (i.lastReminderAt != null) i.lastReminderAt!,
        ]);
      }

      final double paceMult = switch (snap.state) {
        PaceState.ahead => _aheadMult,
        PaceState.onTrack => 1.0,
        PaceState.slightlyBehind => _slightMult,
        PaceState.significantlyBehind => _significantMult,
        PaceState.dayClosing => 1.0,
      };
      var raw = i.policy.baseIntervalMin * paceMult;
      if (i.hotEnvironment) raw *= _hotMult;
      final fatigueMult = i.fatigue.intervalMultiplier;
      raw *= fatigueMult;
      // Each unanswered reminder in a row widens spacing (never tightens).
      raw *= 1 + 0.25 * i.consecutiveUnanswered;
      final interval = raw
          .clamp(i.policy.minGapMin.toDouble(), _maxIntervalMin.toDouble())
          .round();
      appliedInterval = interval;
      candidate = anchor.add(Duration(minutes: interval));

      final baseline = i.policy.baseIntervalMin;
      if (interval < baseline) adjustment = Adjustment.earlier;
      if (interval > baseline) adjustment = Adjustment.later;

      switch (snap.state) {
        case PaceState.slightlyBehind:
          reasons.add(ReasonCode.paceGap);
          explanation = ExplanationKey.slightlyBehindEarlier;
        case PaceState.significantlyBehind:
          reasons.add(ReasonCode.paceGap);
          reasons.add(ReasonCode.recovery);
          explanation = ExplanationKey.significantlyBehindSpread;
        case PaceState.ahead:
          reasons.add(ReasonCode.scheduledCheck);
          explanation = ExplanationKey.aheadStayQuiet;
        case PaceState.onTrack:
          reasons.add(ReasonCode.scheduledCheck);
        case PaceState.dayClosing:
          reasons.add(ReasonCode.dayClosing);
      }
      if (i.lastLogAt != null &&
          i.now.difference(i.lastLogAt!).inMinutes >= baseline) {
        reasons.add(ReasonCode.recentIdlePeriod);
      }
      if (fatigueMult > 1.0 && i.fatigue.sufficient) {
        reasons.add(ReasonCode.fatigue);
        if (explanation == ExplanationKey.onTrackScheduled ||
            explanation == ExplanationKey.aheadStayQuiet) {
          explanation = ExplanationKey.fatigueSlowed;
        }
      }
    }

    // A snooze is an explicit "ask me again at T": it overrides the computed
    // spacing (but never the pause floor, quiet spans or the day cut-off).
    if (snoozeActive) {
      candidate = i.snoozeUntil!;
      reasons.add(ReasonCode.snoozed);
      explanation = ExplanationKey.snoozedUntil;
      adjustment = Adjustment.later;
    }

    // Apply floor (pause, minimum lead).
    final overdue = candidate.isBefore(i.now);
    if (overdue) {
      final overdueFloor = i.now.add(const Duration(minutes: overdueLeadMin));
      candidate = overdueFloor.isAfter(floor) ? overdueFloor : floor;
    } else if (candidate.isBefore(floor)) {
      candidate = floor;
      if (floorReason == _Binding.pause) {
        reasons.add(ReasonCode.paused);
        explanation = ExplanationKey.pausedUntilTime;
        adjustment = Adjustment.later;
      }
    }

    // Move out of quiet / workout spans.
    final blocked = _blockedIntervals(i.today);
    final moved = _pushOutOfBlocked(candidate, blocked);
    if (moved.time != candidate) {
      candidate = moved.time;
      adjustment = Adjustment.later;
      if (moved.byWorkout) {
        reasons.add(ReasonCode.workoutEnded);
        reasons.add(ReasonCode.routinePattern);
        explanation = ExplanationKey.workoutEnded;
      } else {
        reasons.add(ReasonCode.quietHoursExit);
        explanation = ExplanationKey.quietHoursExit;
      }
    }

    // Past the reminder cut-off: nothing more today.
    if (candidate.isAfter(traj.planEnd)) {
      final r = <ReasonCode>[
        ReasonCode.dayClosing,
        if (snap.state == PaceState.significantlyBehind ||
            snap.state == PaceState.slightlyBehind ||
            snap.state == PaceState.dayClosing)
          ReasonCode.recovery,
      ];
      return tomorrowFirst(r, ExplanationKey.dayClosingTomorrow);
    }

    return make(
      next: candidate,
      reasons: _dedupe(reasons),
      explanation: explanation,
      adjustment: adjustment,
      interval: appliedInterval,
    );
  }

  /// Projects the reminder chain assuming the user does **not** respond to
  /// any of them. This is what actually gets scheduled with the OS, because
  /// the app cannot run code at fire time. Any user action replaces the chain.
  ///
  /// Always ends with either the unanswered-limit (then tomorrow's first
  /// reminder) or tomorrow's first reminder directly.
  List<SchedulerDecision> planChain(SchedulerInput start, {int maxCount = 6}) {
    final out = <SchedulerDecision>[];
    var input = start;
    for (var n = 0; n < maxCount; n++) {
      final d = decide(input);
      if (d.nextReminder == null) break;
      out.add(d);
      if (d.deferredToTomorrow) break;
      input = input.copyWith(
        now: d.nextReminder,
        lastReminderAt: d.nextReminder,
        consecutiveUnanswered: input.consecutiveUnanswered + 1,
        clearSnooze: true,
      );
    }
    return out;
  }

  // ---- helpers -----------------------------------------------------------

  DateTime _latest(List<DateTime> ts) =>
      ts.reduce((a, b) => a.isAfter(b) ? a : b);

  List<T> _dedupe<T>(List<T> l) => l.toSet().toList();

  ({DateTime time, bool shifted}) _firstOfDay(
    DayContext ctx,
    ReminderPolicy policy,
    DateTime floor,
  ) {
    DateTime t = ctx.window.wake.add(Duration(minutes: policy.firstOffsetMin));
    if (t.isBefore(floor)) t = floor;
    final moved = _pushOutOfBlocked(t, _blockedIntervals(ctx));
    return (time: moved.time, shifted: moved.time != t);
  }

  List<_Blocked> _blockedIntervals(DayContext ctx) {
    final out = <_Blocked>[];
    final loc = ctx.window.location;
    void add(List<TimeSpan> spans, bool workout) {
      for (final s in spans) {
        for (final dayOffset in const [-1, 0]) {
          final d = ctx.window.date.addDays(dayOffset);
          final start = wallTime(loc, d, s.startMinute);
          final end = wallTime(
            loc,
            s.endMinute <= s.startMinute ? d.addDays(1) : d,
            s.endMinute,
          );
          out.add(_Blocked(start, end, workout));
        }
      }
    }

    add(ctx.quietSpans, false);
    add(ctx.workoutSpans, true);
    return out;
  }

  ({DateTime time, bool byWorkout}) _pushOutOfBlocked(
    DateTime t,
    List<_Blocked> blocked,
  ) {
    var cur = t;
    var byWorkout = false;
    for (var guard = 0; guard < 8; guard++) {
      _Blocked? hit;
      for (final b in blocked) {
        if (!cur.isBefore(b.start) && cur.isBefore(b.end)) {
          if (hit == null || b.end.isAfter(hit.end)) hit = b;
        }
      }
      if (hit == null) break;
      cur = hit.end;
      byWorkout = hit.workout;
    }
    return (time: cur, byWorkout: byWorkout);
  }
}

enum _Binding { none, pause }

class _Blocked {
  const _Blocked(this.start, this.end, this.workout);
  final tz.TZDateTime start;
  final tz.TZDateTime end;
  final bool workout;
}
