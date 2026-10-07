import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

import '../../core/time/hydra_time.dart';
import '../models/entities.dart';
import '../models/enums.dart';

/// Version stamped on every decision and persisted reminder event so that
/// HRE_V2 can ship without reinterpreting old data.
const String kHreV1 = 'HRE_V1';

/// Structured, machine-readable reasons behind a scheduling decision.
/// User-facing explanations are generated from these (never invented).
enum ReasonCode {
  paceGap,
  recentIdlePeriod,
  scheduledCheck,
  recovery,
  userPreference,
  routinePattern,
  quietHoursExit,
  workoutEnded,
  fatigue,
  snoozed,
  paused,
  dayClosing,
  goalReached,
  firstOfDay,
}

enum Adjustment { none, earlier, later, deferredToTomorrow }

/// Key of the single sentence that explains the decision to the user.
enum ExplanationKey {
  firstOfDay,
  onTrackScheduled,
  aheadStayQuiet,
  slightlyBehindEarlier,
  significantlyBehindSpread,
  snoozedUntil,
  quietHoursExit,
  workoutEnded,
  fatigueQuiet,
  fatigueSlowed,
  dayClosingTomorrow,
  goalReachedTomorrow,
  pausedUntilLog,
  pausedUntilTime,
  remindersOff,
}

/// Which notification sentence family to use (resolved to localized text).
enum CopyKey {
  firstOfDay,
  gentle,
  neutral,
  encouraging,
  progress,
  onPace,
  behind,
  recovery,
  closing,
  afterWorkout,
}

/// Per-mode reminder behaviour. Deliberately small and explicit.
class ReminderPolicy {
  const ReminderPolicy({
    required this.mode,
    required this.baseIntervalMin,
    required this.minGapMin,
    required this.firstOffsetMin,
    required this.maxUnanswered,
  });

  factory ReminderPolicy.forMode(ReminderMode mode) => switch (mode) {
        ReminderMode.gentle => const ReminderPolicy(
            mode: ReminderMode.gentle,
            baseIntervalMin: 150,
            minGapMin: 90,
            firstOffsetMin: 90,
            maxUnanswered: 2,
          ),
        ReminderMode.balanced => const ReminderPolicy(
            mode: ReminderMode.balanced,
            baseIntervalMin: 105,
            minGapMin: 60,
            firstOffsetMin: 45,
            maxUnanswered: 3,
          ),
        ReminderMode.focus => const ReminderPolicy(
            mode: ReminderMode.focus,
            baseIntervalMin: 75,
            minGapMin: 40,
            firstOffsetMin: 30,
            maxUnanswered: 4,
          ),
      };

  final ReminderMode mode;

  /// Spacing between reminders when exactly on track.
  final int baseIntervalMin;

  /// Hard floor: the engine never reminds more often than this.
  final int minGapMin;

  /// First reminder of a day: minutes after wake.
  final int firstOffsetMin;

  /// Consecutive reminders with no response before HYDRA goes quiet.
  final int maxUnanswered;
}

enum FatigueLevel { low, moderate, high }

class FatigueState {
  const FatigueState({
    required this.index,
    required this.level,
    required this.sampleSize,
    required this.sufficient,
    this.suggestFewerReminders = false,
  });

  static const FatigueState none = FatigueState(
    index: 0,
    level: FatigueLevel.low,
    sampleSize: 0,
    sufficient: false,
  );

  /// 0 (engaged) … 1 (ignoring everything).
  final double index;
  final FatigueLevel level;
  final int sampleSize;
  final bool sufficient;
  final bool suggestFewerReminders;

  double get intervalMultiplier => switch (level) {
        FatigueLevel.low => 1.0,
        FatigueLevel.moderate => 1.3,
        FatigueLevel.high => 1.7,
      };
}

/// The planned cumulative-hydration curve for one logical day.
///
/// Fraction of target planned by progress `p ∈ [0,1]` through the *plan
/// window* (wake → sleep minus a wind-down buffer) is
/// `f(p) = 1.2p − 0.2p²` — gently front-loaded (f'(0)=1.2, f'(1)=0.8),
/// monotonic, exactly 0 at wake and exactly 1 at plan end. Reminders stop at
/// plan end so people are not nudged to drink right before sleep.
class PlanTrajectory {
  PlanTrajectory({required this.targetMl, required this.window})
      : planEnd = window.sleep.subtract(
          Duration(minutes: _windDownMinutes(window)),
        );

  final int targetMl;
  final DayWindow window;
  final tz.TZDateTime planEnd;

  static int _windDownMinutes(DayWindow w) {
    final fifteenPct = (w.lengthMinutes * 0.15).round();
    return fifteenPct < 60 ? fifteenPct : 60;
  }

  Duration get planLength => planEnd.difference(window.wake);

  /// Progress through the plan window, clamped to [0,1].
  double progressAt(DateTime t) {
    final total = planLength.inSeconds;
    if (total <= 0) return 1;
    final p = t.difference(window.wake).inSeconds / total;
    return p.clamp(0.0, 1.0);
  }

  static double fractionForProgress(double p) =>
      (1.2 * p - 0.2 * p * p).clamp(0.0, 1.0);

  /// Inverse of [fractionForProgress].
  static double progressForFraction(double f) {
    final c = f.clamp(0.0, 1.0);
    // 0.2p² − 1.2p + f = 0  →  p = (1.2 − √(1.44 − 0.8f)) / 0.4
    return (1.2 - math.sqrt(1.44 - 0.8 * c)) / 0.4;
  }

  double expectedMlAt(DateTime t) =>
      targetMl * fractionForProgress(progressAt(t));

  DateTime timeAtFraction(double f) => window.wake.add(
        Duration(
          seconds: (progressForFraction(f) * planLength.inSeconds).round(),
        ),
      );
}

/// A snapshot of "where am I versus my plan" at one instant.
class PaceSnapshot {
  const PaceSnapshot({
    required this.now,
    required this.targetMl,
    required this.consumedMl,
    required this.expectedMl,
    required this.gapMl,
    required this.remainingMl,
    required this.elapsedFraction,
    required this.state,
    required this.goalReached,
    required this.beforeWake,
    required this.estimatedFinish,
    required this.finishBeyondWindow,
    required this.remainingPlanMinutes,
    required this.suggestedPerCheckInMl,
  });

  final DateTime now;
  final int targetMl;
  final int consumedMl;
  final double expectedMl;

  /// expected − actual; positive = behind plan.
  final double gapMl;
  final int remainingMl;

  /// Share of the plan window elapsed (0–1).
  final double elapsedFraction;
  final PaceState state;
  final bool goalReached;
  final bool beforeWake;

  /// When the user would finish if they keep the *same lag* behind the plan
  /// curve. Null when the goal is already reached.
  final DateTime? estimatedFinish;

  /// True when [estimatedFinish] falls after the planned sleep time.
  final bool finishBeyondWindow;
  final int remainingPlanMinutes;

  /// Remaining target spread over the remaining check-ins, capped so the app
  /// never implies a large catch-up. Null when nothing remains or the cap
  /// would be exceeded (day is closing).
  final int? suggestedPerCheckInMl;

  double get percent => targetMl == 0 ? 0 : consumedMl / targetMl;
  double get gapFractionOfTarget => targetMl == 0 ? 0 : gapMl / targetMl;
}

/// A resolved day: window plus spans where reminders must not fire.
class DayContext {
  const DayContext({
    required this.window,
    this.quietSpans = const [],
    this.workoutSpans = const [],
  });

  final DayWindow window;
  final List<TimeSpan> quietSpans;
  final List<TimeSpan> workoutSpans;
}

class SchedulerInput {
  const SchedulerInput({
    required this.now,
    required this.today,
    required this.tomorrow,
    required this.targetMl,
    required this.consumedMl,
    required this.policy,
    this.lastLogAt,
    this.lastReminderAt,
    this.consecutiveUnanswered = 0,
    this.fatigue = FatigueState.none,
    this.snoozeUntil,
    this.pausedUntil,
    this.pausedUntilNextLog = false,
    this.remindersEnabled = true,
    this.tone = NotificationTone.auto,
    this.historyDays = 0,
    this.hotEnvironment = false,
    this.copySeed = 0,
  });

  final DateTime now;
  final DayContext today;
  final DayContext tomorrow;
  final int targetMl;
  final int consumedMl;
  final ReminderPolicy policy;
  final DateTime? lastLogAt;
  final DateTime? lastReminderAt;

  /// Reminders sent since the user last interacted (logged/opened/snoozed).
  final int consecutiveUnanswered;
  final FatigueState fatigue;
  final DateTime? snoozeUntil;
  final DateTime? pausedUntil;
  final bool pausedUntilNextLog;
  final bool remindersEnabled;
  final NotificationTone tone;

  /// Days of history available (drives decision confidence only).
  final int historyDays;

  /// User-declared hot environment: raises reminder *awareness* (slightly
  /// tighter spacing); never changes the target.
  final bool hotEnvironment;

  /// Deterministic seed for copy variant rotation (e.g. day-of-year).
  final int copySeed;

  SchedulerInput copyWith({
    DateTime? now,
    int? consumedMl,
    DateTime? lastLogAt,
    DateTime? lastReminderAt,
    int? consecutiveUnanswered,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) =>
      SchedulerInput(
        now: now ?? this.now,
        today: today,
        tomorrow: tomorrow,
        targetMl: targetMl,
        consumedMl: consumedMl ?? this.consumedMl,
        policy: policy,
        lastLogAt: lastLogAt ?? this.lastLogAt,
        lastReminderAt: lastReminderAt ?? this.lastReminderAt,
        consecutiveUnanswered:
            consecutiveUnanswered ?? this.consecutiveUnanswered,
        fatigue: fatigue,
        snoozeUntil: clearSnooze ? null : (snoozeUntil ?? this.snoozeUntil),
        pausedUntil: pausedUntil,
        pausedUntilNextLog: pausedUntilNextLog,
        remindersEnabled: remindersEnabled,
        tone: tone,
        historyDays: historyDays,
        hotEnvironment: hotEnvironment,
        copySeed: copySeed,
      );
}

class SchedulerDecision {
  const SchedulerDecision({
    required this.nextReminder,
    required this.snapshot,
    required this.reasons,
    required this.adjustment,
    required this.explanation,
    required this.copy,
    required this.copyVariant,
    required this.confidence,
    required this.deferredToTomorrow,
    required this.intervalMinutes,
    this.algorithmVersion = kHreV1,
  });

  /// Null when no reminder should be scheduled (paused, off).
  final DateTime? nextReminder;
  final PaceSnapshot snapshot;
  final List<ReasonCode> reasons;
  final Adjustment adjustment;
  final ExplanationKey explanation;
  final CopyKey copy;
  final int copyVariant;

  /// 0–1: how much history backs this decision. Informational.
  final double confidence;
  final bool deferredToTomorrow;

  /// Interval actually applied (minutes) when computed from an anchor.
  final int? intervalMinutes;
  final String algorithmVersion;

  PaceState get state => snapshot.state;
}
