import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/core/util/validation.dart';
import 'package:hydra/data/database/app_database.dart';
import 'package:hydra/data/repositories/hydration_repository.dart';
import 'package:hydra/data/repositories/misc_repositories.dart';
import 'package:hydra/data/repositories/profile_repository.dart';
import 'package:hydra/data/repositories/reminder_repository.dart';
import 'package:hydra/data/repositories/routine_repository.dart';
import 'package:hydra/data/repositories/vessel_repository.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';

void main() {
  late AppDatabase db;
  late HydrationRepository repo;
  final t0 = DateTime.utc(2026, 10, 7, 4, 0); // 09:30 IST

  setUpAll(ensureTimeZonesInitialized);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = HydrationRepository(db, now: () => t0);
  });
  tearDown(() => db.close());

  group('HydrationRepository', () {
    test('add persists with UTC, zone and logical local date', () async {
      final e = await repo.add(volumeMl: 250, at: t0, timezone: 'Asia/Kolkata');
      expect(e.localDate, const LocalDate(2026, 10, 7));
      final back = await repo.getById(e.id);
      expect(back!.volumeMl, 250);
      expect(back.timestampUtc, t0);
      expect(back.timezone, 'Asia/Kolkata');
    });

    test('rejects zero, negative and absurd volumes (DB never touched)', () async {
      for (final bad in [0, -50, 5001, 100000]) {
        expect(() => repo.add(volumeMl: bad, at: t0, timezone: 'UTC'),
            throwsA(isA<ValidationException>()));
      }
      expect(await repo.all(), isEmpty);
    });

    test('database CHECK constraint also rejects bad volumes', () async {
      await expectLater(
        db.customStatement(
          "INSERT INTO hydration_entries (id,timestamp_utc,timezone,local_date,volume_ml,source,created_at,updated_at) "
          "VALUES ('x',0,'UTC','2026-01-01',-5,'manual',0,0)",
        ),
        throwsA(anything),
      );
    });

    test('total never negative; delete never increases total', () async {
      final a = await repo.add(volumeMl: 300, at: t0, timezone: 'Asia/Kolkata');
      await repo.add(volumeMl: 200, at: t0, timezone: 'Asia/Kolkata');
      final d = const LocalDate(2026, 10, 7);
      final before = await repo.totalForDay(d);
      await repo.delete(a.id);
      final after = await repo.totalForDay(d);
      expect(after, lessThanOrEqualTo(before));
      expect(after, greaterThanOrEqualTo(0));
      expect(await repo.totalForDay(const LocalDate(2020, 1, 1)), 0);
    });

    test('undo-delete restores exactly', () async {
      final a = await repo.add(volumeMl: 300, at: t0, timezone: 'Asia/Kolkata');
      final deleted = await repo.delete(a.id);
      await repo.restore(deleted!);
      expect((await repo.getById(a.id))!.volumeMl, 300);
    });

    test('update changes volume and keeps id', () async {
      final a = await repo.add(volumeMl: 300, at: t0, timezone: 'Asia/Kolkata');
      await repo.update(a.id, volumeMl: 350);
      expect((await repo.getById(a.id))!.volumeMl, 350);
      expect(() => repo.update(a.id, volumeMl: 0), throwsA(isA<ValidationException>()));
      expect(() => repo.update('missing', volumeMl: 5), throwsA(isA<ValidationException>()));
    });

    test('moving an entry to another day recomputes its local date', () async {
      final a = await repo.add(volumeMl: 300, at: t0, timezone: 'Asia/Kolkata');
      final moved = await repo.update(a.id, at: t0.subtract(const Duration(days: 1)));
      expect(moved.localDate, const LocalDate(2026, 10, 6));
    });

    test('changing device timezone later never rewrites historical instants', () async {
      final a = await repo.add(volumeMl: 250, at: t0, timezone: 'Asia/Kolkata');
      // A later entry in another zone.
      await repo.add(volumeMl: 250, at: t0.add(const Duration(hours: 20)), timezone: 'America/New_York');
      final back = await repo.getById(a.id);
      expect(back!.timestampUtc, t0);
      expect(back.timezone, 'Asia/Kolkata');
      expect(back.localDate, const LocalDate(2026, 10, 7));
    });

    test('100 rapid logs are all persisted and totals are exact', () async {
      await Future.wait([
        for (var i = 0; i < 100; i++)
          repo.add(volumeMl: 50, at: t0.add(Duration(seconds: i)), timezone: 'Asia/Kolkata'),
      ]);
      expect(await repo.totalForDay(const LocalDate(2026, 10, 7)), 5000);
      expect((await repo.entriesForDay(const LocalDate(2026, 10, 7))).length, 100);
    });

    test('duplicate external record does not double count', () async {
      final a = await repo.add(volumeMl: 500, at: t0, timezone: 'UTC',
          source: EntrySource.healthkit, externalRecordId: 'HK-1');
      final b = await repo.add(volumeMl: 500, at: t0, timezone: 'UTC',
          source: EntrySource.healthkit, externalRecordId: 'HK-1');
      expect(b.id, a.id);
      expect((await repo.all()).length, 1);
    });

    test('deleting an imported entry leaves a tombstone', () async {
      final a = await repo.add(volumeMl: 500, at: t0, timezone: 'UTC',
          source: EntrySource.healthConnect, externalRecordId: 'HC-9');
      await repo.delete(a.id);
      expect(await repo.tombstones(EntrySource.healthConnect), {'HC-9'});
      // restore clears it
      await repo.restore(a);
      expect(await repo.tombstones(EntrySource.healthConnect), isEmpty);
    });

    test('frequent volumes need minimum uses (no unpredictable suggestions)', () async {
      repo = HydrationRepository(db, now: () => t0.add(const Duration(days: 1)));
      for (var i = 0; i < 4; i++) {
        await repo.add(volumeMl: 330, at: t0, timezone: 'UTC');
      }
      await repo.add(volumeMl: 123, at: t0, timezone: 'UTC');
      final f = await repo.frequentVolumes();
      expect(f.single.ml, 330);
    });

    test('streams update after writes', () async {
      final d = const LocalDate(2026, 10, 7);
      final emitted = <int>[];
      final sub = repo.watchTotalForDay(d).listen(emitted.add);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.add(volumeMl: 250, at: t0, timezone: 'Asia/Kolkata');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await sub.cancel();
      expect(emitted.last, 250);
    });
  });

  group('Profile / vessels / routines', () {
    test('profile ensure + save round trip and bounds', () async {
      final repo = ProfileRepository(db);
      final p = await repo.ensure(now: t0, timezone: 'Asia/Kolkata');
      expect(p.dailyTargetMl, 2400);
      await repo.save(p.copyWith(dailyTargetMl: 3000, quickAddsMl: [200, 300]));
      final back = await repo.get();
      expect(back!.dailyTargetMl, 3000);
      expect(back.quickAddsMl, [200, 300]);
      expect(() => repo.save(p.copyWith(dailyTargetMl: 100)), throwsA(isA<ValidationException>()));
      expect(() => repo.save(p.copyWith(wakeMinute: 2000)), throwsA(isA<ValidationException>()));
    });

    test('vessels: limit, validation, delete keeps history', () async {
      final v = VesselRepository(db);
      final h = HydrationRepository(db, now: () => t0);
      final a = await v.upsert(name: 'Desk', volumeMl: 750);
      await h.add(volumeMl: 750, at: t0, timezone: 'UTC', vesselId: a.id);
      await v.delete(a.id);
      final e = (await h.all()).single;
      expect(e.volumeMl, 750);
      expect(e.vesselId, isNull);
      expect(() => v.upsert(name: '', volumeMl: 100), throwsA(isA<ValidationException>()));
      expect(() => v.upsert(name: 'x', volumeMl: 0), throwsA(isA<ValidationException>()));
      for (var i = 0; i < 2; i++) {
        await v.upsert(name: 'v$i', volumeMl: 100, limit: 2);
      }
      expect(() => v.upsert(name: 'over', volumeMl: 100, limit: 2),
          throwsA(isA<ValidationException>()));
    });

    test('routines persist spans and reject invalid times', () async {
      final r = RoutineRepository(db);
      final routine = r.blank(name: 'Office', kind: RoutineKind.work, wake: 7 * 60, sleep: 23 * 60, weekdays: {1, 2, 3, 4, 5})
          .copyWith(quietSpans: [const TimeSpan(13 * 60, 14 * 60)]);
      await r.upsert(routine);
      final back = (await r.getAll()).single;
      expect(back.weekdays, {1, 2, 3, 4, 5});
      expect(back.quietSpans.single, const TimeSpan(13 * 60, 14 * 60));
      expect(() => r.upsert(routine.copyWith(sleepMinute: 8 * 60)), throwsA(isA<ValidationException>()));
    });
  });

  group('Reminders & settings', () {
    test('reminder lifecycle', () async {
      final rr = ReminderRepository(db);
      final e = ReminderEvent(
        id: 'r1',
        scheduledAt: t0.add(const Duration(hours: 1)),
        localDate: const LocalDate(2026, 10, 7),
        type: ReminderType.adaptive,
        outcome: ReminderOutcome.pending,
        reason: 'paceGap',
        algorithmVersion: 'HRE_V1',
      );
      await rr.insertScheduled([e]);
      expect((await rr.pendingAfter(t0)).length, 1);
      expect((await rr.pendingBefore(t0)).length, 0);
      await rr.cancelFuturePending(t0);
      expect((await rr.pendingAfter(t0)).length, 0);
      await rr.insertScheduled([e.copyWith(outcome: ReminderOutcome.pending)]);
      await rr.resolve('r1', ReminderOutcome.logged, t0.add(const Duration(hours: 1, minutes: 5)));
      expect((await rr.recentResolved()).single.outcome, ReminderOutcome.logged);
    });

    test('settings kv + malformed json is safe', () async {
      final s = SettingsRepository(db);
      await s.setString('a', '1');
      expect(await s.getString('a'), '1');
      await s.setString('bad', '{not json');
      expect(await s.getJson('bad'), isEmpty);
      await s.setJson('ok', {'x': 1});
      expect((await s.getJson('ok'))['x'], 1);
      expect(await s.getBool('missing', fallback: true), isTrue);
    });

    test('achievements unlock once', () async {
      final a = AchievementRepository(db);
      expect(await a.unlock('c1', 'challenge', t0), isTrue);
      expect(await a.unlock('c1', 'challenge', t0), isFalse);
    });
  });

  test('deleteEverything wipes all tables', () async {
    await repo.add(volumeMl: 250, at: t0, timezone: 'UTC');
    await VesselRepository(db).upsert(name: 'X', volumeMl: 100);
    await ProfileRepository(db).ensure(now: t0, timezone: 'UTC');
    await SettingsRepository(db).setString('k', 'v');
    await db.deleteEverything();
    expect(await repo.all(), isEmpty);
    expect(await VesselRepository(db).getAll(), isEmpty);
    expect(await ProfileRepository(db).get(), isNull);
    expect(await SettingsRepository(db).getString('k'), isNull);
  });
}
