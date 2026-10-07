import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../core/config/app_config.dart';
import '../core/logging/log.dart';

/// Error categories surfaced in dashboards (see docs: severity mapping).
enum ErrorArea { flutter, native, notifications, health, purchases, widgets, database, other }

/// Central crash/error pipeline. Always records locally (redacted ring
/// buffer for support diagnostics); forwards to Crashlytics only when
/// configured **and** the user allows diagnostics. Messages are scrubbed of
/// volumes, dates and emails before leaving the device.
class ErrorReporter {
  ErrorReporter();

  bool _remoteEnabled = false;
  bool _crashlyticsReady = false;

  Future<void> init() async {
    if (!AppConfig.firebaseEnabled) return;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      _crashlyticsReady = true;
    } catch (e) {
      Log.info('crash', 'crashlytics unavailable', fields: {'type': e.runtimeType.toString()});
    }
  }

  Future<void> setRemoteEnabled(bool v) async {
    _remoteEnabled = v;
    if (_crashlyticsReady) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(v);
    }
  }

  /// Installs global handlers. Call once, before `runApp`.
  void installGlobalHandlers() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      record(details.exception, details.stack, ErrorArea.flutter, fatal: false);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      record(error, stack, ErrorArea.native, fatal: true);
      return true;
    };
  }

  void record(Object error, StackTrace? stack, ErrorArea area, {bool fatal = false}) {
    Log.error(area.name, Redactor.scrub(error.toString()), error: error, stack: stack);
    if (_remoteEnabled && _crashlyticsReady) {
      unawaited(FirebaseCrashlytics.instance.recordError(
        Exception('${error.runtimeType}: ${Redactor.scrub(error.toString())}'),
        stack,
        reason: area.name,
        fatal: fatal,
      ));
    }
  }

  /// Wraps an async operation so failures are reported but never thrown into
  /// core flows (notifications, health, purchases are all non-fatal).
  Future<T?> guard<T>(ErrorArea area, Future<T> Function() op) async {
    try {
      return await op();
    } catch (e, st) {
      record(e, st, area);
      return null;
    }
  }
}
