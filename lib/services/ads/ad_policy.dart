/// Where an ad may appear. **There is deliberately no placement for the
/// dashboard, logging flow, notifications, widgets, onboarding, permission or
/// privacy screens** — an ad there is unrepresentable, not merely discouraged.
enum AdPlacement {
  historyBanner(AdFormat.banner),
  historyNative(AdFormat.native),
  insightsNative(AdFormat.native),
  discoverNative(AdFormat.native),

  /// Shown at most rarely when the user opens the detailed monthly analysis.
  monthlyAnalysisInterstitial(AdFormat.interstitial),

  rewardedTheme(AdFormat.rewarded),
  rewardedRecap(AdFormat.rewarded),
  rewardedVessel(AdFormat.rewarded);

  const AdPlacement(this.format);
  final AdFormat format;
}

enum AdFormat { banner, native, interstitial, rewarded }

enum AdDenyReason {
  none,
  pro,
  noConsent,
  tooNew,
  notActivated,
  intervalNotElapsed,
  sessionCap,
  dailyCap,
  rewardedCap,
  flagOff,
  offline,
  unavailable,
}

class AdDecision {
  const AdDecision(this.allowed, [this.reason = AdDenyReason.none]);
  final bool allowed;
  final AdDenyReason reason;
  static const AdDecision yes = AdDecision(true);
}

/// Everything the policy needs, gathered in one place so no screen can decide
/// to show an ad on its own.
class AdPolicyInput {
  const AdPolicyInput({
    required this.placement,
    required this.now,
    required this.isPro,
    required this.canRequestAds,
    required this.online,
    required this.installAgeDays,
    required this.totalLogs,
    required this.interstitialsToday,
    required this.interstitialsThisSession,
    required this.rewardedToday,
    this.lastAdShownAt,
    this.rewardedEnabled = true,
    this.interstitialsEnabled = true,
    this.maxInterstitialsPerDay = 2,
    this.minMinutesBetweenAds = 5,
    this.adUnitAvailable = true,
  });

  final AdPlacement placement;
  final DateTime now;
  final bool isPro;
  final bool canRequestAds;
  final bool online;
  final int installAgeDays;

  /// Lifetime number of hydration logs: ads wait until the product has
  /// proven its value (the user logged a few drinks).
  final int totalLogs;
  final int interstitialsToday;
  final int interstitialsThisSession;
  final int rewardedToday;
  final DateTime? lastAdShownAt;
  final bool rewardedEnabled;
  final bool interstitialsEnabled;
  final int maxInterstitialsPerDay;
  final int minMinutesBetweenAds;
  final bool adUnitAvailable;
}

/// The single authority on whether an ad may be requested/shown.
class AdPolicyManager {
  const AdPolicyManager();

  static const int minLogsBeforeAnyAd = 3;
  static const int minInstallDaysForInterstitial = 3;
  static const int maxRewardedPerDay = 5;

  AdDecision decide(AdPolicyInput i) {
    if (i.isPro) return const AdDecision(false, AdDenyReason.pro);
    if (!i.canRequestAds) return const AdDecision(false, AdDenyReason.noConsent);
    if (!i.adUnitAvailable) return const AdDecision(false, AdDenyReason.unavailable);
    if (!i.online) return const AdDecision(false, AdDenyReason.offline);

    final fmt = i.placement.format;
    if (fmt == AdFormat.rewarded) {
      if (!i.rewardedEnabled) return const AdDecision(false, AdDenyReason.flagOff);
      if (i.rewardedToday >= maxRewardedPerDay) {
        return const AdDecision(false, AdDenyReason.rewardedCap);
      }
      return AdDecision.yes; // optional, user-initiated
    }

    // Passive formats wait until the user has experienced the product.
    if (i.totalLogs < minLogsBeforeAnyAd) {
      return const AdDecision(false, AdDenyReason.notActivated);
    }
    if (i.installAgeDays < 1) return const AdDecision(false, AdDenyReason.tooNew);

    if (fmt == AdFormat.interstitial) {
      if (!i.interstitialsEnabled) return const AdDecision(false, AdDenyReason.flagOff);
      if (i.installAgeDays < minInstallDaysForInterstitial) {
        return const AdDecision(false, AdDenyReason.tooNew);
      }
      if (i.interstitialsThisSession >= 1) {
        return const AdDecision(false, AdDenyReason.sessionCap);
      }
      if (i.interstitialsToday >= i.maxInterstitialsPerDay) {
        return const AdDecision(false, AdDenyReason.dailyCap);
      }
      final last = i.lastAdShownAt;
      if (last != null &&
          i.now.difference(last).inMinutes < i.minMinutesBetweenAds) {
        return const AdDecision(false, AdDenyReason.intervalNotElapsed);
      }
    }
    return AdDecision.yes;
  }
}
