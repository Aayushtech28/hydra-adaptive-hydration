import '../core/time/local_date.dart';
import '../domain/challenges/challenges.dart';
import '../domain/insights/consistency.dart';
import '../domain/insights/day_stats.dart';
import '../domain/insights/insights.dart';
import '../domain/insights/momentum.dart';
import '../domain/insights/recaps.dart';

/// Everything the Insights / History / recap screens need, computed once from
/// the completed-day series (and today's live stats) — never per widget
/// rebuild.
class StatsBundle {
  const StatsBundle({
    required this.today,
    required this.days,
    required this.todayStats,
    required this.activeDays,
    required this.sufficiency,
    required this.consistency,
    required this.streak,
    required this.momentum,
    required this.independence,
    required this.habit,
    required this.insights,
    required this.weekly,
    required this.monthly,
    required this.challenges,
  });

  final LocalDate today;

  /// Completed days, oldest → newest (excludes today).
  final List<DayStats> days;
  final DayStats todayStats;
  final int activeDays;
  final DataSufficiency sufficiency;
  final ConsistencyResult consistency;
  final StreakResult streak;
  final MomentumResult momentum;
  final ReminderIndependenceResult independence;
  final HabitResult habit;
  final List<Insight> insights;
  final WeeklyRecap? weekly;
  final MonthlyRecap? monthly;
  final List<ChallengeProgress> challenges;

  Insight? get dailyInsight => insights.isEmpty ? null : insights.first;
}

StatsBundle buildStatsBundle({
  required LocalDate today,
  required List<DayStats> completed,
  required DayStats todayStats,
  required List<ChallengeDefinition> challengeDefs,
  String? favoriteVesselName,
  int? favoriteVesselMl,
}) {
  final activeDays =
      completed.where((d) => d.active).length + (todayStats.active ? 1 : 0);
  final consistency = ConsistencyCalculator.compute(
    completed,
    today.addDays(-1),
  );
  // Today counts toward the streak only once it is already good.
  final withToday = [...completed, todayStats];
  final streak = StreakCalculator.compute(withToday);
  final momentum = MomentumCalculator.compute(completed);
  final independence = ReminderIndependenceCalculator.compute(completed);

  final recent = completed.length > 14
      ? completed.sublist(completed.length - 14)
      : completed;
  final resolved = recent.fold<int>(0, (s, d) => s + d.remindersResolved);
  final logged = recent.fold<int>(0, (s, d) => s + d.remindersLogged);
  final activeRecent = recent.where((d) => d.active).toList();
  final habit = HabitCalculator.compute(
    eligibleDays: completed.length,
    consistency: consistency.score,
    response: resolved >= 5 ? logged / resolved : null,
    stability: momentum.components[MomentumComponent.stability],
    selfInitiated: activeRecent.isEmpty
        ? null
        : activeRecent.fold<double>(0, (s, d) => s + d.selfInitiatedShare) /
              activeRecent.length,
    independenceCelebrated: independence.celebrate,
  );

  final week = completed.length >= 7
      ? completed.sublist(completed.length - 7)
      : completed;
  final prev = completed.length >= 14
      ? completed.sublist(completed.length - 14, completed.length - 7)
      : <DayStats>[];
  final month = completed.length > 30
      ? completed.sublist(completed.length - 30)
      : completed;

  // Challenge evaluation includes today (live) so progress feels immediate.
  final forChallenges = [...completed, todayStats];
  return StatsBundle(
    today: today,
    days: completed,
    todayStats: todayStats,
    activeDays: activeDays,
    sufficiency: sufficiencyFor(activeDays),
    consistency: consistency,
    streak: streak,
    momentum: momentum,
    independence: independence,
    habit: habit,
    insights: InsightEngine.generate(withToday, today),
    weekly: RecapBuilder.weekly(week, prev),
    monthly: RecapBuilder.monthly(
      month,
      favoriteVesselName: favoriteVesselName,
      favoriteVesselMl: favoriteVesselMl,
    ),
    challenges: [
      for (final c in challengeDefs.where((c) => c.enabled))
        ChallengeEvaluator.evaluate(c, forChallenges, today),
    ],
  );
}
