import 'dart:async';

import 'package:hydra/domain/models/enums.dart';
import 'package:hydra/domain/sync/health_reconciler.dart';
import 'package:hydra/services/health/health_service.dart';
import 'package:hydra/services/purchase/entitlement.dart';
import 'package:hydra/services/purchase/subscription_service.dart';

class FakeHealthService implements HealthService {
  FakeHealthService({this.available = HealthAvailability.available});
  HealthAvailability available;
  HealthPermissionState perm = HealthPermissionState.granted;
  bool grant = true;
  List<ExternalHydration> external = [];
  HealthSyncFailure? failRead;
  HealthSyncFailure? failWrite;
  final List<({int ml, DateTime at, String clientId})> written = [];

  @override
  EntrySource get platformSource => EntrySource.healthkit;
  @override
  Future<HealthAvailability> availability() async => available;
  @override
  Future<HealthPermissionState> permission() async => perm;
  @override
  Future<bool> requestPermission() async => grant;
  @override
  Future<List<ExternalHydration>> readWater(DateTime from, DateTime to) async {
    if (failRead != null) throw HealthSyncException(failRead!);
    return List.of(external);
  }

  @override
  Future<String> writeWater({
    required int ml,
    required DateTime at,
    required String clientId,
  }) async {
    if (failWrite != null) throw HealthSyncException(failWrite!);
    written.add((ml: ml, at: at, clientId: clientId));
    return 'w:$clientId';
  }

  @override
  Future<void> installProvider() async {}
}

class FakeSubscriptionService implements SubscriptionService {
  FakeSubscriptionService({
    this.available = true,
    List<ProPlan>? plans,
    Entitlement initial = Entitlement.free,
  }) : _plans = plans ?? defaultPlans,
       _current = initial;

  static const defaultPlans = [
    ProPlan(
      id: 'annual',
      period: ProPeriod.annual,
      priceLabel: '\$29.99',
      hasFreeTrial: true,
      trialDays: 7,
      monthlyEquivalentLabel: '2.50 USD',
    ),
    ProPlan(
      id: 'monthly',
      period: ProPeriod.monthly,
      priceLabel: '\$4.99',
      hasFreeTrial: false,
    ),
  ];

  final bool available;
  final List<ProPlan> _plans;
  Entitlement _current;
  PurchaseOutcome nextPurchase = PurchaseOutcome.success;
  PurchaseOutcome nextRestore = PurchaseOutcome.success;
  final _ctrl = StreamController<Entitlement>.broadcast();
  int purchases = 0;

  void set(Entitlement e) {
    _current = e;
    _ctrl.add(e);
  }

  @override
  Entitlement get current => _current;
  @override
  Stream<Entitlement> get changes => _ctrl.stream;
  @override
  bool get storeAvailable => available;
  @override
  Future<void> start() async {}
  @override
  Future<Entitlement> refresh() async => _current;
  @override
  Future<List<ProPlan>> plans() async => available ? _plans : const [];
  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async {
    purchases++;
    if (nextPurchase == PurchaseOutcome.success)
      set(const Entitlement(status: SubscriptionStatus.active));
    return nextPurchase;
  }

  @override
  Future<PurchaseOutcome> restore() async {
    if (nextRestore == PurchaseOutcome.success)
      set(const Entitlement(status: SubscriptionStatus.active));
    return nextRestore;
  }
}
