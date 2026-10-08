import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/logging/log.dart';

enum ConsentState { unknown, required, notRequired, obtained }

/// Wraps Google's User Messaging Platform. Ads are only ever requested when
/// [canRequestAds] is true. Failure to reach UMP means *no ads*, never
/// ads-without-consent.
abstract class ConsentService {
  ConsentState get status;
  bool get canRequestAds;
  bool get privacyOptionsRequired;

  /// True when the user is in a region requiring consent (EEA/UK etc.).
  bool get regionRequiresConsent;
  Stream<bool> get canRequestAdsChanges;

  /// Refreshes consent info (call every launch) and shows the form if
  /// required. Never blocks the UI for long and never throws.
  Future<void> gather();
  Future<void> showPrivacyOptions();
  Future<void> resetForTesting();
}

class UmpConsentService implements ConsentService {
  final StreamController<bool> _changes = StreamController.broadcast();
  ConsentState _status = ConsentState.unknown;
  bool _canRequest = false;
  bool _privacyOptions = false;

  @override
  ConsentState get status => _status;
  @override
  bool get canRequestAds => _canRequest;
  @override
  bool get privacyOptionsRequired => _privacyOptions;
  @override
  bool get regionRequiresConsent =>
      _status == ConsentState.required || _status == ConsentState.obtained;
  @override
  Stream<bool> get canRequestAdsChanges => _changes.stream;

  @override
  Future<void> gather() async {
    final done = Completer<void>();
    // The UMP plugin reports some platform failures asynchronously (e.g. the
    // plugin is unavailable on this platform), outside any try/catch. A
    // guarded zone turns those into "no ads", never a crash.
    unawaited(runZonedGuarded(() async {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((FormError? err) async {
              if (err != null) {
                Log.warning('consent', 'consent form error', fields: {'code': err.errorCode});
              }
              await _refresh();
              if (!done.isCompleted) done.complete();
            });
          } catch (_) {
            await _refresh();
            if (!done.isCompleted) done.complete();
          }
        },
        (FormError err) async {
          Log.warning('consent', 'consent info update failed', fields: {'code': err.errorCode});
          await _refresh();
          if (!done.isCompleted) done.complete();
        },
      );
    }, (e, st) {
      Log.warning('consent', 'consent unavailable; ads stay off', fields: {'type': e.runtimeType.toString()});
      _canRequest = false;
      if (!done.isCompleted) done.complete();
    }));
    await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
  }

  Future<void> _refresh() async {
    final info = ConsentInformation.instance;
    final s = await info.getConsentStatus();
    _status = switch (s) {
      ConsentStatus.required => ConsentState.required,
      ConsentStatus.notRequired => ConsentState.notRequired,
      ConsentStatus.obtained => ConsentState.obtained,
      _ => ConsentState.unknown,
    };
    final before = _canRequest;
    _canRequest = await info.canRequestAds();
    _privacyOptions = await info.getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    if (before != _canRequest) _changes.add(_canRequest);
  }

  @override
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((err) async {
        await _refresh();
        if (!done.isCompleted) done.complete();
      });
      await done.future.timeout(const Duration(seconds: 60), onTimeout: () {});
    } catch (e, st) {
      Log.error('consent', 'privacy options failed', error: e, stack: st);
    }
  }

  @override
  Future<void> resetForTesting() async {
    await ConsentInformation.instance.reset();
    await _refresh();
  }
}

/// Used when ads are impossible/disabled (tests, unsupported platforms).
class NoConsentService implements ConsentService {
  @override
  ConsentState get status => ConsentState.unknown;
  @override
  bool get canRequestAds => false;
  @override
  bool get privacyOptionsRequired => false;
  @override
  bool get regionRequiresConsent => true;
  @override
  Stream<bool> get canRequestAdsChanges => const Stream.empty();
  @override
  Future<void> gather() async {}
  @override
  Future<void> showPrivacyOptions() async {}
  @override
  Future<void> resetForTesting() async {}
}
