import 'package:drift/drift.dart';

import '../../core/time/hydra_time.dart';
import '../../core/time/local_date.dart';
import '../../core/units/volume_unit.dart';
import '../../core/util/ids.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../database/app_database.dart';

class HydrationRepository {
  HydrationRepository(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;

  /// Validates, then persists. Never accepts a non-positive/absurd volume.
  /// For external sources a duplicate (source, externalRecordId) returns the
  /// existing row instead of creating a second one (no double counting).
  Future<HydrationEntry> add({
    required int volumeMl,
    required DateTime at,
    required String timezone,
    EntrySource source = EntrySource.manual,
    String? vesselId,
    String? externalRecordId,
    BeverageType beverage = BeverageType.water,
    String? id,
  }) async {
    _validateVolume(volumeMl);
    final loc = locationFor(timezone);
    final nowMs = _now().toUtc().millisecondsSinceEpoch;
    final entry = HydrationEntry(
      id: id ?? newId(),
      timestampUtc: at.toUtc(),
      timezone: timezone,
      localDate: logicalDateOf(at, loc),
      volumeMl: volumeMl,
      source: source,
      createdAt: DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true),
      beverage: beverage,
      vesselId: vesselId,
      externalRecordId: externalRecordId,
    );
    return _db.transaction(() async {
      if (externalRecordId != null) {
        final dup = await (_db.select(_db.hydrationEntries)
              ..where((t) =>
                  t.source.equals(source.name) &
                  t.externalRecordId.equals(externalRecordId)))
            .getSingleOrNull();
        if (dup != null) return _map(dup);
      }
      await _db.into(_db.hydrationEntries).insert(_toCompanion(entry));
      return entry;
    });
  }

  /// Restores a previously deleted entry (undo of delete).
  Future<void> restore(HydrationEntry e) async {
    _validateVolume(e.volumeMl);
    await _db.transaction(() async {
      if (e.externalRecordId != null) {
        await (_db.delete(_db.importTombstones)
              ..where((t) =>
                  t.source.equals(e.source.name) &
                  t.externalId.equals(e.externalRecordId!)))
            .go();
      }
      await _db.into(_db.hydrationEntries).insertOnConflictUpdate(_toCompanion(e));
    });
  }

  Future<HydrationEntry> update(
    String id, {
    int? volumeMl,
    DateTime? at,
    String? timezone,
    String? vesselId,
    bool clearVessel = false,
  }) async {
    final row = await (_db.select(_db.hydrationEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw const ValidationException(ValidationCode.notFound);
    if (volumeMl != null) _validateVolume(volumeMl);
    final cur = _map(row);
    final tz = timezone ?? (at != null ? cur.timezone : cur.timezone);
    final newAt = at ?? cur.timestampUtc;
    final updated = cur.copyWith(
      volumeMl: volumeMl,
      timestampUtc: newAt.toUtc(),
      timezone: tz,
      localDate: at != null ? logicalDateOf(newAt, locationFor(tz)) : null,
      vesselId: vesselId,
      clearVessel: clearVessel,
      updatedAt: _now().toUtc(),
    );
    await _db.into(_db.hydrationEntries).insertOnConflictUpdate(_toCompanion(updated));
    return updated;
  }

  /// Deletes an entry. External-sourced entries leave a tombstone so a later
  /// health sync does not re-import them.
  Future<HydrationEntry?> delete(String id) => _db.transaction(() async {
        final row = await (_db.select(_db.hydrationEntries)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (row == null) return null;
        final e = _map(row);
        if (e.externalRecordId != null && e.source.isExternal) {
          await _db.into(_db.importTombstones).insertOnConflictUpdate(
                ImportTombstonesCompanion.insert(
                  source: e.source.name,
                  externalId: e.externalRecordId!,
                  createdAt: _now().toUtc().millisecondsSinceEpoch,
                ),
              );
        }
        await (_db.delete(_db.hydrationEntries)..where((t) => t.id.equals(id))).go();
        return e;
      });

  Future<HydrationEntry?> getById(String id) async {
    final r = await (_db.select(_db.hydrationEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  Stream<List<HydrationEntry>> watchDay(LocalDate d) => (_db.select(_db.hydrationEntries)
        ..where((t) => t.localDate.equals(d.toIso()))
        ..orderBy([(t) => OrderingTerm.asc(t.timestampUtc)]))
      .watch()
      .map((l) => l.map(_map).toList());

  Future<List<HydrationEntry>> entriesForDay(LocalDate d) async =>
      (await (_db.select(_db.hydrationEntries)
                ..where((t) => t.localDate.equals(d.toIso()))
                ..orderBy([(t) => OrderingTerm.asc(t.timestampUtc)]))
              .get())
          .map(_map)
          .toList();

  Future<List<HydrationEntry>> entriesBetween(LocalDate from, LocalDate to) async =>
      (await (_db.select(_db.hydrationEntries)
                ..where((t) =>
                    t.localDate.isBiggerOrEqualValue(from.toIso()) &
                    t.localDate.isSmallerOrEqualValue(to.toIso()))
                ..orderBy([(t) => OrderingTerm.asc(t.timestampUtc)]))
              .get())
          .map(_map)
          .toList();

  Future<List<HydrationEntry>> all() async => (await (_db.select(_db.hydrationEntries)
            ..orderBy([(t) => OrderingTerm.asc(t.timestampUtc)]))
          .get())
      .map(_map)
      .toList();

  Future<int> totalForDay(LocalDate d) async {
    final sum = _db.hydrationEntries.volumeMl.sum();
    final q = _db.selectOnly(_db.hydrationEntries)
      ..addColumns([sum])
      ..where(_db.hydrationEntries.localDate.equals(d.toIso()));
    return (await q.getSingle()).read(sum) ?? 0;
  }

  Stream<int> watchTotalForDay(LocalDate d) {
    final sum = _db.hydrationEntries.volumeMl.sum();
    final q = _db.selectOnly(_db.hydrationEntries)
      ..addColumns([sum])
      ..where(_db.hydrationEntries.localDate.equals(d.toIso()));
    return q.watchSingle().map((r) => r.read(sum) ?? 0);
  }

  Future<LocalDate?> firstEntryDate() async {
    final m = _db.hydrationEntries.localDate.min();
    final q = _db.selectOnly(_db.hydrationEntries)..addColumns([m]);
    return LocalDate.tryParse((await q.getSingle()).read(m));
  }

  Future<HydrationEntry?> lastEntry() async {
    final r = await (_db.select(_db.hydrationEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.timestampUtc)])
          ..limit(1))
        .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Most-used volumes over the recent past; basis for opt-in smart quick-add.
  Future<List<({int ml, int uses})>> frequentVolumes({
    int days = 60,
    int minUses = 3,
    int limit = 3,
  }) async {
    final cutoff = _now().toUtc().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final cnt = _db.hydrationEntries.id.count();
    final q = _db.selectOnly(_db.hydrationEntries)
      ..addColumns([_db.hydrationEntries.volumeMl, cnt])
      ..where(_db.hydrationEntries.timestampUtc.isBiggerOrEqualValue(cutoff))
      ..groupBy([_db.hydrationEntries.volumeMl], having: cnt.isBiggerOrEqualValue(minUses))
      ..orderBy([OrderingTerm.desc(cnt)])
      ..limit(limit);
    final rows = await q.get();
    return [
      for (final r in rows)
        (ml: r.read(_db.hydrationEntries.volumeMl)!, uses: r.read(cnt)!),
    ];
  }

  Future<Map<String, int>> vesselUseCounts({int days = 30}) async {
    final cutoff = _now().toUtc().subtract(Duration(days: days)).millisecondsSinceEpoch;
    final cnt = _db.hydrationEntries.id.count();
    final q = _db.selectOnly(_db.hydrationEntries)
      ..addColumns([_db.hydrationEntries.vesselId, cnt])
      ..where(_db.hydrationEntries.vesselId.isNotNull() &
          _db.hydrationEntries.timestampUtc.isBiggerOrEqualValue(cutoff))
      ..groupBy([_db.hydrationEntries.vesselId]);
    return {
      for (final r in await q.get())
        r.read(_db.hydrationEntries.vesselId)!: r.read(cnt)!,
    };
  }

  // ---- external (health) support ----------------------------------------

  Future<Set<String>> externalIds(EntrySource source) async {
    final rows = await (_db.select(_db.hydrationEntries)
          ..where((t) => t.source.equals(source.name) & t.externalRecordId.isNotNull()))
        .get();
    return {for (final r in rows) r.externalRecordId!};
  }

  Future<Set<String>> tombstones(EntrySource source) async {
    final rows = await (_db.select(_db.importTombstones)
          ..where((t) => t.source.equals(source.name)))
        .get();
    return {for (final r in rows) r.externalId};
  }

  Future<void> linkExternal(String entryId, String externalId, EntrySource platform) async {
    // Unique index guards against two entries claiming one external record.
    final existing = await (_db.select(_db.hydrationEntries)
          ..where((t) => t.externalRecordId.equals(externalId)))
        .get();
    if (existing.any((e) => e.id != entryId && e.source == platform.name)) return;
    await (_db.update(_db.hydrationEntries)..where((t) => t.id.equals(entryId)))
        .write(HydrationEntriesCompanion(externalRecordId: Value(externalId)));
  }

  /// Entries that should be exported to a health platform (HYDRA-originated,
  /// not yet linked).
  Future<List<HydrationEntry>> unexported({DateTime? since}) async {
    final q = _db.select(_db.hydrationEntries)
      ..where((t) =>
          t.externalRecordId.isNull() &
          t.source.isIn([
            EntrySource.manual.name,
            EntrySource.notificationAction.name,
            EntrySource.widget.name,
          ]));
    if (since != null) {
      q.where((t) => t.timestampUtc.isBiggerOrEqualValue(since.toUtc().millisecondsSinceEpoch));
    }
    return (await q.get()).map(_map).toList();
  }

  // ---- internals ---------------------------------------------------------

  void _validateVolume(int ml) {
    if (ml < VolumeLimits.minEntryMl || ml > VolumeLimits.maxEntryMl) {
      throw ValidationException(ValidationCode.volumeInvalid, '$ml');
    }
  }

  HydrationEntriesCompanion _toCompanion(HydrationEntry e) => HydrationEntriesCompanion(
        id: Value(e.id),
        timestampUtc: Value(e.timestampUtc.millisecondsSinceEpoch),
        timezone: Value(e.timezone),
        localDate: Value(e.localDate.toIso()),
        volumeMl: Value(e.volumeMl),
        beverage: Value(e.beverage.name),
        vesselId: Value(e.vesselId),
        source: Value(e.source.name),
        externalRecordId: Value(e.externalRecordId),
        createdAt: Value(e.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(e.updatedAt.millisecondsSinceEpoch),
      );

  HydrationEntry _map(HydrationEntryRow r) => HydrationEntry(
        id: r.id,
        timestampUtc: DateTime.fromMillisecondsSinceEpoch(r.timestampUtc, isUtc: true),
        timezone: r.timezone,
        localDate: LocalDate.tryParse(r.localDate) ?? const LocalDate(1970, 1, 1),
        volumeMl: r.volumeMl,
        source: EntrySource.parse(r.source),
        externalRecordId: r.externalRecordId,
        vesselId: r.vesselId,
        beverage: BeverageType.values.firstWhere(
          (b) => b.name == r.beverage,
          orElse: () => BeverageType.water,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(r.updatedAt, isUtc: true),
      );
}
