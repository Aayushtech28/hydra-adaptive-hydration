import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/config/app_config.dart';
import '../../core/logging/log.dart';

/// Low-level ad loading/showing. **Policy lives elsewhere** (AdPolicyManager +
/// AdCoordinator); this class performs no gating of its own except refusing
/// to run when no ad unit is configured.
abstract class AdService {
  bool get isInitialized;
  Future<void> initialize();
  bool unitAvailable(String kind);
  Future<BannerAd?> loadBanner(int widthDp);
  Future<NativeAd?> loadNative();

  /// Returns true if the ad was displayed.
  Future<bool> showInterstitial();

  /// Returns true when the user earned the reward (watched to completion).
  Future<bool> showRewarded();
}

class AdMobService implements AdService {
  bool _initialized = false;

  bool get _android => defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isInitialized => _initialized;

  @override
  bool unitAvailable(String kind) =>
      AppConfig.adUnit(kind, android: _android) != null;

  /// Every request is contextual: no keywords, no content URL, no custom
  /// targeting, and personalization is off. Hydration/health state is not an
  /// input to this class — enforced by its (lack of) dependencies.
  AdRequest get _request =>
      const AdRequest(nonPersonalizedAds: AppConfig.forceContextualAds);

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
          maxAdContentRating: MaxAdContentRating.pg,
        ),
      );
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e, st) {
      Log.error('ads', 'initialize failed', error: e, stack: st);
    }
  }

  @override
  Future<BannerAd?> loadBanner(int widthDp) async {
    final unit = AppConfig.adUnit('banner', android: _android);
    if (unit == null || !_initialized) return null;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(widthDp);
    if (size == null) return null;
    final done = Completer<BannerAd?>();
    final ad = BannerAd(
      adUnitId: unit,
      size: size,
      request: _request,
      listener: BannerAdListener(
        onAdLoaded: (a) => done.complete(a as BannerAd),
        onAdFailedToLoad: (a, err) {
          a.dispose();
          Log.info('ads', 'banner failed', fields: {'code': err.code});
          done.complete(null);
        },
      ),
    );
    await ad.load();
    return done.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        ad.dispose();
        return null;
      },
    );
  }

  @override
  Future<NativeAd?> loadNative() async {
    final unit = AppConfig.adUnit('native', android: _android);
    if (unit == null || !_initialized) return null;
    final done = Completer<NativeAd?>();
    final ad = NativeAd(
      adUnitId: unit,
      request: _request,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
      ),
      listener: NativeAdListener(
        onAdLoaded: (a) => done.complete(a as NativeAd),
        onAdFailedToLoad: (a, err) {
          a.dispose();
          Log.info('ads', 'native failed', fields: {'code': err.code});
          done.complete(null);
        },
      ),
    );
    await ad.load();
    return done.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        ad.dispose();
        return null;
      },
    );
  }

  @override
  Future<bool> showInterstitial() async {
    final unit = AppConfig.adUnit('interstitial', android: _android);
    if (unit == null || !_initialized) return false;
    final loaded = Completer<InterstitialAd?>();
    await InterstitialAd.load(
      adUnitId: unit,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (e) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    if (ad == null) return false;
    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        dismissed.complete();
      },
    );
    await ad.show();
    await dismissed.future;
    return true;
  }

  @override
  Future<bool> showRewarded() async {
    final unit = AppConfig.adUnit('rewarded', android: _android);
    if (unit == null || !_initialized) return false;
    final loaded = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: unit,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (e) => loaded.complete(null),
      ),
    );
    final ad = await loaded.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    if (ad == null) return false;
    var earned = false;
    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        dismissed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        a.dispose();
        dismissed.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    await dismissed.future;
    return earned;
  }
}

/// No-op implementation (Pro users, tests, unsupported platforms).
class NoAdService implements AdService {
  @override
  bool get isInitialized => false;
  @override
  Future<void> initialize() async {}
  @override
  bool unitAvailable(String kind) => false;
  @override
  Future<BannerAd?> loadBanner(int widthDp) async => null;
  @override
  Future<NativeAd?> loadNative() async => null;
  @override
  Future<bool> showInterstitial() async => false;
  @override
  Future<bool> showRewarded() async => false;
}
