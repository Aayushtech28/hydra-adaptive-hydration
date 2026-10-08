import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/core/config/app_config.dart';
import 'package:hydra/core/config/feature_flags.dart';
import 'package:hydra/services/ads/ad_policy.dart';
import 'package:hydra/services/ads/consent_service.dart';
import 'package:hydra/services/analytics/analytics_service.dart';
import 'package:hydra/services/purchase/entitlement.dart';
import 'package:hydra/services/remote_config/remote_config.dart';

final _now = DateTime.utc(2026, 10, 8, 12);

void main() {
  releaseConfigTests();
  group('EntitlementResolver', () {
    test('free / never subscribed', () {
      final e = EntitlementResolver.fromCustomer(
        const CustomerSnapshot(entitlementActive: false),
        _now,
      );
      expect(e.status, SubscriptionStatus.free);
      expect(e.isPro, isFalse);
    });
    test(
      'active, trial, grace (billing issue while active) all unlock Pro',
      () {
        expect(
          EntitlementResolver.fromCustomer(
            const CustomerSnapshot(entitlementActive: true),
            _now,
          ).status,
          SubscriptionStatus.active,
        );
        expect(
          EntitlementResolver.fromCustomer(
            const CustomerSnapshot(entitlementActive: true, isTrial: true),
            _now,
          ).status,
          SubscriptionStatus.trial,
        );
        final g = EntitlementResolver.fromCustomer(
          CustomerSnapshot(entitlementActive: true, billingIssueAt: _now),
          _now,
        );
        expect(g.status, SubscriptionStatus.gracePeriod);
        expect(g.isPro, isTrue);
        expect(g.needsBillingAttention, isTrue);
      },
    );
    test(
      'billing problem after lapse does not unlock; expired does not unlock',
      () {
        final b = EntitlementResolver.fromCustomer(
          CustomerSnapshot(
            entitlementActive: false,
            billingIssueAt: _now,
            everSubscribed: true,
          ),
          _now,
        );
        expect(b.status, SubscriptionStatus.billingProblem);
        expect(b.isPro, isFalse);
        final x = EntitlementResolver.fromCustomer(
          const CustomerSnapshot(
            entitlementActive: false,
            everSubscribed: true,
          ),
          _now,
        );
        expect(x.status, SubscriptionStatus.expired);
        expect(x.isPro, isFalse);
      },
    );
    test('transient network failure keeps cached Pro; ages out after offline grace', () {
      final cached = Entitlement(
        status: SubscriptionStatus.active,
        expiresAt: _now.add(const Duration(days: 5)),
      );
      expect(
        EntitlementResolver.fromCacheOnFailure(cached, _now).isPro,
        isTrue,
      );
      // expired 2 days ago: still inside the 3-day grace
      final lapsing = Entitlement(
        status: SubscriptionStatus.active,
        expiresAt: _now.subtract(const Duration(days: 2)),
      );
      expect(
        EntitlementResolver.fromCacheOnFailure(lapsing, _now).isPro,
        isTrue,
      );
      // expired 4 days ago: grace over
      final gone = Entitlement(
        status: SubscriptionStatus.active,
        expiresAt: _now.subtract(const Duration(days: 4)),
      );
      expect(
        EntitlementResolver.fromCacheOnFailure(gone, _now).status,
        SubscriptionStatus.expired,
      );
      // lifetime (no expiry) persists; no cache ⇒ free
      expect(
        EntitlementResolver.fromCacheOnFailure(
          const Entitlement(status: SubscriptionStatus.active),
          _now,
        ).isPro,
        isTrue,
      );
      expect(
        EntitlementResolver.fromCacheOnFailure(null, _now),
        Entitlement.free,
      );
    });
    test('json round trip; corrupt cache degrades to free', () {
      final e = Entitlement(
        status: SubscriptionStatus.trial,
        expiresAt: _now,
        productId: 'p',
        willRenew: true,
        checkedAt: _now,
      );
      expect(Entitlement.fromJson(e.toJson()).status, SubscriptionStatus.trial);
      expect(Entitlement.fromJson({'s': 'nonsense'}), Entitlement.free);
      expect(Entitlement.fromJson(const {}), Entitlement.free);
    });
  });

  group('AdPolicyManager', () {
    const policy = AdPolicyManager();
    AdPolicyInput input(
      AdPlacement p, {
      bool pro = false,
      bool consent = true,
      bool online = true,
      int age = 5,
      int logs = 10,
      int intToday = 0,
      int intSession = 0,
      int rewardedToday = 0,
      DateTime? last,
      bool unit = true,
      bool rewardedOn = true,
    }) => AdPolicyInput(
      placement: p,
      now: _now,
      isPro: pro,
      canRequestAds: consent,
      online: online,
      installAgeDays: age,
      totalLogs: logs,
      interstitialsToday: intToday,
      interstitialsThisSession: intSession,
      rewardedToday: rewardedToday,
      lastAdShownAt: last,
      adUnitAvailable: unit,
      rewardedEnabled: rewardedOn,
    );

    test('allowed on a secondary screen for an established free user', () {
      expect(policy.decide(input(AdPlacement.historyBanner)).allowed, isTrue);
      expect(policy.decide(input(AdPlacement.insightsNative)).allowed, isTrue);
    });
    test('never for Pro, without consent, offline, or without an ad unit', () {
      for (final p in AdPlacement.values) {
        expect(policy.decide(input(p, pro: true)).reason, AdDenyReason.pro);
        expect(
          policy.decide(input(p, consent: false)).reason,
          AdDenyReason.noConsent,
        );
        expect(
          policy.decide(input(p, online: false)).reason,
          AdDenyReason.offline,
        );
        expect(
          policy.decide(input(p, unit: false)).reason,
          AdDenyReason.unavailable,
        );
      }
    });
    test('passive ads wait until the product proved its value', () {
      expect(
        policy.decide(input(AdPlacement.historyBanner, logs: 2)).reason,
        AdDenyReason.notActivated,
      );
      expect(
        policy.decide(input(AdPlacement.historyBanner, age: 0)).reason,
        AdDenyReason.tooNew,
      );
    });
    test('interstitial caps: new users, session, daily, spacing', () {
      const p = AdPlacement.monthlyAnalysisInterstitial;
      expect(policy.decide(input(p, age: 2)).reason, AdDenyReason.tooNew);
      expect(
        policy.decide(input(p, intSession: 1)).reason,
        AdDenyReason.sessionCap,
      );
      expect(
        policy.decide(input(p, intToday: 2)).reason,
        AdDenyReason.dailyCap,
      );
      expect(
        policy
            .decide(input(p, last: _now.subtract(const Duration(minutes: 2))))
            .reason,
        AdDenyReason.intervalNotElapsed,
      );
      expect(policy.decide(input(p)).allowed, isTrue);
    });
    test('rewarded is optional, flag-controlled and capped per day (no exploit loop)', () {
      const p = AdPlacement.rewardedTheme;
      expect(
        policy.decide(input(p, logs: 0, age: 0)).allowed,
        isTrue,
      ); // user-initiated
      expect(
        policy
            .decide(input(p, rewardedToday: AdPolicyManager.maxRewardedPerDay))
            .reason,
        AdDenyReason.rewardedCap,
      );
      expect(
        policy.decide(input(p, rewardedOn: false)).reason,
        AdDenyReason.flagOff,
      );
    });
  });

  group('config safety', () {
    test('analytics default is off unless UMP positively says consent not required', () {
      expect(defaultAnalyticsEnabled(ConsentState.notRequired), isTrue);
      for (final s in [
        ConsentState.unknown,
        ConsentState.required,
        ConsentState.obtained,
      ]) {
        expect(defaultAnalyticsEnabled(s), isFalse);
      }
    });
    test('analytics params are allow-listed; amounts cannot be sent', () {
      final clean = AnalyticsService.sanitize({
        'source': 'manual',
        'volume_ml': 250,
        'history': 'x',
        'has_vessel': true,
        'plan': 'annual',
      });
      expect(clean.keys.toSet(), {'source', 'has_vessel', 'plan'});
      expect(AnalyticsService.sanitize({'source': 123}), isEmpty);
    });
    test(
      'remote config: garbage → defaults; ad caps can only get stricter',
      () {
        expect(RemoteConfig.parse('nope').maxInterstitialsPerDay, 2);
        expect(RemoteConfig.parse(null).flags.isOn(Flag.healthSync), isTrue);
        final c = RemoteConfig.parse({
          'maxInterstitialsPerDay': 50,
          'minMinutesBetweenAds': 1,
          'flags': {'rewarded_ads': false, 'bogus': true},
        });
        expect(c.maxInterstitialsPerDay, 2);
        expect(c.minMinutesBetweenAds, 5);
        expect(c.flags.isOn(Flag.rewardedAds), isFalse);
        expect(
          RemoteConfig.parse({'maxInterstitialsPerDay': 0})
              .maxInterstitialsPerDay,
          0,
        );
      },
    );
  });
}

void releaseConfigTests() {
  group('release config check', () {
    test('dev/staging never complain', () {
      for (final e in [AppEnv.dev, AppEnv.staging]) {
        expect(
          releaseConfigProblems(
            env: e,
            privacyUrl: '',
            termsUrl: '',
            supportEmail: '',
            revenueCatAndroid: '',
            revenueCatIos: '',
          ),
          isEmpty,
        );
      }
    });
    test('prod flags placeholders and missing keys', () {
      final p = releaseConfigProblems(
        env: AppEnv.prod,
        privacyUrl: 'https://hydra.example/privacy',
        termsUrl: 'http://x.com/t',
        supportEmail: 'support@hydra.example',
        revenueCatAndroid: '',
        revenueCatIos: 'k',
      );
      expect(p.length, 5 - 1);
    });
    test('prod with real values is clean', () {
      expect(
        releaseConfigProblems(
          env: AppEnv.prod,
          privacyUrl: 'https://hydra.app/privacy',
          termsUrl: 'https://hydra.app/terms',
          supportEmail: 'help@hydra.app',
          revenueCatAndroid: 'a',
          revenueCatIos: 'b',
        ),
        isEmpty,
      );
    });
  });
}
