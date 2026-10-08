import '../../core/time/local_date.dart';
import '../models/entities.dart';
import '../models/enums.dart';

class ReminderSample {
  const ReminderSample(this.date, this.minuteOfDay, this.outcome);
  final LocalDate date;
  final int minuteOfDay;
  final ReminderOutcome outcome;
}

/// "Smart quiet hours": finds hours of the day where the user repeatedly
/// ignores or snoozes reminders and suggests a quiet window. Purely local and
/// purely behavioural — it never infers anything about the person's health.
///
/// An hour qualifies with ≥ [minSent] resolved reminders over ≥ [minDays]
/// distinct days and ≥ 75% ignored-or-snoozed. Adjacent hours merge (max 3h).
abstract final class ResponsePatternAnalyzer {
  static const int minSent = 4;
  static const int minDays = 3;
  static const double badShare = 0.75;

  static List<TimeSpan> suggestQuietSpans(
    List<ReminderSample> samples, {
    List<TimeSpan> existing = const [],
  }) {
    final byHour = <int, List<ReminderSample>>{};
    for (final s in samples) {
      if (s.outcome == ReminderOutcome.pending ||
          s.outcome == ReminderOutcome.cancelled)
        continue;
      byHour.putIfAbsent(s.minuteOfDay ~/ 60, () => []).add(s);
    }
    final bad = <int>[];
    for (final e in byHour.entries) {
      final list = e.value;
      final days = list.map((s) => s.date).toSet().length;
      if (list.length < minSent || days < minDays) continue;
      final b = list
          .where(
            (s) =>
                s.outcome == ReminderOutcome.ignored ||
                s.outcome == ReminderOutcome.snoozed,
          )
          .length;
      if (b / list.length >= badShare) bad.add(e.key);
    }
    bad.sort();
    final spans = <TimeSpan>[];
    var i = 0;
    while (i < bad.length) {
      var j = i;
      while (j + 1 < bad.length &&
          bad[j + 1] == bad[j] + 1 &&
          (j + 1 - i) < 3) {
        j++;
      }
      spans.add(TimeSpan(bad[i] * 60, ((bad[j] + 1) * 60) % 1440));
      i = j + 1;
    }
    bool overlaps(TimeSpan a, TimeSpan b) {
      if (a.isOvernight || b.isOvernight) return false;
      return a.startMinute < b.endMinute && b.startMinute < a.endMinute;
    }

    return spans.where((s) => !existing.any((x) => overlaps(s, x))).toList();
  }
}
