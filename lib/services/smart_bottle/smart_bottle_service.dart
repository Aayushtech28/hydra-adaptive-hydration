import 'dart:async';

/// Future BLE smart-bottle boundary (not implemented in V1). Bottle readings
/// would enter through [HydrationEvent]s with `EntrySource.smartBottle` and
/// external ids, and flow through the same reconciliation as health records.
class BottleDevice {
  const BottleDevice({
    required this.id,
    required this.name,
    this.batteryPercent,
  });
  final String id;
  final String name;
  final int? batteryPercent;
}

class BottleHydrationEvent {
  const BottleHydrationEvent({
    required this.deviceId,
    required this.eventId,
    required this.at,
    required this.ml,
  });
  final String deviceId;
  final String eventId;
  final DateTime at;
  final int ml;
}

enum BottleStatus { unsupported, disconnected, connecting, connected }

abstract class SmartBottleService {
  bool get supported;
  Stream<BottleStatus> get status;
  Stream<BottleHydrationEvent> get events;
  Stream<List<BottleDevice>> discover();
  Future<void> connect(BottleDevice d);
  Future<void> disconnect();
  Future<int?> batteryPercent();
}

/// Honest default: reports unsupported so UI can hide the feature.
class UnsupportedSmartBottleService implements SmartBottleService {
  @override
  bool get supported => false;
  @override
  Stream<BottleStatus> get status => Stream.value(BottleStatus.unsupported);
  @override
  Stream<BottleHydrationEvent> get events => const Stream.empty();
  @override
  Stream<List<BottleDevice>> discover() => const Stream.empty();
  @override
  Future<void> connect(BottleDevice d) async =>
      throw UnsupportedError('Smart bottles are not supported yet');
  @override
  Future<void> disconnect() async {}
  @override
  Future<int?> batteryPercent() async => null;
}
