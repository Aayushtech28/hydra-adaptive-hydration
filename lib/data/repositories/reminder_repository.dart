import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../database/app_database.dart';

class ReminderRepository {
  ReminderRepository(this._db);
  final AppDatabase _db;

  Future<void> insertScheduled(List<ReminderEvent> events) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_db.reminderEvents, [
      for (final e in events) _companion(e),
    ]);
  });

  /// Pending events whose time has passed.
  Future<List<ReminderEvent>> pendingBefore(DateTime now) async =>
      (await (_db.select(_db.reminderEvents)
                ..where(
                  (t) =>
                      t.outcome.equals(ReminderOutcome.pending.name) &
                      t.scheduledAt.isSmallerOrEqualValue(
                        now.toUtc().millisecondsSinceEpoch,
                      ),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
              .get())
          .map(_map)
          .toList();

  /// Pending events still in the future (the currently scheduled chain).
  Future<List<ReminderEvent>> pendingAfter(DateTime now) async =>
      (await (_db.select(_db.reminderEvents)
                ..where(
                  (t) =>
                      t.outcome.equals(ReminderOutcome.pending.name) &
                      t.scheduledAt.isBiggerThanValue(
                        now.toUtc().millisecondsSinceEpoch,
                      ),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
              .get())
          .map(_map)
          .toList();

  /// Marks all future pending events cancelled (a new chain replaces them).
  Future<void> cancelFuturePending(DateTime now) =>
      (_db.update(_db.reminderEvents)..where(
            (t) =>
                t.outcome.equals(ReminderOutcome.pending.name) &
                t.scheduledAt.isBiggerThanValue(
                  now.toUtc().millisecondsSinceEpoch,
                ),
          ))
          .write(const ReminderEventsCompanion(outcome: Value('cancelled')));

  Future<void> resolve(String id, ReminderOutcome outcome, DateTime at) =>
      (_db.update(_db.reminderEvents)..where((t) => t.id.equals(id))).write(
        ReminderEventsCompanion(
          outcome: Value(outcome.name),
          resolvedAt: Value(at.toUtc().millisecondsSinceEpoch),
        ),
      );

  Future<ReminderEvent?> getById(String id) async {
    final r = await (_db.select(
      _db.reminderEvents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// The most recent reminder whose time has passed (any outcome but
  /// cancelled), used as an anchor for spacing.
  Future<ReminderEvent?> lastFired(DateTime now) async {
    final r =
        await (_db.select(_db.reminderEvents)
              ..where(
                (t) =>
                    t.outcome.equals('cancelled').not() &
                    t.scheduledAt.isSmallerOrEqualValue(
                      now.toUtc().millisecondsSinceEpoch,
                    ),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)])
              ..limit(1))
            .getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Resolved outcomes, oldest → newest, for fatigue computation.
  Future<List<ReminderEvent>> recentResolved({int limit = 40}) async {
    final rows =
        await (_db.select(_db.reminderEvents)
              ..where(
                (t) =>
                    t.outcome.equals('pending').not() &
                    t.outcome.equals('cancelled').not(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.scheduledAt)])
              ..limit(limit))
            .get();
    return rows.reversed.map(_map).toList();
  }

  Future<List<ReminderEvent>> forDate(LocalDate d) async =>
      (await (_db.select(_db.reminderEvents)
                ..where((t) => t.localDate.equals(d.toIso()))
                ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
              .get())
          .map(_map)
          .toList();

  Future<List<ReminderEvent>> between(LocalDate from, LocalDate to) async =>
      (await (_db.select(_db.reminderEvents)
                ..where(
                  (t) =>
                      t.localDate.isBiggerOrEqualValue(from.toIso()) &
                      t.localDate.isSmallerOrEqualValue(to.toIso()),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
              .get())
          .map(_map)
          .toList();

  /// Drops events older than [days] (history is summarised in DailySummaries).
  Future<void> prune({required DateTime now, int days = 120}) =>
      (_db.delete(_db.reminderEvents)..where(
            (t) => t.scheduledAt.isSmallerThanValue(
              now.toUtc().subtract(Duration(days: days)).millisecondsSinceEpoch,
            ),
          ))
          .go();

  ReminderEventsCompanion _companion(ReminderEvent e) =>
      ReminderEventsCompanion(
        id: Value(e.id),
        scheduledAt: Value(e.scheduledAt.toUtc().millisecondsSinceEpoch),
        localDate: Value(e.localDate.toIso()),
        type: Value(e.type.name),
        outcome: Value(e.outcome.name),
        reason: Value(e.reason),
        algorithmVersion: Value(e.algorithmVersion),
        resolvedAt: Value(e.resolvedAt?.toUtc().millisecondsSinceEpoch),
      );

  ReminderEvent _map(ReminderEventRow r) => ReminderEvent(
    id: r.id,
    scheduledAt: DateTime.fromMillisecondsSinceEpoch(
      r.scheduledAt,
      isUtc: true,
    ),
    localDate: LocalDate.tryParse(r.localDate) ?? const LocalDate(1970, 1, 1),
    type: ReminderType.values.firstWhere(
      (t) => t.name == r.type,
      orElse: () => ReminderType.adaptive,
    ),
    outcome: ReminderOutcome.values.firstWhere(
      (o) => o.name == r.outcome,
      orElse: () => ReminderOutcome.pending,
    ),
    reason: r.reason,
    algorithmVersion: r.algorithmVersion,
    resolvedAt: r.resolvedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(r.resolvedAt!, isUtc: true),
  );
}
