import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/hydra_time.dart';
import '../../core/util/ids.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../database/app_database.dart';
import 'json_codec.dart';

class RoutineRepository {
  RoutineRepository(this._db);
  final AppDatabase _db;

  static const int freeLimit = 2;

  Stream<List<Routine>> watchAll() =>
      (_db.select(_db.routines)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((l) => l.map(_map).toList());

  Future<List<Routine>> getAll() async => (await (_db.select(
    _db.routines,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).get()).map(_map).toList();

  Future<Routine> upsert(Routine r, {int? limit}) async {
    final name = r.name.trim();
    if (name.isEmpty || name.length > 40) {
      throw const ValidationException(ValidationCode.nameInvalid);
    }
    if (validateWakeSleep(r.wakeMinute, r.sleepMinute) != null) {
      throw const ValidationException(ValidationCode.timeInvalid);
    }
    return _db.transaction(() async {
      final exists = await (_db.select(
        _db.routines,
      )..where((t) => t.id.equals(r.id))).getSingleOrNull();
      if (exists == null && limit != null) {
        final n =
            await (_db.selectOnly(_db.routines)
                  ..addColumns([_db.routines.id.count()]))
                .map((x) => x.read(_db.routines.id.count()) ?? 0)
                .getSingle();
        if (n >= limit)
          throw const ValidationException(ValidationCode.limitReached);
      }
      final saved = r.copyWith(name: name);
      await _db.into(_db.routines).insertOnConflictUpdate(_companion(saved));
      return saved;
    });
  }

  Routine blank({
    required String name,
    required RoutineKind kind,
    required int wake,
    required int sleep,
    Set<int> weekdays = const {},
    ReminderMode mode = ReminderMode.balanced,
  }) => Routine(
    id: newId(),
    name: name,
    kind: kind,
    weekdays: weekdays,
    wakeMinute: wake,
    sleepMinute: sleep,
    mode: mode,
    quietSpans: const [],
    workoutSpans: const [],
    quickAddsMl: const [],
    enabled: true,
  );

  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.routines)..where((t) => t.id.equals(id))).go();
      await (_db.update(_db.userProfileRows)
            ..where((t) => t.activeRoutineId.equals(id)))
          .write(const UserProfileRowsCompanion(activeRoutineId: Value(null)));
    });
  }

  RoutinesCompanion _companion(Routine r) => RoutinesCompanion(
    id: Value(r.id),
    name: Value(r.name),
    kind: Value(r.kind.name),
    weekdaysJson: Value(jsonEncode((r.weekdays.toList()..sort()))),
    wakeMinute: Value(r.wakeMinute),
    sleepMinute: Value(r.sleepMinute),
    mode: Value(r.mode.name),
    quietJson: Value(jsonEncode(r.quietSpans.map((s) => s.toJson()).toList())),
    workoutJson: Value(
      jsonEncode(r.workoutSpans.map((s) => s.toJson()).toList()),
    ),
    quickAddsJson: Value(jsonEncode(r.quickAddsMl)),
    enabled: Value(r.enabled),
  );

  Routine _map(RoutineRow r) => Routine(
    id: r.id,
    name: r.name,
    kind: RoutineKind.values.firstWhere(
      (k) => k.name == r.kind,
      orElse: () => RoutineKind.custom,
    ),
    weekdays: decodeIntList(r.weekdaysJson)
        .where((d) => d >= 1 && d <= 7)
        .toSet(),
    wakeMinute: r.wakeMinute,
    sleepMinute: r.sleepMinute,
    mode: ReminderMode.parse(r.mode),
    quietSpans: decodeMapList(r.quietJson)
        .map(TimeSpan.fromJson)
        .whereType<TimeSpan>()
        .toList(),
    workoutSpans: decodeMapList(r.workoutJson)
        .map(TimeSpan.fromJson)
        .whereType<TimeSpan>()
        .toList(),
    quickAddsMl: decodeIntList(r.quickAddsJson),
    enabled: r.enabled,
  );
}
