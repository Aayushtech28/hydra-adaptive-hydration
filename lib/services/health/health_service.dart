import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/logging/log.dart';
import '../../domain/models/enums.dart';
import '../../domain/sync/health_reconciler.dart';

enum HealthAvailability { available, notInstalled, unsupported }

enum HealthPermissionState { granted, denied, unknown }

/// Thrown for recoverable platform failures; the sync layer surfaces them as
/// "HYDRA couldn't sync right now" and never touches local data.
class HealthSyncException implements Exception {
  const HealthSyncException(this.kind);
  final HealthSyncFailure kind;
  @override
  String toString() => 'HealthSyncException($kind)';
}

enum HealthSyncFailure { permissionRevoked, unavailable, platformError }

/// Boundary to HealthKit (iOS) / Health Connect (Android). **Only the water
/// intake type is ever requested** — no heart rate, sleep, steps, etc.
abstract class HealthService {
  EntrySource get platformSource;
  Future<HealthAvailability> availability();
  Future<HealthPermissionState> permission();
  Future<bool> requestPermission();
  Future<List<ExternalHydration>> readWater(DateTime from, DateTime to);

  /// Writes one drink; returns a stable link marker stored as the entry's
  /// externalRecordId. Idempotent per [clientId].
  Future<String> writeWater({required int ml, required DateTime at, required String clientId});

  /// Android only: sends the user to install Health Connect.
  Future<void> installProvider();
}

class PlatformHealthService implements HealthService {
  PlatformHealthService({Health? health}) : _health = health ?? Health();
  final Health _health;

  static const List<HealthDataType> _types = [HealthDataType.WATER];
  static const List<HealthDataAccess> _access = [HealthDataAccess.READ_WRITE];
  static const String _hydraSourcePrefix = 'com.hydra.';
  bool _configured = false;

  @override
  EntrySource get platformSource =>
      defaultTargetPlatform == TargetPlatform.iOS ? EntrySource.healthkit : EntrySource.healthConnect;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  @override
  Future<HealthAvailability> availability() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return HealthAvailability.unsupported;
    if (Platform.isIOS) return HealthAvailability.available;
    try {
      await _ensureConfigured();
      final s = await _health.getHealthConnectSdkStatus();
      return s == HealthConnectSdkStatus.sdkAvailable
          ? HealthAvailability.available
          : s == HealthConnectSdkStatus.sdkUnavailable
              ? HealthAvailability.unsupported
              : HealthAvailability.notInstalled;
    } catch (e, st) {
      Log.error('health', 'availability check failed', error: e, stack: st);
      return HealthAvailability.unsupported;
    }
  }

  @override
  Future<HealthPermissionState> permission() async {
    try {
      await _ensureConfigured();
      final ok = await _health.hasPermissions(_types, permissions: _access);
      if (ok == null) return HealthPermissionState.unknown; // iOS hides read status
      return ok ? HealthPermissionState.granted : HealthPermissionState.denied;
    } catch (e) {
      return HealthPermissionState.unknown;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(_types, permissions: _access);
    } catch (e, st) {
      Log.error('health', 'permission request failed', error: e, stack: st);
      return false;
    }
  }

  @override
  Future<List<ExternalHydration>> readWater(DateTime from, DateTime to) async {
    try {
      await _ensureConfigured();
      final points = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: from,
        endTime: to,
      );
      final out = <ExternalHydration>[];
      for (final p in _health.removeDuplicates(points)) {
        final v = p.value;
        if (v is! NumericHealthValue) continue;
        final liters = v.numericValue.toDouble();
        final ml = (liters * 1000).round();
        if (ml <= 0 || ml > 5000) continue; // ignore nonsensical external data
        out.add(ExternalHydration(
          id: p.uuid,
          at: p.dateFrom.toUtc(),
          ml: ml,
          writtenByHydra: p.sourceId.startsWith(_hydraSourcePrefix),
        ));
      }
      return out;
    } on HealthException catch (e) {
      Log.warning('health', 'read failed', fields: {'type': e.runtimeType.toString()});
      throw const HealthSyncException(HealthSyncFailure.permissionRevoked);
    } catch (e, st) {
      Log.error('health', 'read failed', error: e, stack: st);
      throw const HealthSyncException(HealthSyncFailure.platformError);
    }
  }

  @override
  Future<String> writeWater({required int ml, required DateTime at, required String clientId}) async {
    try {
      await _ensureConfigured();
      final ok = await _health.writeHealthData(
        value: ml / 1000.0,
        unit: HealthDataUnit.LITER,
        type: HealthDataType.WATER,
        startTime: at,
        endTime: at,
        clientRecordId: clientId,
        recordingMethod: RecordingMethod.manual,
      );
      if (!ok) throw const HealthSyncException(HealthSyncFailure.permissionRevoked);
      return 'w:$clientId';
    } on HealthSyncException {
      rethrow;
    } on HealthException {
      throw const HealthSyncException(HealthSyncFailure.permissionRevoked);
    } catch (e, st) {
      Log.error('health', 'write failed', error: e, stack: st);
      throw const HealthSyncException(HealthSyncFailure.platformError);
    }
  }

  @override
  Future<void> installProvider() async {
    if (Platform.isAndroid) await _health.installHealthConnect();
  }
}

/// Used where no platform health store exists (tests, unsupported OS).
class UnsupportedHealthService implements HealthService {
  @override
  EntrySource get platformSource => EntrySource.healthConnect;
  @override
  Future<HealthAvailability> availability() async => HealthAvailability.unsupported;
  @override
  Future<HealthPermissionState> permission() async => HealthPermissionState.denied;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<List<ExternalHydration>> readWater(DateTime from, DateTime to) async =>
      throw const HealthSyncException(HealthSyncFailure.unavailable);
  @override
  Future<String> writeWater({required int ml, required DateTime at, required String clientId}) async =>
      throw const HealthSyncException(HealthSyncFailure.unavailable);
  @override
  Future<void> installProvider() async {}
}
