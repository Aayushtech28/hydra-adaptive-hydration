import 'package:drift/drift.dart';

import '../../core/units/volume_unit.dart';
import '../../core/util/ids.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../database/app_database.dart';

class VesselRepository {
  VesselRepository(this._db);
  final AppDatabase _db;

  /// Free tier cap (Pro is unlimited). Enforced by [upsert] when [limit] given.
  static const int freeLimit = 5;

  Stream<List<Vessel>> watchAll() => (_db.select(_db.vessels)
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .watch()
      .map((l) => l.map(_map).toList());

  Future<List<Vessel>> getAll() async => (await (_db.select(_db.vessels)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
          .get())
      .map(_map)
      .toList();

  Future<Vessel?> getById(String id) async {
    final r = await (_db.select(_db.vessels)..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Creates or updates a vessel. [limit] (e.g. [freeLimit] for free users)
  /// only applies when creating.
  Future<Vessel> upsert({
    String? id,
    required String name,
    required int volumeMl,
    String icon = 'glass',
    bool isFavorite = false,
    int? limit,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 40) {
      throw const ValidationException(ValidationCode.nameInvalid);
    }
    if (volumeMl < VolumeLimits.minEntryMl || volumeMl > VolumeLimits.maxEntryMl) {
      throw const ValidationException(ValidationCode.volumeInvalid);
    }
    return _db.transaction(() async {
      final existing = id == null ? null : await getById(id);
      if (existing == null && limit != null) {
        final n = await (_db.selectOnly(_db.vessels)..addColumns([_db.vessels.id.count()]))
            .map((r) => r.read(_db.vessels.id.count()) ?? 0)
            .getSingle();
        if (n >= limit) throw const ValidationException(ValidationCode.limitReached);
      }
      final order = existing?.sortOrder ?? await _nextOrder();
      final v = Vessel(
        id: id ?? newId(),
        name: trimmed,
        volumeMl: volumeMl,
        icon: icon,
        isFavorite: isFavorite,
        sortOrder: order,
      );
      await _db.into(_db.vessels).insertOnConflictUpdate(_companion(v));
      return v;
    });
  }

  Future<void> delete(String id) => _db.transaction(() async {
        await (_db.delete(_db.vessels)..where((t) => t.id.equals(id))).go();
        // History keeps its volume; only the vessel link is cleared.
        await (_db.update(_db.hydrationEntries)..where((t) => t.vesselId.equals(id)))
            .write(const HydrationEntriesCompanion(vesselId: Value(null)));
      });

  Future<void> reorder(List<String> orderedIds) => _db.transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.vessels)..where((t) => t.id.equals(orderedIds[i])))
              .write(VesselsCompanion(sortOrder: Value(i)));
        }
      });

  Future<void> setFavorite(String id, bool fav) =>
      (_db.update(_db.vessels)..where((t) => t.id.equals(id)))
          .write(VesselsCompanion(isFavorite: Value(fav)));

  /// Seeds the example vessels on first launch (only when none exist).
  Future<void> seedDefaultsIfEmpty(List<({String name, int ml, String icon})> defaults) async {
    final existing = await getAll();
    if (existing.isNotEmpty) return;
    for (final d in defaults) {
      await upsert(name: d.name, volumeMl: d.ml, icon: d.icon);
    }
  }

  Future<int> _nextOrder() async {
    final m = _db.vessels.sortOrder.max();
    final r = await (_db.selectOnly(_db.vessels)..addColumns([m])).getSingle();
    return (r.read(m) ?? -1) + 1;
  }

  VesselsCompanion _companion(Vessel v) => VesselsCompanion(
        id: Value(v.id),
        name: Value(v.name),
        volumeMl: Value(v.volumeMl),
        icon: Value(v.icon),
        isFavorite: Value(v.isFavorite),
        sortOrder: Value(v.sortOrder),
      );

  Vessel _map(VesselRow r) => Vessel(
        id: r.id,
        name: r.name,
        volumeMl: r.volumeMl,
        icon: r.icon,
        isFavorite: r.isFavorite,
        sortOrder: r.sortOrder,
      );
}
