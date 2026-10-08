import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time/local_date.dart';
import '../../domain/insights/day_stats.dart';
import '../database/app_database.dart';

/// Version of the DayStats cache format; bump to invalidate caches.
const int kSummaryVersion = 1;

class SummaryRepository {
  SummaryRepository(this._db);
  final AppDatabase _db;

  Future<void> put(DayStats s, {required DateTime now}) => _db
      .into(_db.dailySummaries)
      .insertOnConflictUpdate(
        DailySummariesCompanion(
          date: Value(s.date.toIso()),
          statsJson: Value(jsonEncode(s.toJson())),
          version: const Value(kSummaryVersion),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
        ),
      );

  Future<DayStats?> get(LocalDate d) async {
    final r =
        await (_db.select(_db.dailySummaries)..where(
              (t) =>
                  t.date.equals(d.toIso()) & t.version.equals(kSummaryVersion),
            ))
            .getSingleOrNull();
    if (r == null) return null;
    try {
      return DayStats.fromJson(
        (jsonDecode(r.statsJson) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<Map<LocalDate, DayStats>> range(LocalDate from, LocalDate to) async {
    final rows =
        await (_db.select(_db.dailySummaries)..where(
              (t) =>
                  t.date.isBiggerOrEqualValue(from.toIso()) &
                  t.date.isSmallerOrEqualValue(to.toIso()) &
                  t.version.equals(kSummaryVersion),
            ))
            .get();
    final out = <LocalDate, DayStats>{};
    for (final r in rows) {
      try {
        final s = DayStats.fromJson(
          (jsonDecode(r.statsJson) as Map).cast<String, Object?>(),
        );
        if (s != null) out[s.date] = s;
      } catch (_) {}
    }
    return out;
  }

  Future<void> invalidate(LocalDate d) => (_db.delete(
    _db.dailySummaries,
  )..where((t) => t.date.equals(d.toIso()))).go();

  Future<void> invalidateAll() => _db.delete(_db.dailySummaries).go();
}

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<String?> getString(String key) async => (await (_db.select(
    _db.kvSettings,
  )..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setString(String key, String value) => _db
      .into(_db.kvSettings)
      .insertOnConflictUpdate(
        KvSettingsCompanion(key: Value(key), value: Value(value)),
      );

  Future<void> remove(String key) =>
      (_db.delete(_db.kvSettings)..where((t) => t.key.equals(key))).go();

  Stream<String?> watchString(String key) => (_db.select(
    _db.kvSettings,
  )..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<int?> getInt(String key) async =>
      int.tryParse(await getString(key) ?? '');
  Future<void> setInt(String key, int v) => setString(key, '$v');

  Future<bool> getBool(String key, {bool fallback = false}) async {
    final v = await getString(key);
    return v == null ? fallback : v == '1';
  }

  Future<void> setBool(String key, bool v) => setString(key, v ? '1' : '0');

  Future<DateTime?> getTime(String key) async {
    final ms = await getInt(key);
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> setTime(String key, DateTime t) =>
      setInt(key, t.toUtc().millisecondsSinceEpoch);

  Future<Map<String, Object?>> getJson(String key) async {
    try {
      final s = await getString(key);
      if (s == null) return {};
      return (jsonDecode(s) as Map).cast<String, Object?>();
    } catch (_) {
      return {};
    }
  }

  Future<void> setJson(String key, Map<String, Object?> v) =>
      setString(key, jsonEncode(v));
}

/// Keys used with [SettingsRepository]. Centralised to avoid typos.
abstract final class SettingKeys {
  static const snoozeUntil = 'sched.snoozeUntil';
  static const pausedUntil = 'sched.pausedUntil';
  static const pausedUntilLog = 'sched.pausedUntilLog';
  static const askedFewerReminders = 'sched.askedFewerAt';
  static const lastScheduledAt = 'sched.lastScheduledAt';
  static const lastDecisionJson = 'sched.lastDecision';
  static const lastTimezone = 'tz.last';
  static const smartQuickAdd = 'ui.smartQuickAdd';
  static const healthSyncEnabled = 'health.enabled';
  static const healthDirection = 'health.direction';
  static const healthLastSync = 'health.lastSync';
  static const adsPersonalization = 'ads.nonPersonalizedOnly';
  static const adLastInterstitial = 'ads.lastInterstitial';
  static const adInterstitialsToday = 'ads.interstitialsToday';
  static const adCounterDate = 'ads.counterDate';
  static const adLastShown = 'ads.lastShown';
  static const rewardedThemeUntil = 'reward.themeUntil';
  static const rewardedExtraVesselDate = 'reward.vesselDate';
  static const entitlementCache = 'sub.entitlementCache';
  static const analyticsEnabled = 'privacy.analytics';
  static const firstLaunchAt = 'app.firstLaunch';
  static const feedbackAskedAt = 'app.feedbackAsked';
  static const dismissedTzPromptFor = 'tz.dismissedFor';
  static const remoteConfigCache = 'remote.cache';
  static const paywallSeenAt = 'sub.paywallSeen';
  static const wizardDay = 'app.activationDay';
}

class AchievementRepository {
  AchievementRepository(this._db);
  final AppDatabase _db;

  Future<Set<String>> unlockedIds() async => {
    for (final r in await _db.select(_db.achievements).get()) r.id,
  };

  /// Returns true only the first time [id] is unlocked.
  Future<bool> unlock(
    String id,
    String type,
    DateTime at, {
    Map<String, Object?> meta = const {},
  }) => _db.transaction(() async {
    final exists = await (_db.select(
      _db.achievements,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (exists != null) return false;
    await _db
        .into(_db.achievements)
        .insert(
          AchievementsCompanion.insert(
            id: id,
            type: type,
            unlockedAt: at.toUtc().millisecondsSinceEpoch,
            metadataJson: Value(jsonEncode(meta)),
          ),
        );
    return true;
  });

  Stream<List<AchievementRow>> watchAll() =>
      _db.select(_db.achievements).watch();
}
