import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/time/local_date.dart';
import 'package:hydra/core/units/volume_unit.dart';
import 'package:hydra/domain/models/entities.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:hydra/domain/models/routine_resolver.dart';
import 'package:hydra/domain/sync/health_reconciler.dart';

final _t = DateTime.utc(2026, 10, 7, 8, 0);

HydrationEntry entry(String id, int ml, DateTime at,
        {EntrySource source = EntrySource.manual, String? ext}) =>
    HydrationEntry(
      id: id,
      timestampUtc: at,
      timezone: 'UTC',
      localDate: const LocalDate(2026, 10, 7),
      volumeMl: ml,
      source: source,
      externalRecordId: ext,
      createdAt: at,
      updatedAt: at,
    );

SyncPlan plan(List<HydrationEntry> local, List<ExternalHydration> ext,
        {Set<String> tomb = const {}, SyncDirection dir = SyncDirection.twoWay}) =>
    HealthReconciler.plan(
      platform: EntrySource.healthkit,
      local: local,
      external: ext,
      tombstones: tomb,
      direction: dir,
      windowStart: _t.subtract(const Duration(days: 1)),
      windowEnd: _t.add(const Duration(days: 1)),
    );

void main() {
  group('HealthReconciler', () {
    test('new external record is imported', () {
      final p = plan([], [ExternalHydration(id: 'a', at: _t, ml: 300)]);
      expect(p.toImport.single.id, 'a');
    });

    test('HYDRA entry + same external record: linked, NOT double counted', () {
      final local = [entry('l1', 500, _t)];
      final p = plan(local, [ExternalHydration(id: 'hk1', at: _t.add(const Duration(seconds: 30)), ml: 500)]);
      expect(p.toImport, isEmpty);
      expect(p.toLink, {'l1': 'hk1'});
      expect(p.toExport, isEmpty);
    });

    test('already-linked record is skipped; sync is idempotent', () {
      final local = [entry('l1', 500, _t, ext: 'hk1')];
      final ext = [ExternalHydration(id: 'hk1', at: _t, ml: 500)];
      final p1 = plan(local, ext);
      expect(p1.toImport, isEmpty);
      expect(p1.toLink, isEmpty);
      expect(p1.toExport, isEmpty);
      expect(p1.duplicatesSkipped, 1);
    });

    test('same volume but different time is a different drink', () {
      final p = plan([entry('l1', 500, _t)],
          [ExternalHydration(id: 'x', at: _t.add(const Duration(hours: 2)), ml: 500)]);
      expect(p.toImport.length, 1);
    });

    test('one local entry cannot be claimed by two external records', () {
      final p = plan([entry('l1', 250, _t)], [
        ExternalHydration(id: 'a', at: _t, ml: 250),
        ExternalHydration(id: 'b', at: _t, ml: 250),
      ]);
      expect(p.toLink.length, 1);
      expect(p.toImport.length, 1);
    });

    test('tombstoned records are never resurrected', () {
      final p = plan([], [ExternalHydration(id: 'gone', at: _t, ml: 200)], tomb: {'gone'});
      expect(p.toImport, isEmpty);
    });

    test('records written by HYDRA but unknown locally are not re-imported', () {
      final p = plan([], [ExternalHydration(id: 'mine', at: _t, ml: 200, writtenByHydra: true)]);
      expect(p.toImport, isEmpty);
    });

    test('unlinked manual entries are exported; imported ones never are', () {
      final p = plan([
        entry('m', 250, _t),
        entry('i', 250, _t, source: EntrySource.healthkit, ext: 'hk9'),
      ], [ExternalHydration(id: 'hk9', at: _t, ml: 250)]);
      expect(p.toExport.map((e) => e.id), ['m']);
    });

    test('direction is respected', () {
      final local = [entry('m', 250, _t)];
      final ext = [ExternalHydration(id: 'a', at: _t.add(const Duration(hours: 3)), ml: 300)];
      expect(plan(local, ext, dir: SyncDirection.importOnly).toExport, isEmpty);
      expect(plan(local, ext, dir: SyncDirection.exportOnly).toImport, isEmpty);
    });

    test('external deletion removes the imported local copy only', () {
      final local = [
        entry('i', 250, _t, source: EntrySource.healthkit, ext: 'hk9'),
        entry('m', 250, _t, ext: 'hk-mine'),
      ];
      final p = plan(local, []);
      expect(p.toRemoveLocal, ['i']);
    });

    test('permission failure style empty external list never deletes manual data', () {
      final local = [entry('m', 250, _t)];
      final p = plan(local, []);
      expect(p.toRemoveLocal, isEmpty);
    });
  });

  group('RoutineResolver', () {
    final profile = UserProfile(
      createdAt: _t,
      locale: null,
      timezone: 'UTC',
      unit: VolumeUnit.ml,
      dailyTargetMl: 2400,
      targetIsUserChosen: false,
      wakeMinute: 420,
      sleepMinute: 1380,
      mode: ReminderMode.balanced,
      tone: NotificationTone.auto,
      weekendDifferent: true,
      weekendWakeMinute: 540,
      weekendSleepMinute: 60,
      quickAddsMl: const [250],
      onboardingComplete: true,
      remindersEnabled: true,
      theme: ThemeChoice.system,
      activeRoutineId: null,
      environmentHot: false,
    );
    Routine routine(String id, Set<int> days, {int wake = 360, bool enabled = true, RoutineKind kind = RoutineKind.work}) =>
        Routine(
          id: id, name: id, kind: kind, weekdays: days, wakeMinute: wake, sleepMinute: 1320,
          mode: ReminderMode.focus, quietSpans: const [], workoutSpans: const [],
          quickAddsMl: const [], enabled: enabled,
        );
    const wed = LocalDate(2026, 10, 7); // Wednesday
    const sat = LocalDate(2026, 10, 10);

    test('falls back to profile, weekend variant on weekends', () {
      final wd = RoutineResolver.resolve(profile: profile, routines: [], date: wed);
      expect(wd.wakeMinute, 420);
      expect(wd.routineId, isNull);
      final we = RoutineResolver.resolve(profile: profile, routines: [], date: sat);
      expect(we.wakeMinute, 540);
      expect(we.sleepMinute, 60);
    });

    test('matches routine by weekday; disabled ignored; most specific wins', () {
      final r = RoutineResolver.resolve(profile: profile, date: wed, routines: [
        routine('all', {1, 2, 3, 4, 5, 6, 7}, wake: 300),
        routine('wed', {3}, wake: 330),
        routine('off', {3}, wake: 200, enabled: false),
      ]);
      expect(r.routineId, 'wed');
      expect(r.mode, ReminderMode.focus);
      expect(r.quickAddsMl, [250]); // inherits profile quick-adds
    });

    test('manual override beats weekday match, ignored when disabled', () {
      final routines = [routine('work', {3}), routine('travel', {}, kind: RoutineKind.travel)];
      final on = RoutineResolver.resolve(
          profile: profile.copyWith(activeRoutineId: 'travel'), routines: routines, date: wed);
      expect(on.routineId, 'travel');
      expect(on.viaOverride, isTrue);
      final off = RoutineResolver.resolve(
          profile: profile.copyWith(activeRoutineId: 'gone'), routines: routines, date: wed);
      expect(off.routineId, 'work');
    });
  });
}
