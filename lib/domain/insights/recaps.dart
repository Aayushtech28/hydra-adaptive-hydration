import '../../core/time/local_date.dart';
import '../models/enums.dart';
import 'consistency.dart';
import 'day_stats.dart';

class WeeklyRecap {
  const WeeklyRecap({
    required this.consistency,
    required this.strongestDay,
    required this.strongestSegment,
    required this.opportunitySegment,
    required this.planCompletionDays,
    required this.eligibleDays,
    required this.responsePercent,
    required this.trendPoints,
    required this.remindersPerDay,
    required this.remindersTrendPercent,
  });

  final int consistency;
  final LocalDate? strongestDay;

  /// 0 morning · 1 afternoon · 2 evening; null if not enough segment data.
  final int? strongestSegment;
  final int? opportunitySegment;
  final int planCompletionDays;
  final int eligibleDays;
  final int? responsePercent;
  final int? trendPoints;
  final double remindersPerDay;

  /// Negative = fewer reminders than last week.
  final int? remindersTrendPercent;
}

abstract final class RecapBuilder {
  static const int minDays = 3;

  /// [week] = last 7 completed days (oldest → newest); [prev] the 7 before.
  static WeeklyRecap? weekly(List<DayStats> week, List<DayStats> prev) {
    final elig = week;
    if (elig.length < minDays || week.where((d) => d.active).isEmpty)
      return null;
    final cons = _mean(elig.map((d) => d.adherence));
    final best = [...elig.where((d) => d.active)]
      ..sort((a, b) => b.adherence.compareTo(a.adherence));
    final seg = _segmentMeans(week);
    int? strongest, opportunity;
    final valid = {
      for (var i = 0; i < 3; i++)
        if (seg[i] != null) i: seg[i]!,
    };
    if (valid.length >= 2) {
      final entries = valid.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      strongest = entries.first.key;
      opportunity = entries.last.key;
      if (entries.first.value - entries.last.value < 0.05) opportunity = null;
    }
    final resolved = week.fold<int>(0, (s, d) => s + d.remindersResolved);
    final logged = week.fold<int>(0, (s, d) => s + d.remindersLogged);
    final sent = week.fold<int>(0, (s, d) => s + d.remindersSent);
    final activeDays = week.where((d) => d.active).length;
    final rpd = activeDays == 0 ? 0.0 : sent / activeDays;
    int? trend;
    int? remTrend;
    if (prev.length >= minDays && prev.any((d) => d.active)) {
      trend = ((cons - _mean(prev.map((d) => d.adherence))) * 100).round();
      final pSent = prev.fold<int>(0, (s, d) => s + d.remindersSent);
      final pActive = prev.where((d) => d.active).length;
      if (pSent >= 5 && pActive > 0) {
        final pr = pSent / pActive;
        remTrend = ((rpd / pr - 1) * 100).round();
      }
    }
    return WeeklyRecap(
      consistency: (cons * 100).round(),
      strongestDay: best.isEmpty ? null : best.first.date,
      strongestSegment: strongest,
      opportunitySegment: opportunity,
      planCompletionDays: week
          .where((d) => d.adherence >= kCompletedDayAdherence)
          .length,
      eligibleDays: elig.length,
      responsePercent: resolved >= 4 ? (100 * logged / resolved).round() : null,
      trendPoints: trend,
      remindersPerDay: rpd,
      remindersTrendPercent: remTrend,
    );
  }

  static List<double?> _segmentMeans(List<DayStats> days) => [
    for (var i = 0; i < 3; i++)
      () {
        final v = days
            .where((d) => d.active)
            .map((d) => d.segmentRatio(i))
            .whereType<double>()
            .toList();
        return v.length < 3 ? null : v.reduce((a, b) => a + b) / v.length;
      }(),
  ];

  static double _mean(Iterable<double> v) {
    final l = v.toList();
    return l.isEmpty ? 0 : l.reduce((a, b) => a + b) / l.length;
  }

  /// Monthly report from the last up-to-30 completed days.
  static MonthlyRecap? monthly(
    List<DayStats> days, {
    String? favoriteVesselName,
    int? favoriteVesselMl,
  }) {
    final active = days.where((d) => d.active).toList();
    if (days.length < 7 || active.length < 3) return null;
    final byKind = <RoutineKind, List<double>>{};
    for (final d in active) {
      if (d.routineKind != null) {
        byKind.putIfAbsent(d.routineKind!, () => []).add(d.adherence);
      }
    }
    RoutineKind? bestKind;
    var bestScore = -1.0;
    byKind.forEach((k, v) {
      if (v.length >= 3 && _mean(v) > bestScore) {
        bestScore = _mean(v);
        bestKind = k;
      }
    });
    int? improvedSegment;
    if (days.length >= 14) {
      final half = days.length ~/ 2;
      final a = _segmentMeans(days.sublist(0, half));
      final b = _segmentMeans(days.sublist(half));
      var bestDelta = 0.05;
      for (var i = 0; i < 3; i++) {
        if (a[i] != null && b[i] != null && b[i]! - a[i]! > bestDelta) {
          bestDelta = b[i]! - a[i]!;
          improvedSegment = i;
        }
      }
    }
    final resolved = days.fold<int>(0, (s, d) => s + d.remindersResolved);
    final logged = days.fold<int>(0, (s, d) => s + d.remindersLogged);
    return MonthlyRecap(
      activeDays: active.length,
      eligibleDays: days.length,
      consistency: (_mean(days.map((d) => d.adherence)) * 100).round(),
      planCompletionDays: days
          .where((d) => d.adherence >= kCompletedDayAdherence)
          .length,
      bestRoutine: bestKind,
      favoriteVesselName: favoriteVesselName,
      favoriteVesselMl: favoriteVesselMl,
      responsePercent: resolved >= 6 ? (100 * logged / resolved).round() : null,
      mostImprovedSegment: improvedSegment,
    );
  }
}

class MonthlyRecap {
  const MonthlyRecap({
    required this.activeDays,
    required this.eligibleDays,
    required this.consistency,
    required this.planCompletionDays,
    required this.bestRoutine,
    required this.favoriteVesselName,
    required this.favoriteVesselMl,
    required this.responsePercent,
    required this.mostImprovedSegment,
  });
  final int activeDays;
  final int eligibleDays;
  final int consistency;
  final int planCompletionDays;
  final RoutineKind? bestRoutine;
  final String? favoriteVesselName;
  final int? favoriteVesselMl;
  final int? responsePercent;
  final int? mostImprovedSegment;
}
