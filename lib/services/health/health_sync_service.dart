import '../../core/logging/log.dart';
import '../../core/time/hydra_time.dart';
import '../../data/repositories/hydration_repository.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../domain/models/enums.dart';
import '../../domain/sync/health_reconciler.dart';
import 'health_service.dart';

class SyncReport {
  const SyncReport({
    this.imported = 0,
    this.exported = 0,
    this.linked = 0,
    this.removed = 0,
    this.failure,
  });
  final int imported;
  final int exported;
  final int linked;
  final int removed;
  final HealthSyncFailure? failure;
  bool get ok => failure == null;
}

/// Orchestrates one reconciliation pass. Any failure leaves local data
/// untouched (the plan is only applied after a successful read).
class HealthSyncService {
  HealthSyncService({
    required this.health,
    required this.hydration,
    required this.settings,
    required this.timezoneName,
    DateTime Function()? now,
    this.windowDays = 14,
  }) : _now = now ?? DateTime.now;

  final HealthService health;
  final HydrationRepository hydration;
  final SettingsRepository settings;
  final String Function() timezoneName;
  final DateTime Function() _now;
  final int windowDays;

  bool _running = false;

  Future<bool> get enabled => settings.getBool(SettingKeys.healthSyncEnabled);

  Future<SyncDirection> direction() async {
    final v = await settings.getString(SettingKeys.healthDirection);
    return SyncDirection.values.firstWhere((d) => d.name == v, orElse: () => SyncDirection.twoWay);
  }

  Future<void> enable(SyncDirection direction) async {
    await settings.setBool(SettingKeys.healthSyncEnabled, true);
    await settings.setString(SettingKeys.healthDirection, direction.name);
  }

  Future<void> disable() => settings.setBool(SettingKeys.healthSyncEnabled, false);

  Future<SyncReport> sync() async {
    if (_running) return const SyncReport();
    _running = true;
    try {
      if (!await enabled) return const SyncReport();
      final now = _now().toUtc();
      final from = now.subtract(Duration(days: windowDays));
      final platform = health.platformSource;
      final local = await hydration.entriesBetween(
        logicalDateOf(from, locationFor(timezoneName())),
        logicalDateOf(now, locationFor(timezoneName())).addDays(1),
      );
      final external = await health.readWater(from, now);
      final plan = HealthReconciler.plan(
        platform: platform,
        local: local,
        external: external,
        tombstones: await hydration.tombstones(platform),
        direction: await direction(),
        windowStart: from,
        windowEnd: now,
      );

      final tz = timezoneName();
      var imported = 0;
      for (final x in plan.toImport) {
        await hydration.add(
          volumeMl: x.ml,
          at: x.at,
          timezone: tz,
          source: platform,
          externalRecordId: x.id,
        );
        imported++;
      }
      for (final e in plan.toLink.entries) {
        await hydration.linkExternal(e.key, e.value, platform);
      }
      var exported = 0;
      for (final e in plan.toExport) {
        try {
          final marker = await health.writeWater(ml: e.volumeMl, at: e.timestampUtc, clientId: e.id);
          await hydration.linkExternal(e.id, marker, EntrySource.manual);
          exported++;
        } on HealthSyncException {
          rethrow;
        }
      }
      var removed = 0;
      for (final id in plan.toRemoveLocal) {
        await hydration.delete(id);
        removed++;
      }
      await settings.setTime(SettingKeys.healthLastSync, now);
      return SyncReport(
        imported: imported,
        exported: exported,
        linked: plan.toLink.length,
        removed: removed,
      );
    } on HealthSyncException catch (e) {
      Log.warning('health', 'sync failed', fields: {'reason': e.kind.name});
      return SyncReport(failure: e.kind);
    } catch (e, st) {
      Log.error('health', 'sync crashed', error: e, stack: st);
      return const SyncReport(failure: HealthSyncFailure.platformError);
    } finally {
      _running = false;
    }
  }
}
