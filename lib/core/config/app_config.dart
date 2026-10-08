import 'package:flutter/foundation.dart';

enum AppEnv {
  dev,
  staging,
  prod;

  static AppEnv parse(String v) =>
      AppEnv.values.firstWhere((e) => e.name == v, orElse: () => AppEnv.dev);
}

/// Build-time configuration, supplied with `--dart-define`. **No secret ever
/// lives in source control**: production ad unit ids, RevenueCat public SDK
/// keys and URLs are injected by CI. Missing values degrade safely (ads off,
/// purchases unavailable, remote config uses bundled defaults).
///
///     flutter run --dart-define=HYDRA_ENV=dev
///     flutter build appbundle --dart-define=HYDRA_ENV=prod \
///       --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/yyy ...
class AppConfig {
  const AppConfig._();

  static const String _env = String.fromEnvironment(
    'HYDRA_ENV',
    defaultValue: 'dev',
  );
  static AppEnv get env => AppEnv.parse(_env);
  static bool get isProd => env == AppEnv.prod;

  /// Developer tooling is compiled out of release builds *and* off in prod.
  static bool get debugToolsAvailable => !kReleaseMode && !isProd;

  // ---- Subscriptions (RevenueCat public SDK keys; safe to ship, but still
  // injected per environment) -------------------------------------------
  static const String revenueCatKeyAndroid = String.fromEnvironment(
    'RC_KEY_ANDROID',
  );
  static const String revenueCatKeyIos = String.fromEnvironment('RC_KEY_IOS');
  static const String proEntitlementId = 'hydra_pro';

  // ---- Ads ---------------------------------------------------------------
  /// Google's published test units, used for dev/staging.
  static const Map<String, String> _testAds = {
    'banner_android': 'ca-app-pub-3940256099942544/6300978111',
    'banner_ios': 'ca-app-pub-3940256099942544/2934735716',
    'native_android': 'ca-app-pub-3940256099942544/2247696110',
    'native_ios': 'ca-app-pub-3940256099942544/3986624511',
    'interstitial_android': 'ca-app-pub-3940256099942544/1033173712',
    'interstitial_ios': 'ca-app-pub-3940256099942544/4411468910',
    'rewarded_android': 'ca-app-pub-3940256099942544/5224354917',
    'rewarded_ios': 'ca-app-pub-3940256099942544/1712485313',
  };

  static const String _prodBannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
  );
  static const String _prodBannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
  );
  static const String _prodNativeAndroid = String.fromEnvironment(
    'ADMOB_NATIVE_ANDROID',
  );
  static const String _prodNativeIos = String.fromEnvironment(
    'ADMOB_NATIVE_IOS',
  );
  static const String _prodInterstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
  );
  static const String _prodInterstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
  );
  static const String _prodRewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
  );
  static const String _prodRewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
  );

  /// Ad unit id for [kind] (`banner`, `native`, `interstitial`, `rewarded`) on
  /// the current platform. Returns null in prod when the id was not injected,
  /// which disables that format (never falls back to test ads in prod).
  static String? adUnit(String kind, {required bool android}) {
    final key = '${kind}_${android ? 'android' : 'ios'}';
    if (!isProd) return _testAds[key];
    final v = switch (key) {
      'banner_android' => _prodBannerAndroid,
      'banner_ios' => _prodBannerIos,
      'native_android' => _prodNativeAndroid,
      'native_ios' => _prodNativeIos,
      'interstitial_android' => _prodInterstitialAndroid,
      'interstitial_ios' => _prodInterstitialIos,
      'rewarded_android' => _prodRewardedAndroid,
      'rewarded_ios' => _prodRewardedIos,
      _ => '',
    };
    return v.isEmpty ? null : v;
  }

  /// Hydration/health state must never influence ad requests. Requests are
  /// always contextual (non-personalized) — an architectural choice, not a
  /// user toggle. See docs/PRIVACY_ARCHITECTURE.md.
  static const bool forceContextualAds = true;

  // ---- Services ----------------------------------------------------------
  static const String remoteConfigUrl = String.fromEnvironment(
    'REMOTE_CONFIG_URL',
  );
  static const bool firebaseEnabled = bool.fromEnvironment('FIREBASE_ENABLED');
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://hydra.example/privacy',
  );
  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://hydra.example/terms',
  );
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@hydra.example',
  );
}
