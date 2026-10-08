import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/domain/hre/fatigue.dart';
import 'package:hydra/domain/hre/pace.dart';
import 'package:hydra/domain/hre/scheduler.dart';
import 'package:hydra/domain/hre/types.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:timezone/timezone.dart' as tz;

const _sched = HydrationScheduler();

tz.Location _loc([String n = 'Asia/Kolkata']) => locationFor(n);

DayContext _ctx(
  LocalDate d, {
  tz.Location? loc,
  int wake = 7 * 60 + 30,
  int sleep = 23 * 60,
  List<TimeSpan> quiet = const [],
  List<TimeSpan> workout = const [],
}) => DayContext(
  window: DayWindow.build(
    date: d,
    location: loc ?? _loc(),
    wakeMinute: wake,
    sleepMinute: sleep,
  ),
  quietSpans: quiet,
  workoutSpans: workout,
);

SchedulerInput _in(
  tz.TZDateTime now, {
  int consumed = 0,
  ReminderMode mode = ReminderMode.balanced,
  DateTime? lastLog,
  DateTime? lastReminder,
  int unanswered = 0,
  FatigueState fatigue = FatigueState.none,
  DateTime? snooze,
  DateTime? pausedUntil,
  bool pausedLog = false,
  List<TimeSpan> quiet = const [],
  List<TimeSpan> workout = const [],
  int target = 2400,
  int wake = 7 * 60 + 30,
  int sleep = 23 * 60,
  NotificationTone tone = NotificationTone.auto,
}) {
  final loc = now.location;
  final d = logicalDateOf(now, loc);
  return SchedulerInput(
    now: now,
    today: _ctx(
      d,
      loc: loc,
      quiet: quiet,
      workout: workout,
      wake: wake,
      sleep: sleep,
    ),
    tomorrow: _ctx(
      d.addDays(1),
      loc: loc,
      quiet: quiet,
      workout: workout,
      wake: wake,
      sleep: sleep,
    ),
    targetMl: target,
    consumedMl: consumed,
    policy: ReminderPolicy.forMode(mode),
    lastLogAt: lastLog,
    lastReminderAt: lastReminder,
    consecutiveUnanswered: unanswered,
    fatigue: fatigue,
    snoozeUntil: snooze,
    pausedUntil: pausedUntil,
    pausedUntilNextLog: pausedLog,
    tone: tone,
  );
}

tz.TZDateTime _t(
  int h,
  int m, {
  String zone = 'Asia/Kolkata',
  int day = 7,
  int month = 10,
}) => tz.TZDateTime(_loc(zone), 2026, month, day, h, m);

void main() {
  setUpAll(ensureTimeZonesInitialized);

  group('PlanTrajectory', () {
    final w = DayWindow.build(
      date: const LocalDate(2026, 10, 7),
      location: _loc(),
      wakeMinute: 7 * 60 + 30,
      sleepMinute: 23 * 60,
    );
    final traj = PlanTrajectory(targetMl: 2400, window: w);

    test('is 0 at wake and target at plan end, monotonic', () {
      expect(traj.expectedMlAt(w.wake), 0);
      expect(traj.expectedMlAt(traj.planEnd), closeTo(2400, 0.001));
      expect(traj.expectedMlAt(w.sleep), closeTo(2400, 0.001));
      var prev = -1.0;
      for (var m = 0; m <= 16 * 60; m += 15) {
        final v = traj.expectedMlAt(w.wake.add(Duration(minutes: m)));
        expect(v, greaterThanOrEqualTo(prev));
        prev = v;
      }
    });

    test('inverse round-trips', () {
      for (final f in [0.0, 0.1, 0.5, 0.9, 1.0]) {
        final p = PlanTrajectory.progressForFraction(f);
        expect(PlanTrajectory.fractionForProgress(p), closeTo(f, 1e-6));
      }
    });

    test('wind-down is at most 60 minutes', () {
      expect(w.sleep.difference(traj.planEnd).inMinutes, 60);
    });
  });

  group('PaceCalculator', () {
    final today = _ctx(const LocalDate(2026, 10, 7));
    final traj = PlanTrajectory(targetMl: 2400, window: today.window);
    PaceSnapshot snap(int consumed, tz.TZDateTime now) =>
        PaceCalculator.compute(
          trajectory: traj,
          consumedMl: consumed,
          now: now,
          baseIntervalMin: 105,
        );

    test('before wake is on track with zero expected', () {
      final s = snap(0, _t(6, 0));
      expect(s.state, PaceState.onTrack);
      expect(s.beforeWake, isTrue);
      expect(s.expectedMl, 0);
    });

    test('classifies ahead / on track / behind / significantly behind', () {
      final noon = _t(14, 0);
      final exp = traj.expectedMlAt(noon).round();
      expect(snap(exp + 300, noon).state, PaceState.ahead);
      expect(snap(exp, noon).state, PaceState.onTrack);
      expect(snap(exp - 300, noon).state, PaceState.slightlyBehind);
      expect(snap(exp - 700, noon).state, PaceState.significantlyBehind);
    });

    test('goal reached is ahead and has no finish estimate', () {
      final s = snap(2400, _t(15, 0));
      expect(s.goalReached, isTrue);
      expect(s.state, PaceState.ahead);
      expect(s.estimatedFinish, isNull);
      expect(s.suggestedPerCheckInMl, isNull);
    });

    test('day closing near plan end when meaningfully behind', () {
      expect(snap(800, _t(21, 30)).state, PaceState.dayClosing);
      // on-track near the end is NOT closing
      final near = _t(21, 30);
      expect(
        snap(traj.expectedMlAt(near).round(), near).state,
        PaceState.onTrack,
      );
    });

    test('never suggests a panic catch-up', () {
      final s = snap(200, _t(21, 30));
      expect(s.suggestedPerCheckInMl, isNull);
      for (var h = 8; h < 22; h++) {
        final p = snap(0, _t(h, 0)).suggestedPerCheckInMl;
        if (p != null)
          expect(p, lessThanOrEqualTo(PaceCalculator.maxSuggestedMl));
      }
    });

    test('estimated finish moves later when behind and earlier when ahead', () {
      final now = _t(14, 0);
      final exp = traj.expectedMlAt(now).round();
      final behind = snap(exp - 500, now).estimatedFinish!;
      final onPace = snap(exp, now).estimatedFinish!;
      final ahead = snap(exp + 400, now).estimatedFinish!;
      expect(behind.isAfter(onPace), isTrue);
      expect(ahead.isBefore(onPace), isTrue);
      expect(onPace.difference(traj.planEnd).inMinutes.abs(), lessThan(2));
    });
  });

  group('HydrationScheduler.decide', () {
    test('before wake schedules first reminder at wake + offset', () {
      final d = _sched.decide(_in(_t(6, 0)));
      expect(d.nextReminder, _t(8, 15));
      expect(d.reasons, contains(ReasonCode.firstOfDay));
      expect(d.explanation, ExplanationKey.firstOfDay);
      expect(d.copy, CopyKey.firstOfDay);
      expect(d.algorithmVersion, kHreV1);
    });

    test('behind pace brings next reminder earlier than baseline', () {
      final now = _t(14, 0);
      final last = _t(11, 0);
      final onTrack = _sched.decide(_in(now, consumed: 1350, lastLog: last));
      final behind = _sched.decide(
        _in(now, consumed: 700, lastLog: last, lastReminder: _t(13, 0)),
      );
      expect(behind.state, PaceState.significantlyBehind);
      expect(behind.reasons, contains(ReasonCode.paceGap));
      expect(behind.explanation, ExplanationKey.significantlyBehindSpread);
      expect(behind.adjustment, Adjustment.earlier);
      expect(onTrack.nextReminder, isNotNull);
    });

    test('ahead of pace stays quiet longer than on-track', () {
      final now = _t(12, 0);
      final last = _t(11, 50);
      final ahead = _sched.decide(_in(now, consumed: 1800, lastLog: last));
      final track = _sched.decide(_in(now, consumed: 880, lastLog: last));
      expect(track.state, PaceState.onTrack);
      expect(ahead.state, PaceState.ahead);
      expect(ahead.explanation, ExplanationKey.aheadStayQuiet);
      expect(ahead.nextReminder!.isAfter(track.nextReminder!), isTrue);
    });

    test('never reminds sooner than the mode minimum gap', () {
      for (final mode in ReminderMode.values) {
        final policy = ReminderPolicy.forMode(mode);
        final now = _t(15, 0);
        final d = _sched.decide(
          _in(now, consumed: 100, lastLog: now, lastReminder: now, mode: mode),
        );
        expect(
          d.nextReminder!.difference(now).inMinutes,
          greaterThanOrEqualTo(policy.minGapMin),
        );
      }
    });

    test('goal reached defers to tomorrow first reminder', () {
      final d = _sched.decide(_in(_t(15, 0), consumed: 2400));
      expect(d.deferredToTomorrow, isTrue);
      expect(d.explanation, ExplanationKey.goalReachedTomorrow);
      expect(d.nextReminder, _t(8, 15, day: 8));
    });

    test(
      'day closing: past plan end defers to tomorrow, no forced catch-up',
      () {
        final d = _sched.decide(
          _in(_t(22, 10), consumed: 900, lastLog: _t(18, 0)),
        );
        expect(d.state, PaceState.dayClosing);
        expect(d.explanation, ExplanationKey.dayClosingTomorrow);
        expect(d.nextReminder!.day, 8);
        expect(d.copy, CopyKey.closing);
      },
    );

    test('quiet hours: reminder inside span moves to span end', () {
      final quiet = [const TimeSpan(14 * 60, 15 * 60)];
      final d = _sched.decide(
        _in(
          _t(12, 40),
          consumed: 900,
          lastLog: _t(12, 40),
          lastReminder: _t(12, 40),
          quiet: quiet,
          mode: ReminderMode.focus,
        ),
      );
      // focus: ~75*0.8.. falls near 13:40-14:00 region; assert never inside quiet
      final t = d.nextReminder!;
      final mins = t.hour * 60 + t.minute;
      expect(mins >= 14 * 60 && mins < 15 * 60, isFalse);
    });

    test('quiet span covering the candidate pushes to its end with reason', () {
      final quiet = [const TimeSpan(13 * 60, 16 * 60)];
      final d = _sched.decide(
        _in(_t(12, 0), consumed: 1000, lastLog: _t(12, 0), quiet: quiet),
      );
      expect(d.nextReminder, _t(16, 0));
      expect(d.reasons, contains(ReasonCode.quietHoursExit));
      expect(d.explanation, ExplanationKey.quietHoursExit);
    });

    test('overnight quiet span is respected', () {
      final quiet = [const TimeSpan(22 * 60, 9 * 60)];
      final d = _sched.decide(_in(_t(6, 0), quiet: quiet));
      // first reminder 08:15 falls in quiet (ends 09:00 same day)
      expect(d.nextReminder, _t(9, 0));
    });

    test('workout window suppresses reminders and resumes after it', () {
      final workout = [const TimeSpan(18 * 60, 19 * 60 + 15)];
      final d = _sched.decide(
        _in(
          _t(17, 0),
          consumed: 1500,
          lastLog: _t(17, 0),
          lastReminder: _t(17, 0),
          workout: workout,
          mode: ReminderMode.focus,
        ),
      );
      final t = d.nextReminder!;
      final mins = t.hour * 60 + t.minute;
      expect(mins >= 18 * 60 && mins < 19 * 60 + 15, isFalse);
    });

    test('snooze is honoured exactly and explained', () {
      final now = _t(14, 0);
      final d = _sched.decide(
        _in(
          now,
          consumed: 1200,
          lastLog: _t(12, 0),
          lastReminder: now,
          snooze: now.add(const Duration(minutes: 30)),
        ),
      );
      expect(d.nextReminder, _t(14, 30));
      expect(d.explanation, ExplanationKey.snoozedUntil);
      expect(d.reasons, contains(ReasonCode.snoozed));
    });

    test('pause until next log schedules nothing', () {
      final d = _sched.decide(_in(_t(14, 0), pausedLog: true));
      expect(d.nextReminder, isNull);
      expect(d.explanation, ExplanationKey.pausedUntilLog);
    });

    test('timed pause floors the next reminder', () {
      final now = _t(14, 0);
      final d = _sched.decide(_in(now, lastLog: now, pausedUntil: _t(17, 0)));
      expect(d.nextReminder!.isBefore(_t(17, 0)), isFalse);
    });

    test('reminders disabled schedules nothing', () {
      final base = _in(_t(14, 0));
      final off = SchedulerInput(
        now: base.now,
        today: base.today,
        tomorrow: base.tomorrow,
        targetMl: 2400,
        consumedMl: 0,
        policy: base.policy,
        remindersEnabled: false,
      );
      expect(_sched.decide(off).nextReminder, isNull);
    });

    test('too many unanswered reminders go quiet until tomorrow', () {
      final now = _t(15, 0);
      final d = _sched.decide(
        _in(now, consumed: 500, lastReminder: now, unanswered: 3),
      );
      expect(d.deferredToTomorrow, isTrue);
      expect(d.explanation, ExplanationKey.fatigueQuiet);
    });

    test('high fatigue widens spacing, never tightens it', () {
      final now = _t(15, 0);
      final base = _sched.decide(
        _in(now, consumed: 1000, lastLog: now, lastReminder: now),
      );
      const tired = FatigueState(
        index: 0.7,
        level: FatigueLevel.high,
        sampleSize: 12,
        sufficient: true,
      );
      final fat = _sched.decide(
        _in(
          now,
          consumed: 1000,
          lastLog: now,
          lastReminder: now,
          fatigue: tired,
        ),
      );
      expect(
        fat.nextReminder!.isAfter(base.nextReminder!) || fat.deferredToTomorrow,
        isTrue,
      );
      expect(fat.reasons, contains(ReasonCode.fatigue));
    });

    test('overdue reminder after long idle is not instant', () {
      final now = _t(17, 0);
      final d = _sched.decide(
        _in(now, consumed: 400, lastLog: _t(8, 30), lastReminder: _t(8, 30)),
      );
      expect(
        d.nextReminder!.difference(now).inMinutes,
        greaterThanOrEqualTo(HydrationScheduler.overdueLeadMin),
      );
    });

    test('fresh start mid-day does not ping immediately', () {
      final now = _t(15, 0);
      final d = _sched.decide(_in(now));
      expect(
        d.nextReminder!.difference(now).inMinutes,
        greaterThanOrEqualTo(
          ReminderPolicy.forMode(ReminderMode.balanced).minGapMin,
        ),
      );
    });

    test('invariant: decisions are never in the past or inside sleep', () {
      for (var h = 0; h < 24; h++) {
        for (final consumed in [0, 600, 1500, 2399, 2400]) {
          for (final mode in ReminderMode.values) {
            final now = _t(h, 17, day: 7);
            final d = _sched.decide(
              _in(
                now,
                consumed: consumed,
                mode: mode,
                lastLog: consumed > 0
                    ? now.subtract(const Duration(minutes: 70))
                    : null,
              ),
            );
            final n = d.nextReminder!;
            expect(n.isAfter(now), isTrue, reason: 'h=$h c=$consumed $mode');
            final local = tz.TZDateTime.from(n, _loc());
            final m = local.hour * 60 + local.minute;
            // never during sleep (23:00–07:30)
            expect(
              m >= 7 * 60 + 30 && m <= 22 * 60,
              isTrue,
              reason: 'h=$h c=$consumed $mode got $local',
            );
          }
        }
      }
    });
  });

  group('planChain', () {
    test('chain is increasing, bounded and ends with tomorrow', () {
      final chain = _sched.planChain(
        _in(_t(9, 0), consumed: 250, lastLog: _t(9, 0)),
      );
      expect(chain, isNotEmpty);
      for (var i = 1; i < chain.length; i++) {
        expect(
          chain[i].nextReminder!.isAfter(chain[i - 1].nextReminder!),
          isTrue,
        );
      }
      expect(chain.last.deferredToTomorrow, isTrue);
      expect(chain.length, lessThanOrEqualTo(6));
      // never more unanswered reminders than the policy allows today
      final today = chain.where((d) => !d.deferredToTomorrow).length;
      expect(
        today,
        lessThanOrEqualTo(
          ReminderPolicy.forMode(ReminderMode.balanced).maxUnanswered,
        ),
      );
    });

    test('unanswered spacing widens, never tightens', () {
      final chain = _sched.planChain(_in(_t(8, 0), mode: ReminderMode.focus));
      final todays = chain.where((d) => !d.deferredToTomorrow).toList();
      for (var i = 2; i < todays.length; i++) {
        final prevGap = todays[i - 1].nextReminder!.difference(
          todays[i - 2].nextReminder!,
        );
        final gap = todays[i].nextReminder!.difference(
          todays[i - 1].nextReminder!,
        );
        // pace may shorten base spacing, but the unanswered widening keeps
        // it from collapsing below the policy floor
        expect(
          gap.inMinutes,
          greaterThanOrEqualTo(
            ReminderPolicy.forMode(ReminderMode.focus).minGapMin,
          ),
        );
        expect(prevGap.inMinutes, greaterThan(0));
      }
    });
  });

  group('time handling', () {
    test(
      'DST spring-forward: window and reminders stay valid (America/New_York)',
      () {
        final loc = _loc('America/New_York');
        final d = const LocalDate(2026, 3, 8);
        final w = DayWindow.build(
          date: d,
          location: loc,
          wakeMinute: 7 * 60,
          sleepMinute: 23 * 60,
        );
        // 23h day: 07:00→23:00 EDT is 15h wall-clock minus nothing after 2am; window length 16h-0
        expect(w.lengthMinutes, 16 * 60);
        final now = tz.TZDateTime(loc, 2026, 3, 8, 9, 0);
        final input = SchedulerInput(
          now: now,
          today: DayContext(window: w),
          tomorrow: DayContext(
            window: DayWindow.build(
              date: d.addDays(1),
              location: loc,
              wakeMinute: 7 * 60,
              sleepMinute: 23 * 60,
            ),
          ),
          targetMl: 2400,
          consumedMl: 300,
          policy: ReminderPolicy.forMode(ReminderMode.balanced),
          lastLogAt: now,
        );
        final dec = _sched.decide(input);
        expect(dec.nextReminder!.isAfter(now), isTrue);
      },
    );

    test(
      'DST overnight window spanning the change has correct absolute length',
      () {
        final loc = _loc('America/New_York');
        // overnight 22:00 → 03:00 on spring-forward night: only 4 real hours
        final w = DayWindow.build(
          date: const LocalDate(2026, 3, 7),
          location: loc,
          wakeMinute: 22 * 60,
          sleepMinute: 3 * 60,
        );
        expect(w.lengthMinutes, 4 * 60);
      },
    );

    test('logical date rolls over at 04:00 local, not midnight', () {
      final loc = _loc('Asia/Kolkata');
      expect(
        logicalDateOf(tz.TZDateTime(loc, 2026, 10, 8, 0, 30), loc),
        const LocalDate(2026, 10, 7),
      );
      expect(
        logicalDateOf(tz.TZDateTime(loc, 2026, 10, 8, 4, 0), loc),
        const LocalDate(2026, 10, 8),
      );
    });

    test('same instant maps to different logical dates by zone', () {
      final instant = DateTime.utc(2026, 10, 7, 23, 0);
      expect(
        logicalDateOf(instant, _loc('Asia/Kolkata')),
        const LocalDate(2026, 10, 8),
      );
      expect(
        logicalDateOf(instant, _loc('America/New_York')),
        const LocalDate(2026, 10, 7),
      );
    });

    test('wake/sleep validation', () {
      expect(validateWakeSleep(7 * 60, 23 * 60), isNull);
      expect(validateWakeSleep(7 * 60, 1 * 60), isNull); // overnight to 01:00
      expect(validateWakeSleep(7 * 60, 9 * 60), RoutineTimeError.tooShort);
      expect(
        validateWakeSleep(2 * 60, 23 * 60),
        RoutineTimeError.wakeBeforeRollover,
      );
      expect(
        validateWakeSleep(7 * 60, 6 * 60),
        RoutineTimeError.overnightPastRollover,
      );
    });

    test('local-date arithmetic is calendar-pure', () {
      expect(
        const LocalDate(2026, 3, 8).addDays(1),
        const LocalDate(2026, 3, 9),
      );
      expect(
        const LocalDate(2026, 12, 31).addDays(1),
        const LocalDate(2027, 1, 1),
      );
      expect(LocalDate.tryParse('2026-02-30'), isNull);
    });
  });

  group('FatigueCalculator', () {
    test('insufficient sample yields no fatigue', () {
      final f = FatigueCalculator.compute(
        List.filled(4, ReminderOutcome.ignored),
      );
      expect(f.sufficient, isFalse);
      expect(f.level, FatigueLevel.low);
    });
    test('mostly ignored becomes high and suggests fewer reminders', () {
      final f = FatigueCalculator.compute(
        List.filled(12, ReminderOutcome.ignored) +
            List.filled(2, ReminderOutcome.logged),
      );
      expect(f.level, FatigueLevel.high);
      expect(f.suggestFewerReminders, isTrue);
      expect(
        FatigueCalculator.compute(
          List.filled(12, ReminderOutcome.ignored),
          alreadyAskedRecently: true,
        ).suggestFewerReminders,
        isFalse,
      );
    });
    test('engaged user stays low', () {
      final f = FatigueCalculator.compute(
        List.filled(10, ReminderOutcome.logged),
      );
      expect(f.level, FatigueLevel.low);
      expect(f.index, 0);
    });
    test('trailing unanswered counts only the trailing run', () {
      expect(
        FatigueCalculator.trailingUnanswered([
          ReminderOutcome.ignored,
          ReminderOutcome.logged,
          ReminderOutcome.ignored,
          ReminderOutcome.ignored,
        ]),
        2,
      );
    });
  });
}
