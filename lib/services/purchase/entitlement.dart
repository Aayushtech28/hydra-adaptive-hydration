enum SubscriptionStatus { free, trial, active, gracePeriod, billingProblem, expired }

/// SDK-independent view of a store customer (mapped from RevenueCat).
class CustomerSnapshot {
  const CustomerSnapshot({
    required this.entitlementActive,
    this.isTrial = false,
    this.expiresAt,
    this.billingIssueAt,
    this.willRenew = false,
    this.productId,
    this.everSubscribed = false,
  });

  final bool entitlementActive;
  final bool isTrial;

  /// Null for lifetime purchases.
  final DateTime? expiresAt;
  final DateTime? billingIssueAt;
  final bool willRenew;
  final String? productId;

  /// True if the customer ever held the entitlement (distinguishes
  /// `free` from `expired`).
  final bool everSubscribed;
}

class Entitlement {
  const Entitlement({
    required this.status,
    this.expiresAt,
    this.productId,
    this.willRenew = false,
    this.checkedAt,
    this.fromCache = false,
  });

  static const Entitlement free = Entitlement(status: SubscriptionStatus.free);

  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final String? productId;
  final bool willRenew;
  final DateTime? checkedAt;
  final bool fromCache;

  /// Pro features unlocked. A billing problem *after* the store's grace
  /// period does not unlock; during grace the user keeps Pro.
  bool get isPro =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trial ||
      status == SubscriptionStatus.gracePeriod;

  bool get needsBillingAttention =>
      status == SubscriptionStatus.gracePeriod || status == SubscriptionStatus.billingProblem;

  Map<String, Object?> toJson() => {
        's': status.name,
        'e': expiresAt?.toUtc().millisecondsSinceEpoch,
        'p': productId,
        'r': willRenew,
        'c': checkedAt?.toUtc().millisecondsSinceEpoch,
      };

  static Entitlement fromJson(Map<String, Object?> j) {
    final status = SubscriptionStatus.values
        .where((s) => s.name == j['s'])
        .cast<SubscriptionStatus?>()
        .firstOrNull;
    if (status == null) return free;
    DateTime? ms(Object? v) =>
        v is int ? DateTime.fromMillisecondsSinceEpoch(v, isUtc: true) : null;
    return Entitlement(
      status: status,
      expiresAt: ms(j['e']),
      productId: j['p'] as String?,
      willRenew: j['r'] == true,
      checkedAt: ms(j['c']),
      fromCache: true,
    );
  }
}

abstract final class EntitlementResolver {
  /// How long a cached Pro state is honoured past its expiry when the store
  /// cannot be reached (transient network failure must not lock users out).
  static const Duration offlineGrace = Duration(days: 3);

  static Entitlement fromCustomer(CustomerSnapshot c, DateTime now) {
    if (c.entitlementActive) {
      final status = c.billingIssueAt != null
          ? SubscriptionStatus.gracePeriod
          : c.isTrial
              ? SubscriptionStatus.trial
              : SubscriptionStatus.active;
      return Entitlement(
        status: status,
        expiresAt: c.expiresAt,
        productId: c.productId,
        willRenew: c.willRenew,
        checkedAt: now,
      );
    }
    if (c.billingIssueAt != null) {
      return Entitlement(
        status: SubscriptionStatus.billingProblem,
        expiresAt: c.expiresAt,
        productId: c.productId,
        checkedAt: now,
      );
    }
    return Entitlement(
      status: c.everSubscribed ? SubscriptionStatus.expired : SubscriptionStatus.free,
      expiresAt: c.expiresAt,
      productId: c.productId,
      checkedAt: now,
    );
  }

  /// The entitlement to use when a live refresh failed.
  static Entitlement fromCacheOnFailure(Entitlement? cached, DateTime now) {
    if (cached == null) return Entitlement.free;
    if (!cached.isPro) return cached;
    final exp = cached.expiresAt;
    if (exp == null) return cached; // lifetime
    if (now.isBefore(exp.add(offlineGrace))) return cached;
    return Entitlement(
      status: SubscriptionStatus.expired,
      expiresAt: exp,
      productId: cached.productId,
      checkedAt: cached.checkedAt,
      fromCache: true,
    );
  }
}
