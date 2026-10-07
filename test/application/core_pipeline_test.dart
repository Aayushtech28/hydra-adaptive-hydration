import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/application/hydra_core.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/core/util/validation.dart';
import 'package:hydra/data/repositories/misc_repositories.dart';
import 'package:hydra/domain/hre/types.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:hydra/services/notifications/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

import '../support/harness.dart';

int _localMinute(DateTime t, String zone) {
  final l = tz.TZDateTime.from(t.toUtc(), locationFor(zone));
  return l.hour * 60 + l.minute;
}

void main() {
  late Harness h;
  setUp(() async => h = await Harness.create());
  tearDown(() => h.dispose());

  test('logging persists immediately and reschedules a bounded chain', () async {
    final r = await h.core.log(volumeMl: 250);
    expect(r.dayTotalMl, 250);
    await h.settle();
    final s = h.notifications.scheduled;
    expect(s, isNotEmpty);
    expect(s.length, lessThanOrEqualTo(6));
    for (final r in s) {
      expect(r.at.isAfter(h.now), isTrue);
      final m = _localMinute(r.at, 'Asia/Kolkata');
      expect(m >= 7 * 60 + 30 && m <= 22 * 60, isTrue, reason: 'reminder at minute $m');
      expect(r.body, isNotEmpty);
    }
    for (var i = 1; i < s.length; i++) {
      expect(s[i].at.isAfter(s[i - 1].at), isTrue);
    }
    expect(h.widgets.last!.percent, 10);
  });

  test('log validates before touching the database', () async {
    for (final bad in [0, -1, 6000]) {
      expect(() => h.core.log(volumeMl: bad), throwsA(isA<ValidationException>()));
    }
    expect(await h.core.hydration.all(), isEmpty);
  });

  test('notification action logs without the UI, resolves the event, reschedules', () async {
    await h.core.reschedule(reason: 'init');
    final ev = (await h.core.reminders.pendingAfter(h.now)).first;
    h.now = ev.scheduledAt.add(const Duration(minutes: 1));
    await h.core.handleNotificationAction(NotificationAction(NotificationActionKind.log, ml: 250, eventId: ev.id));
    await h.settle();
    final e = await h.core.reminders.getById(ev.id);
    expect(e!.outcome, ReminderOutcome.logged);
    expect((await h.core.hydration.all()).single.source, EntrySource.notificationAction);
    expect(h.notifications.scheduled.every((r) => r.at.isAfter(h.now)), isTrue);
  });

  test('malformed notification action is ignored safely', () async {
    expect(NotificationAction.parse(actionId: 'log:abc'), isNull);
    expect(NotificationAction.parse(actionId: 'log:-5'), isNull);
    expect(NotificationAction.parse(actionId: 'log:999999'), isNull);
    expect(NotificationAction.parse(actionId: 'evil'), isNull);
    expect(NotificationAction.parse(actionId: null, payload: 'v1|abc')!.kind, NotificationActionKind.open);
  });

  test('snooze reschedules exactly 30 minutes ahead', () async {
    await h.core.log(volumeMl: 300);
    await h.settle();
    await h.core.snooze(const Duration(minutes: 30));
    await h.settle();
    expect(h.notifications.scheduled.first.at, h.now.add(const Duration(minutes: 30)));
  });

  test('repeated snooze keeps honouring the latest request', () async {
    for (var i = 0; i < 3; i++) {
      await h.core.snooze(const Duration(minutes: 30));
      h.advance(const Duration(minutes: 10));
    }
    await h.settle();
    final first = h.notifications.scheduled.first.at;
    expect(first.isAfter(h.now), isTrue);
  });

  test('pause until next log schedules nothing, then resumes after a log', () async {
    await h.core.pauseUntilNextLog();
    await h.settle();
    expect(h.notifications.scheduled, isEmpty);
    h.advance(const Duration(minutes: 1));
    await h.core.log(volumeMl: 250);
    await h.settle();
    expect(h.notifications.scheduled, isNotEmpty);
  });

  test('timed pause floors reminders', () async {
    final until = h.now.add(const Duration(hours: 3));
    await h.core.pauseUntil(until);
    await h.settle();
    expect(h.notifications.scheduled.every((r) => !r.at.isBefore(until)), isTrue);
  });

  test('permission denied: tracking works, nothing scheduled, no crash', () async {
    h.notifications.perm = NotificationPermission.denied;
    await h.core.log(volumeMl: 500);
    await h.settle();
    expect(h.notifications.scheduled, isEmpty);
    expect(await h.core.hydration.totalForDay(await h.core.today()), 500);
    final ctx = await h.core.currentContext();
    expect(h.core.plans.decide(ctx).snapshot.consumedMl, 500);
  });

  test('permission revoked later: next reschedule clears the chain safely', () async {
    await h.core.reschedule();
    expect(h.notifications.scheduled, isNotEmpty);
    h.notifications.perm = NotificationPermission.denied;
    await h.core.reschedule();
    expect(await h.core.reminders.pendingAfter(h.now), isEmpty);
  });

  test('reminders disabled in profile schedules nothing', () async {
    await h.core.updateProfile((p) => p.copyWith(remindersEnabled: false));
    expect(h.notifications.scheduled, isEmpty);
  });

  test('100 rapid taps: all persisted, reschedules coalesced, single chain', () async {
    await Future.wait([for (var i = 0; i < 100; i++) h.core.log(volumeMl: 20)]);
    await h.settle();
    expect(await h.core.hydration.totalForDay(await h.core.today()), 2000);
    expect(h.notifications.replaceCalls, lessThan(20));
    final pending = await h.core.reminders.pendingAfter(h.now);
    expect(pending.length, lessThanOrEqualTo(6));
  });

  test('undo (delete) then redo restores the total and never goes negative', () async {
    final r = await h.core.log(volumeMl: 400);
    await h.core.deleteEntry(r.entry.id);
    expect(await h.core.hydration.totalForDay(await h.core.today()), 0);
    await h.core.restoreEntry(r.entry);
    expect(await h.core.hydration.totalForDay(await h.core.today()), 400);
    // ten repeated undo requests on the same entry are harmless
    for (var i = 0; i < 10; i++) {
      await h.core.deleteEntry(r.entry.id);
    }
    expect(await h.core.hydration.totalForDay(await h.core.today()), 0);
  });

  test('changing the target recalculates pace and schedule', () async {
    await h.core.log(volumeMl: 500);
    final before = h.core.plans.decide(await h.core.currentContext()).snapshot.percent;
    await h.core.updateProfile((p) => p.copyWith(dailyTargetMl: 4000));
    final after = h.core.plans.decide(await h.core.currentContext()).snapshot.percent;
    expect(after, lessThan(before));
  });

  test('changing wake time moves the first reminder (before wake)', () async {
    h.now = DateTime.utc(2026, 10, 7, 0, 30); // 06:00 IST, before wake
    await h.core.updateProfile((p) => p.copyWith(wakeMinute: 6 * 60 + 30));
    await h.settle();
    final first = h.notifications.scheduled.first;
    expect(_localMinute(first.at, 'Asia/Kolkata'), 6 * 60 + 30 + 45);
  });

  test('changing sleep time earlier ends today’s reminders earlier', () async {
    h.now = DateTime.utc(2026, 10, 7, 12, 0); // 17:30 IST
    await h.core.updateProfile((p) => p.copyWith(sleepMinute: 20 * 60));
    await h.settle();
    final today = h.notifications.scheduled.where((r) => _localMinute(r.at, 'Asia/Kolkata') > 7 * 60 + 30 && r.at.day == 7);
    for (final r in today) {
      expect(_localMinute(r.at, 'Asia/Kolkata') <= 19 * 60, isTrue);
    }
  });

  test('timezone change recalculates future reminders in the new wall clock; history untouched', () async {
    final logged = await h.core.log(volumeMl: 250);
    final instant = logged.entry.timestampUtc;
    h.timezone = 'America/New_York';
    expect(await h.core.detectTimezoneChange(), 'America/New_York');
    h.now = DateTime.utc(2026, 10, 7, 14, 0); // 10:00 EDT
    await h.core.acceptTimezone('America/New_York');
    await h.settle();
    for (final r in h.notifications.scheduled) {
      final m = _localMinute(r.at, 'America/New_York');
      expect(m >= 7 * 60 + 30 && m <= 22 * 60, isTrue, reason: 'NY minute $m');
    }
    final back = await h.core.hydration.getById(logged.entry.id);
    expect(back!.timestampUtc, instant);
    expect(back.timezone, 'Asia/Kolkata');
    expect(await h.core.detectTimezoneChange(), isNull);
  });

  test('reminders elapse: logged within window = logged, otherwise ignored', () async {
    await h.core.reschedule();
    final evs = await h.core.reminders.pendingAfter(h.now);
    expect(evs, isNotEmpty);
    final first = evs.first;
    h.now = first.scheduledAt.add(const Duration(minutes: 10));
    await h.core.log(volumeMl: 250);
    h.now = first.scheduledAt.add(const Duration(minutes: 60));
    await h.core.coordinator.resolveElapsed(h.now);
    expect((await h.core.reminders.getById(first.id))!.outcome, ReminderOutcome.logged);

    if (evs.length > 1) {
      final second = evs[1];
      h.now = second.scheduledAt.add(const Duration(minutes: 50));
      await h.core.coordinator.resolveElapsed(h.now);
      expect((await h.core.reminders.getById(second.id))!.outcome, anyOf(ReminderOutcome.ignored, ReminderOutcome.cancelled));
    }
  });

  test('ignored reminders make the engine quieter, not louder', () async {
    // Simulate a week of ignored reminders then compare spacing.
    final start = h.now;
    for (var d = 0; d < 6; d++) {
      h.now = start.add(Duration(days: d));
      await h.core.reschedule();
      final evs = await h.core.reminders.pendingAfter(h.now);
      for (final e in evs) {
        h.now = e.scheduledAt.add(const Duration(minutes: 50));
        await h.core.coordinator.resolveElapsed(h.now);
      }
    }
    final outcomes = (await h.core.reminders.recentResolved()).map((e) => e.outcome).toList();
    expect(outcomes.where((o) => o == ReminderOutcome.ignored).length, greaterThan(5));
    h.now = start.add(const Duration(days: 7));
    final ctx = await h.core.currentContext();
    expect(ctx.input.fatigue.level, isNot(FatigueLevel.low));
    final unanswered = ctx.input.consecutiveUnanswered;
    expect(unanswered, lessThanOrEqualTo(4));
  });

  test('quiet hours: scheduler never schedules inside a routine quiet span', () async {
    final r = h.core.routines.blank(
      name: 'Office',
      kind: RoutineKind.work,
      wake: 7 * 60 + 30,
      sleep: 23 * 60,
      weekdays: {1, 2, 3, 4, 5, 6, 7},
    ).copyWith(quietSpans: [const TimeSpan(11 * 60, 14 * 60)]);
    await h.core.routines.upsert(r);
    await h.core.log(volumeMl: 250);
    await h.settle();
    for (final s in h.notifications.scheduled) {
      final m = _localMinute(s.at, 'Asia/Kolkata');
      expect(m >= 11 * 60 && m < 14 * 60, isFalse, reason: 'inside quiet: $m');
    }
  });

  test('switching routines repeatedly never destroys history', () async {
    await h.core.log(volumeMl: 250);
    final a = await h.core.routines.upsert(h.core.routines.blank(name: 'A', kind: RoutineKind.work, wake: 420, sleep: 1380));
    final b = await h.core.routines.upsert(h.core.routines.blank(name: 'B', kind: RoutineKind.travel, wake: 480, sleep: 1320));
    for (var i = 0; i < 10; i++) {
      await h.core.updateProfile((p) => p.copyWith(activeRoutineId: i.isEven ? a.id : b.id));
    }
    expect(await h.core.hydration.totalForDay(await h.core.today()), 250);
    await h.core.updateProfile((p) => p.copyWith(clearActiveRoutine: true));
    expect((await h.core.profiles.get())!.activeRoutineId, isNull);
  });

  test('scheduler ends the day with tomorrow’s first reminder', () async {
    h.now = DateTime.utc(2026, 10, 7, 15, 0); // 20:30 IST
    await h.core.log(volumeMl: 300);
    await h.settle();
    final last = h.notifications.scheduled.last;
    expect(last.at.toUtc().day, anyOf(7, 8));
    expect(_localMinute(last.at, 'Asia/Kolkata'), lessThanOrEqualTo(22 * 60));
  });

  test('delete-all wipes data, reminders and resets widget; can restart fresh', () async {
    await h.core.log(volumeMl: 250);
    await h.core.deleteAllData();
    expect(await h.core.hydration.all(), isEmpty);
    expect(await h.core.profiles.get(), isNull);
    expect(h.notifications.scheduled, isEmpty);
    expect(h.widgets.last!.percent, 0);
    await h.core.bootstrap();
    expect((await h.core.profiles.get())!.onboardingComplete, isFalse);
  });

  test('premium expiry style invariants: hydration data unaffected by settings', () async {
    await h.core.log(volumeMl: 250);
    await h.core.settings.setString(SettingKeys.entitlementCache, '{"s":"expired"}');
    expect(await h.core.hydration.totalForDay(await h.core.today()), 250);
  });

  test('day stats are computed for completed days and cached', () async {
    final day1 = DateTime.utc(2026, 10, 5, 4, 0);
    h.now = day1;
    await h.core.log(volumeMl: 1000, at: day1);
    h.now = DateTime.utc(2026, 10, 7, 4, 0);
    final today = await h.core.today();
    final days = await h.core.stats.completedDays(today, now: h.now);
    expect(days.where((d) => d.active).length, 1);
    expect(days.last.date, today.addDays(-1));
    final cached = await h.core.summaries.range(const LocalDate(2026, 10, 1), today);
    expect(cached, isNotEmpty);
  });
}
