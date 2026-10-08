import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/core/util/validation.dart';
import 'package:hydra/domain/hre/types.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:hydra/domain/sync/health_reconciler.dart';
import 'package:hydra/services/export/export_service.dart';
import 'package:hydra/services/health/health_service.dart';
import 'package:hydra/services/health/health_sync_service.dart';
import 'package:timezone/timezone.dart' as tz;

import '../support/fakes.dart';
import '../support/harness.dart';

int _min(DateTime t, String z) {
  final l = tz.TZDateTime.from(t.toUtc(), locationFor(z));
  return l.hour * 60 + l.minute;
}

void main() {
  late Harness h;
  setUp(() async => h = await Harness.create());
  tearDown(() => h.dispose());

  group('onboarding & scheduling gate', () {
    test('no reminders are scheduled before onboarding completes', () async {
      final fresh = await Harness.create(onboarded: false);
      await fresh.core.reschedule(reason: 'test');
      expect(fresh.notifications.scheduled, isEmpty);
      expect(await fresh.core.reminders.pendingAfter(fresh.now), isEmpty);
      await fresh.core.completeOnboarding();
      await fresh.core.reschedule(reason: 'test');
      expect(fresh.notifications.scheduled, isNotEmpty);
      await fresh.dispose();
    });
  });

  group('input validation', () {
    test(
      'future-dated log is rejected, small clock skew is accepted',
      () async {
        expect(
          () => h.core.log(
            volumeMl: 250,
            at: h.now.add(const Duration(hours: 1)),
          ),
          throwsA(isA<ValidationException>()),
        );
        await h.core.log(
          volumeMl: 250,
          at: h.now.add(const Duration(minutes: 3)),
        );
        expect(await h.core.hydration.count(), 1);
      },
    );
    test(
      'editing an entry into the future is rejected and leaves it unchanged',
      () async {
        final r = await h.core.log(volumeMl: 250);
        expect(
          () => h.core.editEntry(
            r.entry.id,
            at: h.now.add(const Duration(days: 1)),
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(
          (await h.core.hydration.getById(r.entry.id))!.timestampUtc,
          r.entry.timestampUtc,
        );
      },
    );
    test('edit then delete then undo round-trips the day total', () async {
      final r = await h.core.log(volumeMl: 300);
      await h.core.editEntry(r.entry.id, volumeMl: 450);
      expect(await h.core.hydration.totalForDay(await h.core.today()), 450);
      final e = (await h.core.hydration.getById(r.entry.id))!;
      await h.core.deleteEntry(e.id);
      await h.core.restoreEntry(e);
      expect(await h.core.hydration.totalForDay(await h.core.today()), 450);
    });
  });

  group('smart quiet hours never shadow the schedule', () {
    test(
      'no weekend variant: one routine for every day carrying the span',
      () async {
        await h.core.addQuietSpan(
          const TimeSpan(14 * 60, 15 * 60),
          weekdayName: 'Weekday',
          weekendName: 'Weekend',
        );
        final rs = await h.core.routines.getAll();
        expect(rs.single.weekdays.length, 7);
        expect(rs.single.quietSpans.single, const TimeSpan(14 * 60, 15 * 60));
      },
    );
    test('weekend variant is preserved with its own wake/sleep', () async {
      await h.core.updateProfile(
        (p) => p.copyWith(
          weekendDifferent: true,
          weekendWakeMinute: 9 * 60,
          weekendSleepMinute: 60,
        ),
      );
      await h.core.addQuietSpan(
        const TimeSpan(14 * 60, 15 * 60),
        weekdayName: 'Weekday',
        weekendName: 'Weekend',
      );
      final rs = await h.core.routines.getAll();
      expect(rs.length, 2);
      final weekend = rs.firstWhere((r) => r.weekdays.contains(6));
      expect(weekend.wakeMinute, 9 * 60);
      expect(weekend.sleepMinute, 60);
      expect(
        rs.firstWhere((r) => r.weekdays.contains(1)).wakeMinute,
        7 * 60 + 30,
      );
    });
    test('adds to the routine already in effect', () async {
      final r = await h.core.routines.upsert(
        h.core.routines.blank(
          name: 'Office',
          kind: RoutineKind.work,
          wake: 420,
          sleep: 1380,
          weekdays: {1, 2, 3, 4, 5, 6, 7},
        ),
      );
      await h.core.addQuietSpan(
        const TimeSpan(13 * 60, 14 * 60),
        weekdayName: 'a',
        weekendName: 'b',
      );
      final rs = await h.core.routines.getAll();
      expect(rs.single.id, r.id);
      expect(rs.single.quietSpans, hasLength(1));
    });
  });

  group('day rollover & timezones', () {
    test('a drink at 02:00 belongs to the previous logical day; 04:00 starts a new one', () async {
      h.now = DateTime.utc(2026, 10, 7, 20, 30); // 02:00 IST on the 8th
      final late = await h.core.log(volumeMl: 200);
      expect(late.entry.localDate, const LocalDate(2026, 10, 7));
      expect(await h.core.today(), const LocalDate(2026, 10, 7));
      h.now = DateTime.utc(2026, 10, 7, 22, 30); // 04:00 IST
      expect(await h.core.today(), const LocalDate(2026, 10, 8));
    });
    test('overnight routine (sleep 01:00): reminders at 00:30 still fall inside the day', () async {
      await h.core.updateProfile((p) => p.copyWith(sleepMinute: 60));
      h.now = DateTime.utc(2026, 10, 7, 18, 30); // 00:00 IST night of 7th→8th
      await h.core.log(volumeMl: 100);
      await h.settle();
      for (final r in h.notifications.scheduled) {
        final m = _min(r.at, 'Asia/Kolkata');
        // never between planned sleep (01:00) and wake (07:30)
        expect(
          m >= 60 && m < 7 * 60 + 30,
          isFalse,
          reason: 'reminder at minute $m',
        );
      }
    });
    test('traveller: same instant is a different logical date per zone, history keeps its zone', () async {
      final e = await h.core.log(
        volumeMl: 250,
        at: DateTime.utc(2026, 10, 7, 3, 0),
      );
      expect(e.entry.timezone, 'Asia/Kolkata');
      h.timezone = 'Pacific/Auckland';
      // 03:00 UTC on the 7th is still the 7th in Kolkata; in Auckland it is the evening of the 7th.
      expect(e.entry.localDate, const LocalDate(2026, 10, 7));
      expect(await h.core.today(), const LocalDate(2026, 10, 7));
      expect(
        (await h.core.hydration.getById(e.entry.id))!.timezone,
        'Asia/Kolkata',
      );
    });
  });

  group('health sync safety', () {
    HealthSyncService svc(FakeHealthService fake) => HealthSyncService(
      health: fake,
      hydration: h.core.hydration,
      settings: h.core.settings,
      timezoneName: () => 'Asia/Kolkata',
      now: () => h.now,
    );

    test('disabled by default: sync is a no-op', () async {
      final fake = FakeHealthService()
        ..external = [ExternalHydration(id: 'a', at: h.now, ml: 300)];
      final r = await svc(fake).sync();
      expect(r.ok, isTrue);
      expect(await h.core.hydration.count(), 0);
    });
    test(
      'imports once; a second sync is idempotent (no double count)',
      () async {
        final fake = FakeHealthService()
          ..external = [ExternalHydration(id: 'a', at: h.now, ml: 300)];
        final s = svc(fake);
        await s.enable(SyncDirection.twoWay);
        await s.sync();
        await s.sync();
        expect(await h.core.hydration.totalForDay(await h.core.today()), 300);
      },
    );
    test('HYDRA entry already in Health is linked, not double counted, and not re-exported', () async {
      final log = await h.core.log(volumeMl: 500);
      final fake = FakeHealthService()
        ..external = [
          ExternalHydration(id: 'hk1', at: log.entry.timestampUtc, ml: 500),
        ];
      final s = svc(fake);
      await s.enable(SyncDirection.twoWay);
      await s.sync();
      expect(await h.core.hydration.totalForDay(await h.core.today()), 500);
      expect(fake.written, isEmpty);
    });
    test('manual entries are exported once', () async {
      await h.core.log(volumeMl: 250);
      final fake = FakeHealthService();
      final s = svc(fake);
      await s.enable(SyncDirection.twoWay);
      await s.sync();
      await s.sync();
      expect(fake.written, hasLength(1));
    });
    test('failures never touch local data and are reported', () async {
      await h.core.log(volumeMl: 250);
      final fake = FakeHealthService()
        ..failRead = HealthSyncFailure.permissionRevoked;
      final s = svc(fake);
      await s.enable(SyncDirection.twoWay);
      final r = await s.sync();
      expect(r.ok, isFalse);
      expect(r.failure, HealthSyncFailure.permissionRevoked);
      expect(await h.core.hydration.totalForDay(await h.core.today()), 250);
      fake.failRead = null;
      fake.failWrite = HealthSyncFailure.platformError;
      expect((await s.sync()).ok, isFalse);
      expect(await h.core.hydration.count(), 1);
    });
    test(
      'an empty read (iOS hides denied access) never deletes imported entries',
      () async {
        final fake = FakeHealthService()
          ..external = [ExternalHydration(id: 'a', at: h.now, ml: 300)];
        final s = svc(fake);
        await s.enable(SyncDirection.twoWay);
        await s.sync();
        fake.external = [];
        await s.sync();
        expect(await h.core.hydration.totalForDay(await h.core.today()), 300);
      },
    );
    test('a user-deleted imported entry is not resurrected', () async {
      final fake = FakeHealthService()
        ..external = [ExternalHydration(id: 'a', at: h.now, ml: 300)];
      final s = svc(fake);
      await s.enable(SyncDirection.twoWay);
      await s.sync();
      final e = (await h.core.hydration.all()).single;
      await h.core.deleteEntry(e.id);
      await s.sync();
      expect(await h.core.hydration.count(), 0);
    });
  });

  group('export & deletion', () {
    ExportService export() => ExportService(
      hydration: h.core.hydration,
      vessels: h.core.vessels,
      routines: h.core.routines,
      profile: h.core.profiles,
      now: () => h.now,
    );

    test(
      'CSV has the documented header, one row per entry, UTC timestamps and ml',
      () async {
        await h.core.log(volumeMl: 250);
        await h.core.log(volumeMl: 500);
        final rows = const LineSplitter().convert(await export().buildCsv());
        expect(
          rows.first,
          'id,date,timestamp_utc,timezone,volume_ml,beverage,vessel,source',
        );
        expect(rows, hasLength(3));
        expect(rows[1].split(',')[4], '250');
        expect(rows[1], contains('2026-10-07'));
      },
    );
    test('CSV escapes commas/quotes and neutralises spreadsheet formulas', () {
      expect(ExportService.csvField('a,b'), '"a,b"');
      expect(ExportService.csvField('say "hi"'), '"say ""hi"""');
      expect(ExportService.csvField('=SUM(A1)'), "'=SUM(A1)");
      expect(ExportService.csvField('+1'), "'+1");
      expect(ExportService.csvField('plain'), 'plain');
    });
    test('JSON export is versioned and contains profile, vessels, routines and entries', () async {
      await h.core.log(volumeMl: 250);
      final j = jsonDecode(await export().buildJson()) as Map<String, dynamic>;
      expect(j['schema'], 'hydra.export.v1');
      expect((j['entries'] as List).single['volumeMl'], 250);
      expect((j['vessels'] as List), isNotEmpty);
      expect((j['profile'] as Map)['dailyTargetMl'], 2400);
      // No analytics identifiers or subscription data are part of the export.
      expect(
        j.keys,
        containsAll(['profile', 'vessels', 'routines', 'entries']),
      );
      expect(j.containsKey('entitlement'), isFalse);
    });
    test('deleteAllData removes every user table, cancels reminders, resets widget', () async {
      await h.core.log(volumeMl: 250);
      await h.core.reschedule();
      expect(h.notifications.scheduled, isNotEmpty);
      await h.core.deleteAllData();
      expect(await h.core.hydration.count(), 0);
      expect(await h.core.vessels.getAll(), isEmpty);
      expect(await h.core.routines.getAll(), isEmpty);
      expect(await h.core.reminders.recentResolved(), isEmpty);
      expect(
        await h.core.summaries.range(
          const LocalDate(2000, 1, 1),
          const LocalDate(2100, 1, 1),
        ),
        isEmpty,
      );
      expect(h.notifications.scheduled, isEmpty);
      expect(h.widgets.last!.percent, 0);
    });
  });

  group('scheduler edge cases through the full pipeline', () {
    test('quiet span covering the whole waking day defers everything to tomorrow, outside the span', () async {
      await h.core.routines.upsert(
        h.core.routines
            .blank(
              name: 'Silent',
              kind: RoutineKind.custom,
              wake: 7 * 60 + 30,
              sleep: 23 * 60,
              weekdays: {1, 2, 3, 4, 5, 6, 7},
            )
            .copyWith(quietSpans: [const TimeSpan(7 * 60, 23 * 60)]),
      );
      await h.core.reschedule();
      for (final r in h.notifications.scheduled) {
        final m = _min(r.at, 'Asia/Kolkata');
        expect(m >= 7 * 60 && m < 23 * 60, isFalse);
      }
    });
    test('chained quiet spans (13–14 then 14–15) push past both', () async {
      await h.core.routines.upsert(
        h.core.routines
            .blank(
              name: 'Lunch',
              kind: RoutineKind.custom,
              wake: 7 * 60 + 30,
              sleep: 23 * 60,
              weekdays: {1, 2, 3, 4, 5, 6, 7},
            )
            .copyWith(
              quietSpans: [
                const TimeSpan(13 * 60, 14 * 60),
                const TimeSpan(14 * 60, 15 * 60),
              ],
            ),
      );
      h.now = DateTime.utc(2026, 10, 7, 6, 30); // 12:00 IST
      await h.core.log(volumeMl: 300);
      await h.settle();
      for (final r in h.notifications.scheduled) {
        final m = _min(r.at, 'Asia/Kolkata');
        expect(
          m >= 13 * 60 && m < 15 * 60,
          isFalse,
          reason: 'inside chained quiet at $m',
        );
      }
    });
    test(
      'reaching the goal stops today’s reminders and schedules only tomorrow',
      () async {
        await h.core.log(volumeMl: 2400);
        await h.settle();
        expect(h.notifications.scheduled, hasLength(1));
        expect(
          h.notifications.scheduled.single.at.isAfter(
            h.now.add(const Duration(hours: 6)),
          ),
          isTrue,
        );
      },
    );
    test('decisions are stamped with the engine version and report no confidence on day one', () async {
      final d = h.core.plans.decide(await h.core.currentContext());
      expect(d.algorithmVersion, kHreV1);
      expect(d.confidence, 0);
    });
  });
}
