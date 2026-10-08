import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/domain/challenges/challenges.dart';
import 'package:hydra/domain/hre/types.dart';
import 'package:hydra/domain/insights/consistency.dart';
import 'package:hydra/domain/insights/day_stats.dart';
import 'package:hydra/domain/insights/insights.dart';
import 'package:hydra/domain/insights/momentum.dart';
import 'package:hydra/domain/insights/recaps.dart';
import 'package:hydra/domain/models/enums.dart';

DayStats day(
  LocalDate d, {
  double adherence = 0.9,
  bool active = true,
  int? firstDelay = 20,
  List<double> seg = const [1.0, 0.9, 0.9],
  int sent = 4,
  int logged = 3,
  int ignored = 1,
  int remindedLogs = 2,
  int logs = 6,
}) => DayStats(
  date: d,
  targetMl: 2400,
  consumedMl: active ? (2400 * adherence).round() : 0,
  logCount: active ? logs : 0,
  completion: adherence,
  timing: adherence,
  adherence: active ? adherence : 0,
  firstLogDelayMin: active ? firstDelay : null,
  segmentActualMl: [for (final s in seg) (500 * s).round()],
  segmentPlannedMl: const [500, 500, 500],
  remindersSent: sent,
  remindersLogged: logged,
  remindersOpened: 0,
  remindersSnoozed: 0,
  remindersIgnored: ignored,
  remindedLogs: remindedLogs,
  isWeekend: d.isWeekend,
);

List<DayStats> series(
  int n,
  DayStats Function(int i, LocalDate d) f, {
  LocalDate start = const LocalDate(2026, 8, 1),
}) => [for (var i = 0; i < n; i++) f(i, start.addDays(i))];

void main() {
  setUpAll(ensureTimeZonesInitialized);

  group('DayStatsBuilder', () {
    final window = DayWindow.build(
      date: const LocalDate(2026, 10, 7),
      location: locationFor('Asia/Kolkata'),
      wakeMinute: 7 * 60,
      sleepMinute: 23 * 60,
    );
    final traj = PlanTrajectory(targetMl: 2400, window: window);

    test('no logs gives zero adherence', () {
      final s = DayStatsBuilder.build(
        date: const LocalDate(2026, 10, 7),
        trajectory: traj,
        logs: const [],
      );
      expect(s.adherence, 0);
      expect(s.active, isFalse);
    });

    test('logging exactly the plan curve scores near 1', () {
      final logs = <LogPoint>[];
      var prev = 0.0;
      for (var h = 1; h <= 15; h++) {
        final t = window.wake.add(Duration(hours: h));
        final e = traj.expectedMlAt(t);
        logs.add(LogPoint(t, (e - prev).round()));
        prev = e;
      }
      logs.add(
        LogPoint(traj.planEnd, 2400 - logs.fold<int>(0, (s, l) => s + l.ml)),
      );
      final s = DayStatsBuilder.build(
        date: const LocalDate(2026, 10, 7),
        trajectory: traj,
        logs: logs,
      );
      expect(s.completion, closeTo(1, 0.001));
      expect(s.timing, greaterThan(0.95));
      expect(s.adherence, greaterThan(0.95));
    });

    test('all water at the end completes but scores lower on timing', () {
      final s = DayStatsBuilder.build(
        date: const LocalDate(2026, 10, 7),
        trajectory: traj,
        logs: [LogPoint(traj.planEnd, 2400)],
      );
      expect(s.completion, 1);
      expect(s.timing, lessThan(0.6));
      expect(s.adherence, lessThan(0.85));
    });

    test('over-drinking is not rewarded', () {
      final s = DayStatsBuilder.build(
        date: const LocalDate(2026, 10, 7),
        trajectory: traj,
        logs: [LogPoint(window.wake.add(const Duration(hours: 1)), 6000)],
      );
      expect(s.completion, 1);
      expect(s.adherence, lessThanOrEqualTo(1));
    });

    test('links logs to reminders within 45 minutes', () {
      final rem = window.wake.add(const Duration(hours: 3));
      final s = DayStatsBuilder.build(
        date: const LocalDate(2026, 10, 7),
        trajectory: traj,
        logs: [
          LogPoint(rem.add(const Duration(minutes: 10)), 250),
          LogPoint(rem.add(const Duration(minutes: 120)), 250),
        ],
        reminders: [ReminderPoint(rem, ReminderOutcome.logged)],
      );
      expect(s.remindedLogs, 1);
      expect(s.selfInitiatedShare, 0.5);
      expect(s.remindersLogged, 1);
    });

    test('json round trip and malformed cache is rejected, not fatal', () {
      final s = day(const LocalDate(2026, 10, 7));
      final back = DayStats.fromJson(s.toJson())!;
      expect(back.adherence, s.adherence);
      expect(DayStats.fromJson({'d': 'garbage'}), isNull);
    });
  });

  group('Consistency & streak', () {
    test('insufficient under 3 eligible days', () {
      final r = ConsistencyCalculator.compute(
        series(2, (i, d) => day(d)),
        const LocalDate(2026, 8, 2),
      );
      expect(r.sufficient, isFalse);
      expect(r.score, isNull);
    });

    test('one missed day dents but never zeroes the score', () {
      final days = series(
        30,
        (i, d) => i == 28 ? day(d, active: false) : day(d, adherence: 0.95),
      );
      final r = ConsistencyCalculator.compute(days, days.last.date);
      expect(r.score, inInclusiveRange(80, 95));
    });

    test('recent days weigh more than old days', () {
      final improving = series(
        30,
        (i, d) => day(d, adherence: i < 15 ? 0.4 : 0.95),
      );
      final declining = series(
        30,
        (i, d) => day(d, adherence: i < 15 ? 0.95 : 0.4),
      );
      expect(
        ConsistencyCalculator.compute(improving, improving.last.date).score!,
        greaterThan(
          ConsistencyCalculator.compute(declining, declining.last.date).score!,
        ),
      );
    });

    test('streak: miss without token resets', () {
      final days = series(
        5,
        (i, d) => i == 3 ? day(d, adherence: 0.2) : day(d),
      );
      expect(StreakCalculator.compute(days, todayInProgress: false).current, 1);
    });

    test('streak: banked recovery token forgives one miss', () {
      final days = series(
        9,
        (i, d) => i == 7 ? day(d, adherence: 0.2) : day(d),
      );
      final r = StreakCalculator.compute(days, todayInProgress: false);
      expect(r.current, 8);
      expect(r.best, 8);
    });

    test('in-progress today does not break the streak', () {
      final days = series(
        6,
        (i, d) => i == 5 ? day(d, adherence: 0.1) : day(d),
      );
      expect(StreakCalculator.compute(days).current, 5);
    });
  });

  group('Momentum', () {
    test('insufficient history gives no score', () {
      expect(
        MomentumCalculator.compute(series(3, (i, d) => day(d))).sufficient,
        isFalse,
      );
    });

    test('strong steady user is strong with reasons', () {
      final days = series(
        28,
        (i, d) => day(d, adherence: 0.92, firstDelay: 20 + (i % 3)),
      );
      final m = MomentumCalculator.compute(days);
      expect(m.sufficient, isTrue);
      expect(m.score!, greaterThanOrEqualTo(65));
      expect(m.reasons, isNotEmpty);
    });

    test('improvement produces a positive trend', () {
      final days = series(28, (i, d) => day(d, adherence: i < 14 ? 0.5 : 0.95));
      final m = MomentumCalculator.compute(days);
      expect(m.trend, isNotNull);
      expect(m.trend!, greaterThan(0));
    });

    test('score stays within 0..100 for extremes', () {
      final lo = MomentumCalculator.compute(
        series(14, (i, d) => day(d, adherence: 0.01, firstDelay: i * 50)),
      );
      expect(lo.score!, inInclusiveRange(0, 100));
    });
  });

  group('Reminder independence', () {
    test('needs 28 days', () {
      expect(
        ReminderIndependenceCalculator.compute(series(20, (i, d) => day(d)))
            .sufficient,
        isFalse,
      );
    });
    test('celebrates fewer reminders with held consistency', () {
      final days = series(
        42,
        (i, d) => day(d, adherence: 0.9, sent: i < 14 ? 8 : 4),
      );
      final r = ReminderIndependenceCalculator.compute(days);
      expect(r.reductionPercent, 50);
      expect(r.celebrate, isTrue);
    });
    test('does not celebrate if consistency collapsed', () {
      final days = series(
        42,
        (i, d) => day(d, adherence: i < 14 ? 0.9 : 0.5, sent: i < 14 ? 8 : 2),
      );
      expect(ReminderIndependenceCalculator.compute(days).celebrate, isFalse);
    });
  });

  group('Habit stage', () {
    test('new user is Remember', () {
      expect(
        HabitCalculator.compute(
          eligibleDays: 2,
          consistency: null,
          response: null,
          stability: null,
          selfInitiated: null,
          independenceCelebrated: false,
        ).stage,
        HabitStage.remember,
      );
    });
    test('advances on behaviour, not volume', () {
      final r = HabitCalculator.compute(
        eligibleDays: 60,
        consistency: 85,
        response: 0.8,
        stability: 0.8,
        selfInitiated: 0.7,
        independenceCelebrated: false,
      );
      expect(r.stage, HabitStage.automatic);
      final mid = HabitCalculator.compute(
        eligibleDays: 20,
        consistency: 70,
        response: 0.6,
        stability: 0.5,
        selfInitiated: 0.2,
        independenceCelebrated: false,
      );
      expect(mid.stage, HabitStage.predict);
    });
  });

  group('Insights (data sufficiency)', () {
    final today = const LocalDate(2026, 8, 31);
    test('no data', () {
      expect(InsightEngine.generate([], today).single.type, InsightType.noData);
    });
    test('first day never claims a pattern', () {
      final r = InsightEngine.generate([day(today)], today);
      expect(r.single.type, InsightType.firstDay);
    });
    test('under a week never claims a pattern', () {
      final days = series(
        5,
        (i, d) => day(d, seg: const [0.2, 0.2, 0.2]),
        start: today.addDays(-4),
      );
      final r = InsightEngine.generate(days, today);
      expect(
        r.every(
          (i) =>
              i.type == InsightType.earlyDays ||
              i.type == InsightType.recoveryAfterMiss,
        ),
        isTrue,
      );
    });
    test('afternoon drift appears only with enough evidence', () {
      final days = series(
        10,
        (i, d) => day(d, seg: const [1.0, 0.4, 0.9]),
        start: today.addDays(-9),
      );
      final r = InsightEngine.generate(days, today);
      expect(r.first.type, InsightType.afternoonDrift);
      expect(r.first.evidenceDays, 10);
    });
    test('morning strength', () {
      final days = series(
        9,
        (i, d) => day(d, seg: const [1.0, 0.8, 0.8]),
        start: today.addDays(-8),
      );
      expect(
        InsightEngine.generate(
          days,
          today,
        ).any((i) => i.type == InsightType.morningStrength),
        isTrue,
      );
    });
    test('weekend variance requires both groups', () {
      final days = series(
        14,
        (i, d) => day(d, adherence: d.isWeekend ? 0.4 : 0.95),
        start: today.addDays(-13),
      );
      expect(
        InsightEngine.generate(
          days,
          today,
        ).any((i) => i.type == InsightType.weekendVariance),
        isTrue,
      );
    });
    test('recovery message after one bad day following good ones', () {
      final days = series(
        10,
        (i, d) => i == 9 ? day(d, adherence: 0.2) : day(d),
        start: today.addDays(-9).addDays(-1),
      );
      final r = InsightEngine.generate(days, today);
      expect(r.any((i) => i.type == InsightType.recoveryAfterMiss), isTrue);
    });
    test('sufficiency ladder', () {
      expect(sufficiencyFor(0), DataSufficiency.none);
      expect(sufficiencyFor(1), DataSufficiency.firstDay);
      expect(sufficiencyFor(6), DataSufficiency.early);
      expect(sufficiencyFor(7), DataSufficiency.initial);
      expect(sufficiencyFor(14), DataSufficiency.established);
      expect(sufficiencyFor(28), DataSufficiency.mature);
    });
  });

  group('Recaps', () {
    test('weekly recap needs ≥3 days and some activity', () {
      expect(RecapBuilder.weekly(series(2, (i, d) => day(d)), []), isNull);
    });
    test('weekly recap computes trend and opportunity', () {
      final week = series(
        7,
        (i, d) => day(d, adherence: 0.9, seg: const [1.0, 0.5, 0.9]),
      );
      final prev = series(
        7,
        (i, d) => day(d, adherence: 0.7),
        start: const LocalDate(2026, 7, 25),
      );
      final r = RecapBuilder.weekly(week, prev)!;
      expect(r.trendPoints, 20);
      expect(r.opportunitySegment, 1);
      expect(r.strongestSegment, 0);
      expect(r.planCompletionDays, 7);
    });
    test('monthly recap requires data', () {
      expect(RecapBuilder.monthly(series(5, (i, d) => day(d))), isNull);
      expect(
        RecapBuilder.monthly(series(20, (i, d) => day(d)))!.activeDays,
        20,
      );
    });
  });

  group('Challenges', () {
    final today = const LocalDate(2026, 8, 7);
    test('morning momentum counts early first drinks', () {
      final days = series(
        7,
        (i, d) => day(d, firstDelay: i < 5 ? 30 : 200),
        start: today.addDays(-6),
      );
      final p = ChallengeEvaluator.evaluate(
        ChallengeDefinition.defaults[0],
        days,
        today,
      );
      expect(p.progress, 5);
      expect(p.completed, isTrue);
    });
    test('weekday rhythm ignores weekends', () {
      final days = series(
        7,
        (i, d) => day(d, adherence: d.isWeekend ? 0.0 : 0.9),
        start: today.addDays(-6),
      );
      final p = ChallengeEvaluator.evaluate(
        ChallengeDefinition.defaults.firstWhere(
          (c) => c.kind == ChallengeKind.weekdayRhythm,
        ),
        days,
        today,
      );
      expect(p.progress, 5);
    });
    test(
      'no challenge rewards volume: over-target days do not beat the cap',
      () {
        final big = DayStats.empty(today, 2400);
        final p = ChallengeEvaluator.evaluate(ChallengeDefinition.defaults[1], [
          big,
        ], today);
        expect(p.progress, 0);
      },
    );
    test('remote definitions are validated', () {
      expect(
        ChallengeDefinition.fromJson({
          'id': 'x',
          'kind': 'weekdayRhythm',
          'windowDays': 7,
          'goal': 9,
        }),
        isNull,
      );
      expect(
        ChallengeDefinition.fromJson({
          'id': 'x',
          'kind': 'nope',
          'windowDays': 7,
          'goal': 3,
        }),
        isNull,
      );
      expect(
        ChallengeDefinition.fromJson({
          'id': 'x',
          'kind': 'weekdayRhythm',
          'windowDays': 7,
          'goal': 3,
        }),
        isNotNull,
      );
    });
  });
}
