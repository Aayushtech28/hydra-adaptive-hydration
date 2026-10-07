import '../../core/time/local_date.dart';
import 'day_stats.dart';

/// How much history exists; gates which conclusions may be shown.
enum DataSufficiency { none, firstDay, early, initial, established, mature }

DataSufficiency sufficiencyFor(int activeDays) {
  if (activeDays <= 0) return DataSufficiency.none;
  if (activeDays == 1) return DataSufficiency.firstDay;
  if (activeDays < 7) return DataSufficiency.early;
  if (activeDays < 14) return DataSufficiency.initial;
  if (activeDays < 28) return DataSufficiency.established;
  return DataSufficiency.mature;
}

enum InsightType {
  noData,
  firstDay,
  earlyDays,
  morningStrength,
  afternoonDrift,
  eveningDrift,
  earlyFirstDrink,
  weekdayStable,
  weekendVariance,
  reminderResponse,
  routineImprovement,
  recoveryAfterMiss,
}

/// A structured, evidence-backed observation. Natural language is produced
/// from [type] + [params] in the localization layer — never invented.
class Insight {
  const Insight(this.type, this.params, this.evidenceDays, this.priority);
  final InsightType type;
  final Map<String, Object> params;
  final int evidenceDays;
  final int priority;
}

abstract final class InsightEngine {
  static const double strongSegment = 0.90;
  static const double weakSegment = 0.70;

  /// [days] are eligible days, oldest → newest. Returns insights ordered by
  /// priority (highest first). Each insight states the minimum data it needs.
  static List<Insight> generate(List<DayStats> days, LocalDate today) {
    final active = days.where((d) => d.active).toList();
    final suff = sufficiencyFor(active.length);
    final out = <Insight>[];

    switch (suff) {
      case DataSufficiency.none:
        return [const Insight(InsightType.noData, {}, 0, 1)];
      case DataSufficiency.firstDay:
        return [const Insight(InsightType.firstDay, {}, 1, 1)];
      case DataSufficiency.early:
        out.add(Insight(InsightType.earlyDays, {'days': active.length}, active.length, 1));
        // Recovery messaging is allowed at any sufficiency once a miss exists.
        _recovery(days, today, out);
        return out..sort((a, b) => b.priority.compareTo(a.priority));
      default:
        break;
    }

    // --- Segment strengths (≥7 active days) -------------------------------
    final ratios = List<double?>.generate(3, (i) {
      final vals = active.map((d) => d.segmentRatio(i)).whereType<double>().toList();
      if (vals.length < 7) return null;
      return vals.reduce((a, b) => a + b) / vals.length;
    });
    if (ratios[0] != null && ratios[0]! >= strongSegment) {
      out.add(Insight(InsightType.morningStrength,
          {'percent': (ratios[0]! * 100).round().clamp(0, 100)}, active.length, 6));
    }
    if (ratios[1] != null && ratios[1]! < weakSegment) {
      out.add(Insight(InsightType.afternoonDrift,
          {'percent': (ratios[1]! * 100).round()}, active.length, 8));
    }
    if (ratios[2] != null && ratios[2]! < weakSegment) {
      out.add(Insight(InsightType.eveningDrift,
          {'percent': (ratios[2]! * 100).round()}, active.length, 7));
    }

    // --- First drink timing (≥14 active days, ≥3 each side, Δ ≥ 10 pts) ----
    if (active.length >= 14) {
      final early = active.where((d) => (d.firstLogDelayMin ?? 9999) <= 30).toList();
      final late = active.where((d) => (d.firstLogDelayMin ?? 9999) > 30).toList();
      if (early.length >= 3 && late.length >= 3) {
        final e = _mean(early.map((d) => d.adherence));
        final l = _mean(late.map((d) => d.adherence));
        if (e - l >= 0.10) {
          out.add(Insight(InsightType.earlyFirstDrink,
              {'minutes': 30, 'points': ((e - l) * 100).round()}, active.length, 7));
        }
      }
    }

    // --- Weekday vs weekend (≥4 weekdays and ≥2 weekend days active) -------
    final wd = active.where((d) => !d.isWeekend).toList();
    final we = active.where((d) => d.isWeekend).toList();
    if (wd.length >= 4 && we.length >= 2) {
      final a = _mean(wd.map((d) => d.adherence));
      final b = _mean(we.map((d) => d.adherence));
      if ((a - b).abs() >= 0.15) {
        out.add(Insight(InsightType.weekendVariance,
            {'weekday': (a * 100).round(), 'weekend': (b * 100).round()}, active.length, 5));
      } else if (a >= 0.75 && b >= 0.75) {
        out.add(Insight(InsightType.weekdayStable,
            {'weekday': (a * 100).round(), 'weekend': (b * 100).round()}, active.length, 4));
      }
    }

    // --- Reminder response (≥8 resolved reminders) -------------------------
    final resolved = days.fold<int>(0, (s, d) => s + d.remindersResolved);
    if (resolved >= 8) {
      final logged = days.fold<int>(0, (s, d) => s + d.remindersLogged);
      out.add(Insight(InsightType.reminderResponse,
          {'percent': (100 * logged / resolved).round(), 'count': resolved}, active.length, 3));
    }

    // --- Routine improvement (two full weeks) ------------------------------
    if (days.length >= 14) {
      final last = days.sublist(days.length - 7);
      final prev = days.sublist(days.length - 14, days.length - 7);
      if (last.where((d) => d.active).length >= 4 && prev.where((d) => d.active).length >= 4) {
        final delta = (_mean(last.map((d) => d.adherence)) - _mean(prev.map((d) => d.adherence))) * 100;
        if (delta >= 5) {
          out.add(Insight(InsightType.routineImprovement, {'points': delta.round()}, active.length, 6));
        }
      }
    }

    _recovery(days, today, out);
    out.sort((a, b) => b.priority.compareTo(a.priority));
    return out;
  }

  /// "Yesterday didn't erase your progress": yesterday below good while the
  /// two weeks before were good.
  static void _recovery(List<DayStats> days, LocalDate today, List<Insight> out) {
    if (days.length < 4) return;
    final yesterday = days.where((d) => d.date == today.addDays(-1)).firstOrNull;
    if (yesterday == null || yesterday.adherence >= 0.5) return;
    final before = days.where((d) => d.date.isBefore(yesterday.date)).toList();
    if (before.length < 3) return;
    final recent = before.length > 14 ? before.sublist(before.length - 14) : before;
    if (_mean(recent.map((d) => d.adherence)) >= 0.7) {
      out.add(const Insight(InsightType.recoveryAfterMiss, {}, 0, 9));
    }
  }

  static double _mean(Iterable<double> v) {
    final l = v.toList();
    return l.isEmpty ? 0 : l.reduce((a, b) => a + b) / l.length;
  }
}
