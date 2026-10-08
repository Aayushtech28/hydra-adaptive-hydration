import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Bump together with a migration step in [AppDatabase.migration].
const int kSchemaVersion = 1;

@DriftDatabase(
  tables: [
    UserProfileRows,
    HydrationEntries,
    Vessels,
    Routines,
    ReminderEvents,
    DailySummaries,
    Achievements,
    KvSettings,
    ImportTombstones,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database in a background isolate.
  static Future<AppDatabase> openOnDevice() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'hydra.sqlite'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createCustomIndexes();
    },
    onUpgrade: (m, from, to) async {
      // Add a `if (from < N) {...}` block per schema bump. Never edit
      // history; migrations must be additive and data-preserving.
      await _createCustomIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  Future<void> _createCustomIndexes() async {
    // A given external record may exist at most once per source.
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS uq_entries_external '
      'ON hydration_entries (source, external_record_id) '
      'WHERE external_record_id IS NOT NULL',
    );
  }

  /// Wipes every user table inside one transaction ("Delete all my data").
  Future<void> deleteEverything() => transaction(() async {
    for (final t in allTables) {
      await delete(t).go();
    }
  });
}
