import 'dart:io' show Platform;

import '../app/services.dart';
import '../data/database/app_database.dart';
import '../services/health/health_service.dart';

/// Sanitised, support-friendly report. Contains configuration and state only
/// — **never** hydration history, amounts, or health records.
Future<String> buildDiagnosticsReport(AppServices svc, {required String version}) async {
  final core = svc.core;
  final profile = await core.profiles.get();
  final perm = await svc.notifications.permission();
  final health = await svc.health.permission();
  final avail = await svc.health.availability();
  final decisionJson = await core.settings.getJson('sched.lastDecision');
  final b = StringBuffer()
    ..writeln('HYDRA diagnostics')
    ..writeln('app: $version')
    ..writeln('os: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}')
    ..writeln('timezone: ${await core.timezoneName()}')
    ..writeln('locale: ${profile?.locale ?? 'unknown'}')
    ..writeln('db schema: $kSchemaVersion')
    ..writeln('notifications: ${perm.name}')
    ..writeln('reminders enabled: ${profile?.remindersEnabled}')
    ..writeln('reminder mode: ${profile?.mode.name}')
    ..writeln('scheduled notifications: ${await svc.notifications.pendingCount()}')
    ..writeln('scheduler state: ${decisionJson['state']}')
    ..writeln('scheduler algorithm: ${decisionJson['algorithm']}')
    ..writeln('scheduler reasons: ${decisionJson['reasons']}')
    ..writeln('health availability: ${avail.name}')
    ..writeln('health permission: ${health == HealthPermissionState.granted ? 'granted' : health.name}')
    ..writeln('subscription: ${svc.subscription.current.status.name}')
    ..writeln('ad consent: ${svc.consent.status.name}, canRequestAds=${svc.consent.canRequestAds}');
  return b.toString();
}
