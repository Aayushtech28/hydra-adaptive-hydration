// ignore_for_file: recursive_getters
// (Drift's `check(col.isBetween...)` idiom reads the column being defined.)
import 'package:drift/drift.dart';

/// Single-row profile table (id is always 1).
class UserProfileRows extends Table {
  IntColumn get id => integer()();
  IntColumn get createdAt => integer()();
  TextColumn get locale => text().nullable()();
  TextColumn get timezone => text()();
  TextColumn get unit => text().withDefault(const Constant('ml'))();
  IntColumn get dailyTargetMl =>
      integer().check(dailyTargetMl.isBetweenValues(500, 8000))();
  BoolColumn get targetIsUserChosen =>
      boolean().withDefault(const Constant(false))();
  IntColumn get wakeMinute => integer().check(wakeMinute.isBetweenValues(0, 1439))();
  IntColumn get sleepMinute => integer().check(sleepMinute.isBetweenValues(0, 1439))();
  TextColumn get mode => text().withDefault(const Constant('balanced'))();
  TextColumn get tone => text().withDefault(const Constant('auto'))();
  BoolColumn get weekendDifferent => boolean().withDefault(const Constant(false))();
  IntColumn get weekendWakeMinute => integer().withDefault(const Constant(480))();
  IntColumn get weekendSleepMinute => integer().withDefault(const Constant(1410))();
  TextColumn get quickAddsJson => text().withDefault(const Constant('[250,350,500]'))();
  BoolColumn get onboardingComplete => boolean().withDefault(const Constant(false))();
  BoolColumn get remindersEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  TextColumn get activeRoutineId => text().nullable()();
  BoolColumn get environmentHot => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'idx_entries_local_date', columns: {#localDate})
@TableIndex(name: 'idx_entries_timestamp', columns: {#timestampUtc})
@DataClassName('HydrationEntryRow')
class HydrationEntries extends Table {
  TextColumn get id => text()();

  /// Absolute instant, milliseconds since epoch (UTC).
  IntColumn get timestampUtc => integer()();
  TextColumn get timezone => text()();
  TextColumn get localDate => text().withLength(min: 10, max: 10)();
  IntColumn get volumeMl => integer().check(volumeMl.isBetweenValues(1, 5000))();
  TextColumn get beverage => text().withDefault(const Constant('water'))();
  TextColumn get vesselId => text().nullable()();
  TextColumn get source => text()();
  TextColumn get externalRecordId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('VesselRow')
class Vessels extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get volumeMl => integer().check(volumeMl.isBetweenValues(1, 5000))();
  TextColumn get icon => text().withDefault(const Constant('glass'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RoutineRow')
class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get kind => text()();
  TextColumn get weekdaysJson => text().withDefault(const Constant('[]'))();
  IntColumn get wakeMinute => integer().check(wakeMinute.isBetweenValues(0, 1439))();
  IntColumn get sleepMinute => integer().check(sleepMinute.isBetweenValues(0, 1439))();
  TextColumn get mode => text().withDefault(const Constant('balanced'))();
  TextColumn get quietJson => text().withDefault(const Constant('[]'))();
  TextColumn get workoutJson => text().withDefault(const Constant('[]'))();
  TextColumn get quickAddsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'idx_reminders_scheduled', columns: {#scheduledAt})
@TableIndex(name: 'idx_reminders_local_date', columns: {#localDate})
@DataClassName('ReminderEventRow')
class ReminderEvents extends Table {
  TextColumn get id => text()();
  IntColumn get scheduledAt => integer()();
  TextColumn get localDate => text()();
  TextColumn get type => text()();
  TextColumn get outcome => text().withDefault(const Constant('pending'))();
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get algorithmVersion => text()();
  IntColumn get resolvedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached per-day stats (JSON of DayStats) for fast history/insights.
@DataClassName('DailySummaryRow')
class DailySummaries extends Table {
  TextColumn get date => text()();
  TextColumn get statsJson => text()();
  IntColumn get version => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DataClassName('AchievementRow')
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get unlockedAt => integer()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Small key/value store for app state that is not worth a table
/// (pause state, snooze, ad frequency counters, cached entitlement...).
class KvSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Remembers externally-sourced records the user deleted so a later sync
/// does not resurrect them.
class ImportTombstones extends Table {
  TextColumn get source => text()();
  TextColumn get externalId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {source, externalId};
}
