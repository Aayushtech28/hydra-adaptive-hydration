import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/domain/hre/scheduler.dart';
import 'package:hydra/domain/hre/types.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(ensureTimeZonesInitialized);
  const sched = HydrationScheduler();
  final ny = locationFor('America/New_York');

  DayContext ctx(LocalDate d, {int wake = 7 * 60, int sleep = 23 * 60}) =>
      DayContext(
        window: DayWindow.build(
          date: d,
          location: ny,
          wakeMinute: wake,
          sleepMinute: sleep,
        ),
      );

  test('fall-back: a window spanning the repeated hour is 1h longer in absolute time; trajectory stays monotonic', () {
    // Overnight 22:00 → 04:00 across the 2 AM change is 7 real hours, not 6.
    final span = ctx(
      const LocalDate(2026, 10, 31),
      wake: 22 * 60,
      sleep: 4 * 60,
    ).window;
    expect(span.lengthMinutes, 7 * 60);
    // A daytime window on the change day is unaffected (the extra hour is at 2 AM).
    final w = ctx(const LocalDate(2026, 11, 1)).window;
    expect(w.lengthMinutes, 16 * 60);
    final traj = PlanTrajectory(targetMl: 2400, window: w);
    var prev = -1.0;
    for (var m = 0; m <= 16 * 60; m += 30) {
      final v = traj.expectedMlAt(w.wake.add(Duration(minutes: m)));
      expect(v, greaterThanOrEqualTo(prev));
      prev = v;
    }
  });

  test(
    'reminders on a DST change day stay within waking hours in wall-clock time',
    () {
      for (final date in [
        const LocalDate(2026, 3, 8),
        const LocalDate(2026, 11, 1),
      ]) {
        for (var hour = 7; hour < 22; hour += 3) {
          final now = tz.TZDateTime(
            ny,
            date.year,
            date.month,
            date.day,
            hour,
            10,
          );
          final input = SchedulerInput(
            now: now,
            today: ctx(date),
            tomorrow: ctx(date.addDays(1)),
            targetMl: 2400,
            consumedMl: 600,
            policy: ReminderPolicy.forMode(ReminderMode.balanced),
            lastLogAt: now.subtract(const Duration(minutes: 30)),
          );
          for (final d in sched.planChain(input)) {
            final t = tz.TZDateTime.from(d.nextReminder!, ny);
            final m = t.hour * 60 + t.minute;
            expect(
              m >= 7 * 60 && m <= 22 * 60,
              isTrue,
              reason: '$date $hour:10 → $t',
            );
            expect(d.nextReminder!.isAfter(now), isTrue);
          }
        }
      }
    },
  );

  test('first reminder after a DST night lands at wake + offset in wall-clock time', () {
    final date = const LocalDate(2026, 3, 8);
    final now = tz.TZDateTime(ny, 2026, 3, 8, 1, 0);
    final input = SchedulerInput(
      now: now,
      today: ctx(date),
      tomorrow: ctx(date.addDays(1)),
      targetMl: 2400,
      consumedMl: 0,
      policy: ReminderPolicy.forMode(ReminderMode.balanced),
    );
    final first = sched.decide(input).nextReminder!;
    final l = tz.TZDateTime.from(first, ny);
    expect(l.hour * 60 + l.minute, 7 * 60 + 45);
  });
}
