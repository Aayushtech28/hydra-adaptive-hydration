/// Remotely-togglable features. Every flag has a safe local default; a broken
/// or missing remote value can only ever fall back to these.
enum Flag {
  adaptiveSchedulerV1('adaptive_scheduler_v1', true),
  whyNow('why_now', true),
  smartQuietHours('smart_quiet_hours', true),
  advancedInsights('advanced_insights', true),
  weather('weather', false),
  healthSync('health_sync', true),
  advancedWidgets('advanced_widgets', true),
  premiumV2('premium_v2', false),
  rewardedAds('rewarded_ads', true),
  watchBeta('watch_beta', false),
  smartBottleBeta('smart_bottle_beta', false),
  interstitials('interstitials', true);

  const Flag(this.key, this.defaultValue);
  final String key;
  final bool defaultValue;
}

class FeatureFlags {
  const FeatureFlags([this._remote = const {}]);
  final Map<String, bool> _remote;

  bool isOn(Flag f) => _remote[f.key] ?? f.defaultValue;

  /// Core tracking is *not* a flag: nothing here can disable logging.
  FeatureFlags withRemote(Map<String, Object?> raw) {
    final out = <String, bool>{};
    for (final f in Flag.values) {
      final v = raw[f.key];
      if (v is bool) out[f.key] = v;
    }
    return FeatureFlags(out);
  }
}
