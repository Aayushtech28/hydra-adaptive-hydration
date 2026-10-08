import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/logging/log.dart';
import '../../data/repositories/misc_repositories.dart';
import 'entitlement.dart';

/// A purchasable plan, independent of the store SDK.
class ProPlan {
  const ProPlan({
    required this.id,
    required this.period,
    required this.priceLabel,
    required this.hasFreeTrial,
    this.trialDays,
    this.monthlyEquivalentLabel,
    this.handle,
  });

  final String id;
  final ProPeriod period;
  final String priceLabel;
  final bool hasFreeTrial;
  final int? trialDays;
  final String? monthlyEquivalentLabel;

  /// Opaque SDK object needed to execute the purchase.
  final Object? handle;
}

enum ProPeriod { monthly, annual, lifetime }

enum PurchaseOutcome { success, cancelled, pending, failed, unavailable }

abstract class SubscriptionService {
  Entitlement get current;
  Stream<Entitlement> get changes;

  /// Loads the cache immediately (offline-safe) then refreshes from the store.
  Future<void> start();
  Future<Entitlement> refresh();
  Future<List<ProPlan>> plans();
  Future<PurchaseOutcome> purchase(ProPlan plan);
  Future<PurchaseOutcome> restore();
  bool get storeAvailable;
}

/// RevenueCat-backed implementation. All store logic lives here; UI only sees
/// [Entitlement]. Missing SDK key → `storeAvailable == false` and the app
/// stays on the free tier (core tracking is never affected).
class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this._settings, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SettingsRepository _settings;
  final DateTime Function() _now;
  final StreamController<Entitlement> _controller =
      StreamController.broadcast();
  Entitlement _current = Entitlement.free;
  bool _configured = false;

  @override
  Entitlement get current => _current;

  @override
  Stream<Entitlement> get changes => _controller.stream;

  @override
  bool get storeAvailable => _configured;

  static String get _key => defaultTargetPlatform == TargetPlatform.android
      ? AppConfig.revenueCatKeyAndroid
      : AppConfig.revenueCatKeyIos;

  @override
  Future<void> start() async {
    await _loadCache();
    if (_key.isEmpty) {
      Log.info('purchases', 'no SDK key configured; store unavailable');
      return;
    }
    try {
      await Purchases.configure(PurchasesConfiguration(_key));
      _configured = true;
      Purchases.addCustomerInfoUpdateListener((info) => _apply(_map(info)));
      unawaited(refresh());
    } catch (e, st) {
      Log.error('purchases', 'configure failed', error: e, stack: st);
    }
  }

  Future<void> _loadCache() async {
    final j = await _settings.getJson(SettingKeys.entitlementCache);
    if (j.isEmpty) return;
    _current = EntitlementResolver.fromCacheOnFailure(
      Entitlement.fromJson(j),
      _now(),
    );
    _controller.add(_current);
  }

  @override
  Future<Entitlement> refresh() async {
    if (!_configured) return _current;
    try {
      final info = await Purchases.getCustomerInfo();
      await _apply(_map(info));
    } catch (e) {
      // Transient failure: keep (and age) the cached state; never downgrade
      // immediately.
      Log.info(
        'purchases',
        'refresh failed; using cached entitlement',
        fields: {'type': e.runtimeType.toString()},
      );
      final aged = EntitlementResolver.fromCacheOnFailure(_current, _now());
      if (aged.status != _current.status) {
        _current = aged;
        _controller.add(_current);
      }
    }
    return _current;
  }

  Entitlement _map(CustomerInfo info) {
    final ent = info.entitlements.all[AppConfig.proEntitlementId];
    DateTime? parse(String? s) =>
        s == null ? null : DateTime.tryParse(s)?.toUtc();
    return EntitlementResolver.fromCustomer(
      CustomerSnapshot(
        entitlementActive: ent?.isActive ?? false,
        isTrial: ent?.periodType == PeriodType.trial,
        expiresAt: parse(ent?.expirationDate),
        billingIssueAt: parse(ent?.billingIssueDetectedAt),
        willRenew: ent?.willRenew ?? false,
        productId: ent?.productIdentifier,
        everSubscribed: ent != null,
      ),
      _now(),
    );
  }

  Future<void> _apply(Entitlement e) async {
    _current = e;
    await _settings.setString(
      SettingKeys.entitlementCache,
      jsonEncode(e.toJson()),
    );
    _controller.add(e);
  }

  @override
  Future<List<ProPlan>> plans() async {
    if (!_configured) return const [];
    try {
      final offerings = await Purchases.getOfferings();
      final o = offerings.current;
      if (o == null) return const [];
      ProPlan? build(Package? p, ProPeriod period) {
        if (p == null) return null;
        final sp = p.storeProduct;
        final intro = sp.introductoryPrice;
        return ProPlan(
          id: p.identifier,
          period: period,
          priceLabel: sp.priceString,
          hasFreeTrial: intro != null && intro.price == 0,
          trialDays: intro != null && intro.price == 0
              ? intro.periodNumberOfUnits * _unitDays(intro.periodUnit)
              : null,
          monthlyEquivalentLabel: period == ProPeriod.annual
              ? _monthlyEquivalent(sp.price, sp.currencyCode)
              : null,
          handle: p,
        );
      }

      return [
        build(o.annual, ProPeriod.annual),
        build(o.monthly, ProPeriod.monthly),
        build(o.lifetime, ProPeriod.lifetime),
      ].whereType<ProPlan>().toList();
    } catch (e, st) {
      Log.error('purchases', 'offerings failed', error: e, stack: st);
      return const [];
    }
  }

  static int _unitDays(PeriodUnit u) => switch (u) {
    PeriodUnit.day => 1,
    PeriodUnit.week => 7,
    PeriodUnit.month => 30,
    PeriodUnit.year => 365,
    _ => 1,
  };

  static String _monthlyEquivalent(double price, String currency) =>
      '${(price / 12).toStringAsFixed(2)} $currency';

  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async {
    final pkg = plan.handle;
    if (!_configured || pkg is! Package) return PurchaseOutcome.unavailable;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(pkg));
      await _apply(_map(result.customerInfo));
      return current.isPro ? PurchaseOutcome.success : PurchaseOutcome.pending;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError)
        return PurchaseOutcome.cancelled;
      if (code == PurchasesErrorCode.paymentPendingError)
        return PurchaseOutcome.pending;
      Log.error(
        'purchases',
        'purchase failed',
        error: e,
        fields: {'code': code.name},
      );
      return PurchaseOutcome.failed;
    } catch (e, st) {
      Log.error('purchases', 'purchase failed', error: e, stack: st);
      return PurchaseOutcome.failed;
    }
  }

  @override
  Future<PurchaseOutcome> restore() async {
    if (!_configured) return PurchaseOutcome.unavailable;
    try {
      final info = await Purchases.restorePurchases();
      await _apply(_map(info));
      return current.isPro ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } catch (e, st) {
      Log.error('purchases', 'restore failed', error: e, stack: st);
      return PurchaseOutcome.failed;
    }
  }
}
