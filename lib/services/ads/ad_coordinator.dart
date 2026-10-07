import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/config/feature_flags.dart';
import '../../data/repositories/misc_repositories.dart';
import '../purchase/subscription_service.dart';
import '../remote_config/remote_config.dart';
import 'ad_policy.dart';
import 'ad_service.dart';
import 'consent_service.dart';

/// The only gateway UI uses to ask "may I show an ad here?". It assembles the
/// policy input from consent, entitlement, usage counters and connectivity and
/// records every impression, so frequency caps are enforced centrally.
class AdCoordinator {
  AdCoordinator({
    required this.service,
    required this.consent,
    required this.subscription,
    required this.settings,
    required this.remote,
    required this.totalLogs,
    required this.installAgeDays,
    DateTime Function()? now,
    this._policy = const AdPolicyManager(),
    Future<bool> Function()? isOnline,
  })  : _now = now ?? DateTime.now,
        _isOnline = isOnline ?? _defaultOnline;

  final AdService service;
  final ConsentService consent;
  final SubscriptionService subscription;
  final SettingsRepository settings;
  final RemoteConfigService remote;
  final Future<int> Function() totalLogs;
  final Future<int> Function() installAgeDays;
  final DateTime Function() _now;
  final AdPolicyManager _policy;
  final Future<bool> Function() _isOnline;

  int _interstitialsThisSession = 0;

  static Future<bool> _defaultOnline() async {
    final r = await Connectivity().checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  }

  Future<AdDecision> decide(AdPlacement placement) async {
    final now = _now();
    final today = '${now.year}-${now.month}-${now.day}';
    final counterDate = await settings.getString(SettingKeys.adCounterDate);
    final interstitialsToday =
        counterDate == today ? (await settings.getInt(SettingKeys.adInterstitialsToday) ?? 0) : 0;
    final rewardedToday =
        counterDate == today ? (await settings.getInt('${SettingKeys.adInterstitialsToday}.rw') ?? 0) : 0;
    final cfg = remote.current;
    final kind = switch (placement.format) {
      AdFormat.banner => 'banner',
      AdFormat.native => 'native',
      AdFormat.interstitial => 'interstitial',
      AdFormat.rewarded => 'rewarded',
    };
    return _policy.decide(AdPolicyInput(
      placement: placement,
      now: now,
      isPro: subscription.current.isPro,
      canRequestAds: consent.canRequestAds,
      online: await _isOnline(),
      installAgeDays: await installAgeDays(),
      totalLogs: await totalLogs(),
      interstitialsToday: interstitialsToday,
      interstitialsThisSession: _interstitialsThisSession,
      rewardedToday: rewardedToday,
      lastAdShownAt: await settings.getTime(SettingKeys.adLastShown),
      rewardedEnabled: cfg.flags.isOn(Flag.rewardedAds),
      interstitialsEnabled: cfg.flags.isOn(Flag.interstitials),
      maxInterstitialsPerDay: cfg.maxInterstitialsPerDay,
      minMinutesBetweenAds: cfg.minMinutesBetweenAds,
      adUnitAvailable: service.unitAvailable(kind),
    ));
  }

  Future<void> _record(AdFormat f) async {
    final now = _now();
    final today = '${now.year}-${now.month}-${now.day}';
    final counterDate = await settings.getString(SettingKeys.adCounterDate);
    if (counterDate != today) {
      await settings.setString(SettingKeys.adCounterDate, today);
      await settings.setInt(SettingKeys.adInterstitialsToday, 0);
      await settings.setInt('${SettingKeys.adInterstitialsToday}.rw', 0);
    }
    if (f == AdFormat.interstitial) {
      _interstitialsThisSession++;
      await settings.setInt(SettingKeys.adInterstitialsToday,
          (await settings.getInt(SettingKeys.adInterstitialsToday) ?? 0) + 1);
      await settings.setTime(SettingKeys.adLastShown, now);
    }
    if (f == AdFormat.rewarded) {
      await settings.setInt('${SettingKeys.adInterstitialsToday}.rw',
          (await settings.getInt('${SettingKeys.adInterstitialsToday}.rw') ?? 0) + 1);
    }
  }

  /// Shows a full-screen interstitial if (and only if) policy allows it.
  Future<bool> maybeShowInterstitial(AdPlacement placement) async {
    if (placement.format != AdFormat.interstitial) return false;
    final d = await decide(placement);
    if (!d.allowed) return false;
    final shown = await service.showInterstitial();
    if (shown) await _record(AdFormat.interstitial);
    return shown;
  }

  /// User-initiated rewarded flow. Returns true when the reward was earned.
  Future<bool> showRewarded(AdPlacement placement) async {
    if (placement.format != AdFormat.rewarded) return false;
    final d = await decide(placement);
    if (!d.allowed) return false;
    final earned = await service.showRewarded();
    if (earned) await _record(AdFormat.rewarded);
    return earned;
  }
}
