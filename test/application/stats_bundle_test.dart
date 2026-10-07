import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/application/stats_bundle.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/domain/challenges/challenges.dart';
import 'package:hydra/domain/insights/day_stats.dart';
import 'package:hydra/domain/insights/insights.dart';

import '../domain/analytics_test.dart' show day, series;

void main() {
  const today = LocalDate(2026, 9, 30);

  test('brand-new user: no conclusions, no crashes', () {
    final b = buildStatsBundle(
      today: today,
      completed: const [],
      todayStats: DayStats.empty(today, 2400),
      challengeDefs: ChallengeDefinition.defaults,
    );
    expect(b.sufficiency, DataSufficiency.none);
    expect(b.consistency.sufficient, isFalse);
    expect(b.momentum.sufficient, isFalse);
    expect(b.weekly, isNull);
    expect(b.monthly, isNull);
    expect(b.dailyInsight!.type, InsightType.noData);
    expect(b.independence.sufficient, isFalse);
  });

  test('six weeks of steady use produces every metric', () {
    final completed = series(42, (i, d) => day(d, adherence: 0.9, sent: i < 14 ? 8 : 3), start: today.addDays(-42));
    final b = buildStatsBundle(
      today: today,
      completed: completed,
      todayStats: day(today, adherence: 0.4),
      challengeDefs: ChallengeDefinition.defaults,
      favoriteVesselName: 'Desk bottle',
      favoriteVesselMl: 750,
    );
    expect(b.consistency.score, greaterThan(80));
    expect(b.momentum.sufficient, isTrue);
    expect(b.independence.celebrate, isTrue);
    expect(b.weekly, isNotNull);
    expect(b.monthly!.favoriteVesselName, 'Desk bottle');
    expect(b.streak.current, greaterThan(20));
    expect(b.challenges, isNotEmpty);
  });
}
