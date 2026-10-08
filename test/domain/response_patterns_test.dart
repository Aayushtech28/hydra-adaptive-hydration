import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/domain/hre/response_patterns.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';

List<ReminderSample> week(int minute, ReminderOutcome o, {int days = 5}) => [
  for (var d = 0; d < days; d++)
    ReminderSample(const LocalDate(2026, 10, 1).addDays(d), minute, o),
];

void main() {
  test('repeated ignores in a 2–3 PM window become a suggestion', () {
    final s = [
      ...week(14 * 60 + 10, ReminderOutcome.ignored),
      ...week(14 * 60 + 40, ReminderOutcome.snoozed),
      ...week(9 * 60, ReminderOutcome.logged),
    ];
    final r = ResponsePatternAnalyzer.suggestQuietSpans(s);
    expect(r.single, const TimeSpan(14 * 60, 15 * 60));
  });

  test('not enough data → no suggestion', () {
    expect(
      ResponsePatternAnalyzer.suggestQuietSpans(
        week(14 * 60, ReminderOutcome.ignored, days: 2),
      ),
      isEmpty,
    );
  });

  test('responsive hours are never suggested', () {
    expect(
      ResponsePatternAnalyzer.suggestQuietSpans(
        week(10 * 60, ReminderOutcome.logged),
      ),
      isEmpty,
    );
  });

  test('adjacent hours merge and existing spans are not duplicated', () {
    final s = [
      ...week(13 * 60 + 5, ReminderOutcome.ignored),
      ...week(14 * 60 + 5, ReminderOutcome.ignored),
    ];
    expect(
      ResponsePatternAnalyzer.suggestQuietSpans(s).single,
      const TimeSpan(13 * 60, 15 * 60),
    );
    expect(
      ResponsePatternAnalyzer.suggestQuietSpans(
        s,
        existing: [const TimeSpan(13 * 60, 16 * 60)],
      ),
      isEmpty,
    );
  });
}
