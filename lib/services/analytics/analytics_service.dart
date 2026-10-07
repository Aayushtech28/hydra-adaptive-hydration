import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/config/app_config.dart';
import '../../core/logging/log.dart';

/// The closed set of product events. Anything not listed here cannot be sent,
/// and no event carries hydration amounts, history or health data.
enum AnalyticsEvent {
  appOpen('app_open'),
  onboardingStarted('onboarding_started'),
  onboardingCompleted('onboarding_completed'),
  notificationPermissionGranted('notification_permission_granted'),
  notificationPermissionDenied('notification_permission_denied'),
  hydrationLogged('hydration_logged'),
  vesselCreated('vessel_created'),
  reminderSnoozed('reminder_snoozed'),
  reminderActionUsed('reminder_action_used'),
  healthSyncEnabled('health_sync_enabled'),
  paywallViewed('paywall_viewed'),
  premiumStarted('premium_started'),
  premiumRestored('premium_restored'),
  rewardedCompleted('rewarded_completed'),
  widgetAdded('widget_added'),
  fewerRemindersAccepted('fewer_reminders_accepted'),
  dataExported('data_exported'),
  dataDeleted('data_deleted'),
  feedbackGiven('feedback_given');

  const AnalyticsEvent(this.wireName);
  final String wireName;
}

/// Allowed parameter keys → permitted value kinds. Numeric hydration values
/// are not representable.
const Map<String, Type> kAllowedAnalyticsParams = {
  'source': String, // manual | notification | widget | health
  'placement': String,
  'plan': String, // monthly | annual | lifetime
  'platform': String,
  'mode': String, // gentle | balanced | focus
  'rating': String,
  'has_vessel': bool,
};

abstract class AnalyticsSink {
  Future<void> log(String name, Map<String, Object> params);
  Future<void> setEnabled(bool enabled);
}

class AnalyticsService {
  AnalyticsService(List<AnalyticsSink> sinks) : _sinks = [...sinks];
  final List<AnalyticsSink> _sinks;

  void addSink(AnalyticsSink s) {
    _sinks.add(s);
    unawaited(s.setEnabled(_enabled));
  }
  bool _enabled = false;

  bool get enabled => _enabled;

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    for (final s in _sinks) {
      await s.setEnabled(v);
    }
  }

  /// Sanitises params against the allow-list; drops everything else.
  static Map<String, Object> sanitize(Map<String, Object?> params) {
    final out = <String, Object>{};
    params.forEach((k, v) {
      final t = kAllowedAnalyticsParams[k];
      if (t == null || v == null) return;
      if (t == String && v is String) out[k] = v.length > 40 ? v.substring(0, 40) : v;
      if (t == bool && v is bool) out[k] = v;
    });
    return out;
  }

  void log(AnalyticsEvent e, [Map<String, Object?> params = const {}]) {
    if (!_enabled) return;
    final clean = sanitize(params);
    for (final s in _sinks) {
      unawaited(s.log(e.wireName, clean).catchError((Object _) {}));
    }
  }
}

/// Firebase Analytics sink. Safe without configuration: if
/// `Firebase.initializeApp` fails (no google-services files), it silently
/// disables itself and the app is unaffected.
class FirebaseAnalyticsSink implements AnalyticsSink {
  FirebaseAnalytics? _fa;

  static Future<FirebaseAnalyticsSink?> tryCreate() async {
    if (!AppConfig.firebaseEnabled) return null;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final s = FirebaseAnalyticsSink().._fa = FirebaseAnalytics.instance;
      // Default OFF until explicitly enabled by AnalyticsService.
      await s._fa!.setAnalyticsCollectionEnabled(false);
      return s;
    } catch (e) {
      Log.info('analytics', 'firebase unavailable', fields: {'type': e.runtimeType.toString()});
      return null;
    }
  }

  @override
  Future<void> log(String name, Map<String, Object> params) async =>
      _fa?.logEvent(name: name, parameters: params);

  @override
  Future<void> setEnabled(bool enabled) async => _fa?.setAnalyticsCollectionEnabled(enabled);
}

/// Development sink: prints events to the structured log.
class LogAnalyticsSink implements AnalyticsSink {
  @override
  Future<void> log(String name, Map<String, Object> params) async =>
      Log.debug('analytics', name, fields: {'count': params.length});
  @override
  Future<void> setEnabled(bool enabled) async {}
}
