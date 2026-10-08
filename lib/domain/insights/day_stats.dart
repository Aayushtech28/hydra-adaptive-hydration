import 'dart:math' as math;

import '../../core/time/local_date.dart';
import '../hre/types.dart';
import '../models/enums.dart';

/// A bare (instant, volume) pair; keeps analytics independent of storage.
class LogPoint {
  const LogPoint(this.at, this.ml);
  final DateTime at;
  final int ml;
}

/// A resolved reminder for analytics.
class ReminderPoint {
  const ReminderPoint(this.at, this.outcome);
  final DateTime at;
  final ReminderOutcome outcome;
}

/// Everything the behavioural engines need to know about one logical day.
///
/// ## Formulas (documented contract — see docs/SCHEDULER.md & ARCHITECTURE.md)
/// * `completion = min(1, consumed / target)` — over-drinking is never rewarded.
/// * `timing` — at hourly checkpoints from wake+1h to plan end, the *behind*
///   share `max(0, expected − actual) / target` is averaged and subtracted
///   from 1. Being ahead is not rewarded beyond 0 penalty.
/// * `adherence = 0.6·completion + 0.4·timing`.
class DayStats {
  const DayStats({
    required this.date,
    required this.targetMl,
    required this.consumedMl,
    required this.logCount,
    required this.completion,
    required this.timing,
    required this.adherence,
    required this.firstLogDelayMin,
    required this.segmentActualMl,
    required this.segmentPlannedMl,
    required this.remindersSent,
    required this.remindersLogged,
    required this.remindersOpened,
    required this.remindersSnoozed,
    required this.remindersIgnored,
    required this.remindedLogs,
    required this.isWeekend,
    this.routineKind,
  });

  /// An eligible day with no data.
  factory DayStats.empty(LocalDate date, int targetMl) => DayStats(
    date: date,
    targetMl: targetMl,
    consumedMl: 0,
    logCount: 0,
    completion: 0,
    timing: 0,
    adherence: 0,
    firstLogDelayMin: null,
    segmentActualMl: const [0, 0, 0],
    segmentPlannedMl: const [0, 0, 0],
    remindersSent: 0,
    remindersLogged: 0,
    remindersOpened: 0,
    remindersSnoozed: 0,
    remindersIgnored: 0,
    remindedLogs: 0,
    isWeekend: date.isWeekend,
  );

  final LocalDate date;
  final int targetMl;
  final int consumedMl;
  final int logCount;
  final double completion;
  final double timing;
  final double adherence;

  /// Minutes between wake and the first log; null on days with no logs.
  final int? firstLogDelayMin;

  /// Morning / afternoon / evening thirds of the plan window.
  final List<int> segmentActualMl;
  final List<int> segmentPlannedMl;
  final int remindersSent;
  final int remindersLogged;
  final int remindersOpened;
  final int remindersSnoozed;
  final int remindersIgnored;

  /// Logs that happened within [DayStatsBuilder.reminderLinkMinutes] of a
  /// reminder.
  final int remindedLogs;
  final bool isWeekend;
  final RoutineKind? routineKind;

  bool get active => logCount > 0;
  int get remindersResolved =>
      remindersLogged + remindersOpened + remindersSnoozed + remindersIgnored;

  /// Share of logs the user initiated without a recent reminder.
  double get selfInitiatedShare =>
      logCount == 0 ? 0 : (logCount - remindedLogs) / logCount;

  /// Fraction of the planned segment achieved (null when nothing planned).
  double? segmentRatio(int i) => segmentPlannedMl[i] == 0
      ? null
      : (segmentActualMl[i] / segmentPlannedMl[i]).clamp(0.0, 1.5);

  Map<String, Object?> toJson() => {
    'd': date.toIso(),
    't': targetMl,
    'c': consumedMl,
    'n': logCount,
    'cp': completion,
    'tm': timing,
    'ad': adherence,
    'fl': firstLogDelayMin,
    'sa': segmentActualMl,
    'sp': segmentPlannedMl,
    'rs': remindersSent,
    'rl': remindersLogged,
    'ro': remindersOpened,
    'rz': remindersSnoozed,
    'ri': remindersIgnored,
    'rg': remindedLogs,
    'rk': routineKind?.name,
  };

  static DayStats? fromJson(Map<String, Object?> j) {
    try {
      final date = LocalDate.parse(j['d']! as String);
      List<int> ints(Object? o) =>
          (o! as List).map((e) => (e as num).toInt()).toList();
      return DayStats(
        date: date,
        targetMl: (j['t']! as num).toInt(),
        consumedMl: (j['c']! as num).toInt(),
        logCount: (j['n']! as num).toInt(),
        completion: (j['cp']! as num).toDouble(),
        timing: (j['tm']! as num).toDouble(),
        adherence: (j['ad']! as num).toDouble(),
        firstLogDelayMin: (j['fl'] as num?)?.toInt(),
        segmentActualMl: ints(j['sa']),
        segmentPlannedMl: ints(j['sp']),
        remindersSent: (j['rs']! as num).toInt(),
        remindersLogged: (j['rl']! as num).toInt(),
        remindersOpened: (j['ro']! as num).toInt(),
        remindersSnoozed: (j['rz']! as num).toInt(),
        remindersIgnored: (j['ri']! as num).toInt(),
        remindedLogs: (j['rg']! as num).toInt(),
        isWeekend: date.isWeekend,
        routineKind: RoutineKind.values
            .where((k) => k.name == j['rk'])
            .cast<RoutineKind?>()
            .firstOrNull,
      );
    } catch (_) {
      return null; // malformed cached data is recomputed, never fatal
    }
  }
}

abstract final class DayStatsBuilder {
  static const int reminderLinkMinutes = 45;

  static DayStats build({
    required LocalDate date,
    required PlanTrajectory trajectory,
    required List<LogPoint> logs,
    List<ReminderPoint> reminders = const [],
    RoutineKind? routineKind,
  }) {
    final target = trajectory.targetMl;
    final sorted = [...logs]..sort((a, b) => a.at.compareTo(b.at));
    final consumed = sorted.fold<int>(0, (s, l) => s + l.ml);
    final completion = target == 0 ? 0.0 : math.min(1.0, consumed / target);

    // Timing: hourly checkpoints wake+1h … plan end (inclusive).
    final checkpoints = <DateTime>[];
    var cp = trajectory.window.wake.add(const Duration(hours: 1));
    while (cp.isBefore(trajectory.planEnd)) {
      checkpoints.add(cp);
      cp = cp.add(const Duration(hours: 1));
    }
    checkpoints.add(trajectory.planEnd);
    var behindSum = 0.0;
    for (final c in checkpoints) {
      final actual = sorted
          .where((l) => !l.at.isAfter(c))
          .fold<int>(0, (s, l) => s + l.ml);
      final exp = trajectory.expectedMlAt(c);
      behindSum += math.max(0, exp - actual) / target;
    }
    final timing = sorted.isEmpty
        ? 0.0
        : (1 - behindSum / checkpoints.length).clamp(0.0, 1.0);
    final adherence = (0.6 * completion + 0.4 * timing).clamp(0.0, 1.0);

    // Segments (thirds of the plan window).
    final planned = <int>[];
    final actual = <int>[0, 0, 0];
    final third = trajectory.planLength.inSeconds / 3;
    final bounds = [
      for (var i = 0; i <= 3; i++)
        trajectory.window.wake.add(Duration(seconds: (third * i).round())),
    ];
    for (var i = 0; i < 3; i++) {
      final a = trajectory.expectedMlAt(bounds[i]);
      final b = trajectory.expectedMlAt(bounds[i + 1]);
      planned.add((b - a).round());
    }
    for (final l in sorted) {
      final idx = l.at.isBefore(bounds[1])
          ? 0
          : l.at.isBefore(bounds[2])
          ? 1
          : 2;
      actual[idx] += l.ml;
    }

    final firstDelay = sorted.isEmpty
        ? null
        : math.max(
            0,
            sorted.first.at.difference(trajectory.window.wake).inMinutes,
          );

    var logged = 0, opened = 0, snoozed = 0, ignored = 0, sent = 0;
    for (final r in reminders) {
      switch (r.outcome) {
        case ReminderOutcome.pending:
        case ReminderOutcome.cancelled:
          continue;
        case ReminderOutcome.logged:
          logged++;
        case ReminderOutcome.opened:
          opened++;
        case ReminderOutcome.snoozed:
          snoozed++;
        case ReminderOutcome.ignored:
          ignored++;
      }
      sent++;
    }
    var remindedLogs = 0;
    for (final l in sorted) {
      final linked = reminders.any((r) {
        if (r.outcome == ReminderOutcome.cancelled ||
            r.outcome == ReminderOutcome.pending) {
          return false;
        }
        final d = l.at.difference(r.at).inMinutes;
        return d >= 0 && d <= reminderLinkMinutes;
      });
      if (linked) remindedLogs++;
    }

    return DayStats(
      date: date,
      targetMl: target,
      consumedMl: consumed,
      logCount: sorted.length,
      completion: completion,
      timing: timing,
      adherence: adherence,
      firstLogDelayMin: firstDelay,
      segmentActualMl: actual,
      segmentPlannedMl: planned,
      remindersSent: sent,
      remindersLogged: logged,
      remindersOpened: opened,
      remindersSnoozed: snoozed,
      remindersIgnored: ignored,
      remindedLogs: remindedLogs,
      isWeekend: date.isWeekend,
      routineKind: routineKind,
    );
  }
}
