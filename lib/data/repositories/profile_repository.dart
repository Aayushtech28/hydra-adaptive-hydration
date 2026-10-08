import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/units/volume_unit.dart';
import '../../core/util/validation.dart';
import '../../domain/models/entities.dart';
import '../../domain/models/enums.dart';
import '../database/app_database.dart';
import 'json_codec.dart';

class ProfileRepository {
  ProfileRepository(this._db);
  final AppDatabase _db;

  static const int _id = 1;

  Stream<UserProfile?> watch() =>
      (_db.select(_db.userProfileRows)..where((t) => t.id.equals(_id)))
          .watchSingleOrNull()
          .map((r) => r == null ? null : _map(r));

  Future<UserProfile?> get() async {
    final r = await (_db.select(
      _db.userProfileRows,
    )..where((t) => t.id.equals(_id))).getSingleOrNull();
    return r == null ? null : _map(r);
  }

  /// Creates the profile row on first launch.
  Future<UserProfile> ensure({
    required DateTime now,
    required String timezone,
    String? locale,
  }) async {
    final existing = await get();
    if (existing != null) return existing;
    final fresh = UserProfile(
      createdAt: now,
      locale: locale,
      timezone: timezone,
      unit: VolumeUnit.ml,
      dailyTargetMl: VolumeLimits.starterTargetMl,
      targetIsUserChosen: false,
      wakeMinute: 7 * 60 + 30,
      sleepMinute: 23 * 60,
      mode: ReminderMode.balanced,
      tone: NotificationTone.auto,
      weekendDifferent: false,
      weekendWakeMinute: 8 * 60 + 30,
      weekendSleepMinute: 23 * 60 + 30,
      quickAddsMl: const [250, 350, 500],
      onboardingComplete: false,
      remindersEnabled: true,
      theme: ThemeChoice.system,
      activeRoutineId: null,
      environmentHot: false,
    );
    await save(fresh);
    return fresh;
  }

  Future<void> save(UserProfile p) async {
    if (p.dailyTargetMl < VolumeLimits.minTargetMl ||
        p.dailyTargetMl > VolumeLimits.maxTargetMl) {
      throw const ValidationException(ValidationCode.targetInvalid);
    }
    for (final m in [
      p.wakeMinute,
      p.sleepMinute,
      p.weekendWakeMinute,
      p.weekendSleepMinute,
    ]) {
      if (m < 0 || m > 1439)
        throw const ValidationException(ValidationCode.timeInvalid);
    }
    final qa = p.quickAddsMl
        .where(
          (v) => v >= VolumeLimits.minEntryMl && v <= VolumeLimits.maxEntryMl,
        )
        .toList();
    await _db
        .into(_db.userProfileRows)
        .insertOnConflictUpdate(
          UserProfileRowsCompanion(
            id: const Value(_id),
            createdAt: Value(p.createdAt.millisecondsSinceEpoch),
            locale: Value(p.locale),
            timezone: Value(p.timezone),
            unit: Value(p.unit.storageKey),
            dailyTargetMl: Value(p.dailyTargetMl),
            targetIsUserChosen: Value(p.targetIsUserChosen),
            wakeMinute: Value(p.wakeMinute),
            sleepMinute: Value(p.sleepMinute),
            mode: Value(p.mode.name),
            tone: Value(p.tone.name),
            weekendDifferent: Value(p.weekendDifferent),
            weekendWakeMinute: Value(p.weekendWakeMinute),
            weekendSleepMinute: Value(p.weekendSleepMinute),
            quickAddsJson: Value(
              jsonEncode(qa.isEmpty ? const [250, 350, 500] : qa),
            ),
            onboardingComplete: Value(p.onboardingComplete),
            remindersEnabled: Value(p.remindersEnabled),
            theme: Value(p.theme.name),
            activeRoutineId: Value(p.activeRoutineId),
            environmentHot: Value(p.environmentHot),
          ),
        );
  }

  UserProfile _map(UserProfileRow r) {
    final qa = decodeIntList(r.quickAddsJson);
    return UserProfile(
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true),
      locale: r.locale,
      timezone: r.timezone,
      unit: VolumeUnit.fromStorage(r.unit),
      dailyTargetMl: r.dailyTargetMl,
      targetIsUserChosen: r.targetIsUserChosen,
      wakeMinute: r.wakeMinute,
      sleepMinute: r.sleepMinute,
      mode: ReminderMode.parse(r.mode),
      tone: NotificationTone.parse(r.tone),
      weekendDifferent: r.weekendDifferent,
      weekendWakeMinute: r.weekendWakeMinute,
      weekendSleepMinute: r.weekendSleepMinute,
      quickAddsMl: qa.isEmpty ? const [250, 350, 500] : qa,
      onboardingComplete: r.onboardingComplete,
      remindersEnabled: r.remindersEnabled,
      theme: ThemeChoice.values.firstWhere(
        (t) => t.name == r.theme,
        orElse: () => ThemeChoice.system,
      ),
      activeRoutineId: r.activeRoutineId,
      environmentHot: r.environmentHot,
    );
  }
}
