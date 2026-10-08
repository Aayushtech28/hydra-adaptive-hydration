import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/config/app_config.dart';
import '../../core/config/feature_flags.dart';
import '../../core/logging/log.dart';
import '../../data/repositories/misc_repositories.dart';
import '../../domain/challenges/challenges.dart';

/// Validated, bounded remote variables. **Safety-critical scheduler behaviour
/// is intentionally not remotely configurable**; the engine version is chosen
/// from bundled implementations only.
class RemoteConfig {
  const RemoteConfig({
    this.flags = const FeatureFlags(),
    this.challenges = const [],
    this.paywallHeadlineVariant = 0,
    this.maxInterstitialsPerDay = 2,
    this.minMinutesBetweenAds = 5,
    this.version = 0,
  });

  final FeatureFlags flags;
  final List<ChallengeDefinition> challenges;
  final int paywallHeadlineVariant;
  final int maxInterstitialsPerDay;
  final int minMinutesBetweenAds;
  final int version;

  static const RemoteConfig defaults = RemoteConfig();

  /// Parses untrusted JSON. Anything invalid falls back to defaults field by
  /// field; ad caps can only be made *stricter* than local maxima.
  static RemoteConfig parse(Object? raw) {
    if (raw is! Map) return defaults;
    final m = raw.cast<String, Object?>();
    final flags = const FeatureFlags().withRemote(
      (m['flags'] is Map)
          ? (m['flags']! as Map).cast<String, Object?>()
          : const {},
    );
    final chs = <ChallengeDefinition>[];
    if (m['challenges'] is List) {
      for (final c in (m['challenges']! as List)) {
        if (c is Map) {
          final d = ChallengeDefinition.fromJson(c.cast<String, Object?>());
          if (d != null) chs.add(d);
        }
      }
    }
    int boundedInt(Object? v, int fallback, int min, int max) =>
        v is int && v >= min && v <= max ? v : fallback;
    return RemoteConfig(
      flags: flags,
      challenges: chs,
      paywallHeadlineVariant: boundedInt(m['paywallHeadlineVariant'], 0, 0, 3),
      maxInterstitialsPerDay: boundedInt(m['maxInterstitialsPerDay'], 2, 0, 2),
      minMinutesBetweenAds: boundedInt(m['minMinutesBetweenAds'], 5, 5, 240),
      version: boundedInt(m['version'], 0, 0, 1 << 30),
    );
  }

  List<ChallengeDefinition> get effectiveChallenges =>
      challenges.isEmpty ? ChallengeDefinition.defaults : challenges;
}

abstract class RemoteConfigService {
  RemoteConfig get current;
  Future<void> load();
  Future<void> refresh();
}

/// Loads the cache immediately (offline-safe) and refreshes in the background.
class HttpRemoteConfigService implements RemoteConfigService {
  HttpRemoteConfigService(
    this._settings, {
    HttpClient Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? HttpClient.new;

  final SettingsRepository _settings;
  final HttpClient Function() _clientFactory;
  RemoteConfig _current = RemoteConfig.defaults;

  @override
  RemoteConfig get current => _current;

  @override
  Future<void> load() async {
    try {
      final cached = await _settings.getString(SettingKeys.remoteConfigCache);
      if (cached != null) _current = RemoteConfig.parse(jsonDecode(cached));
    } catch (_) {
      _current = RemoteConfig.defaults;
    }
  }

  @override
  Future<void> refresh() async {
    const url = AppConfig.remoteConfigUrl;
    if (url.isEmpty) return; // not configured: bundled defaults stay in force
    final client = _clientFactory()
      ..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client
          .getUrl(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      final res = await req.close().timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return;
      final body = await res
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 8));
      if (body.length > 64 * 1024) return;
      final parsed = RemoteConfig.parse(jsonDecode(body));
      _current = parsed;
      await _settings.setString(SettingKeys.remoteConfigCache, body);
    } on Object catch (e) {
      Log.info(
        'remote_config',
        'refresh failed; keeping current',
        fields: {'type': e.runtimeType.toString()},
      );
    } finally {
      client.close(force: true);
    }
  }
}
