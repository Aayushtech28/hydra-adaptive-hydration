import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' show NotificationResponse;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../application/composition.dart';
import '../application/hydra_core.dart';
import '../application/reminder_coordinator.dart';
import '../core/config/app_config.dart';
import '../core/config/feature_flags.dart';
import '../core/logging/log.dart';
import '../core/time/hydra_time.dart';
import '../data/database/app_database.dart';
import '../data/repositories/misc_repositories.dart';
import '../services/ads/ad_coordinator.dart';
import '../services/ads/ad_service.dart';
import '../services/ads/consent_service.dart';
import '../services/analytics/analytics_service.dart';
import '../services/error_reporter.dart';
import '../services/export/export_service.dart';
import '../services/health/health_service.dart';
import '../services/health/health_sync_service.dart';
import '../services/notifications/local_notification_service.dart';
import '../services/notifications/notification_service.dart';
import '../services/purchase/subscription_service.dart';
import '../services/remote_config/remote_config.dart';
import '../services/smart_bottle/smart_bottle_service.dart';
import '../services/widgets/widget_publisher.dart';

/// Composition root for the UI isolate. Holds every singleton; screens reach
/// it only through Riverpod providers.
class AppServices {
  AppServices._({
    required this.db,
    required this.core,
    required this.notifications,
    required this.errors,
    required this.analytics,
    required this.subscription,
    required this.consent,
    required this.ads,
    required this.adCoordinator,
    required this.health,
    required this.healthSync,
    required this.export,
    required this.remote,
    required this.smartBottle,
    required this.clock,
  });

  final AppDatabase db;
  final HydraCore core;
  final NotificationService notifications;
  final ErrorReporter errors;
  final AnalyticsService analytics;
  final SubscriptionService subscription;
  final ConsentService consent;
  final AdService ads;
  final AdCoordinator adCoordinator;
  final HealthService health;
  final HealthSyncService healthSync;
  final ExportService export;
  final RemoteConfigService remote;
  final SmartBottleService smartBottle;
  final AppClock clock;

  static String _cachedZone = 'UTC';

  /// Device IANA timezone; falls back to the last known value on failure.
  static Future<String> deviceTimezone() async {
    try {
      _cachedZone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {}
    return _cachedZone;
  }

  static String get systemLocaleCode => ui.PlatformDispatcher.instance.locale.toLanguageTag();

  /// Local-data-only startup. No network, no ad/consent/purchase SDKs: the
  /// dashboard can render as soon as this returns.
  static Future<AppServices> create() async => assemble(
        db: await AppDatabase.openOnDevice(),
        notifications: LocalNotificationService(backgroundHandler: hydraBackgroundNotificationHandler),
        widgets: HomeWidgetPublisher(),
      );

  /// Builds the graph from injectable parts (used by [create] and by tests).
  /// Optional platform services that fail to initialise degrade silently.
  static Future<AppServices> assemble({
    required AppDatabase db,
    required NotificationService notifications,
    required WidgetPublisher widgets,
    AppClock? clock,
    Future<String> Function()? timezone,
  }) async {
    ensureTimeZonesInitialized();
    final c = clock ?? AppClock();
    final errors = ErrorReporter();
    final analytics = AnalyticsService([LogAnalyticsSink()]);
    final settings = SettingsRepository(db);
    final remote = HttpRemoteConfigService(settings);
    await remote.load();

    final core = buildCore(
      db: db,
      notifications: notifications,
      widgets: widgets,
      analytics: analytics,
      errors: errors,
      timezoneName: timezone ?? deviceTimezone,
      clock: c,
      flags: () => remote.current.flags,
      localeCode: () => null,
    );
    await core.bootstrap(locale: systemLocaleCode);
    try {
      await _initNotifications(core, notifications);
    } catch (e, st) {
      // Notifications unavailable: tracking and everything else still works.
      Log.error('notifications', 'init failed; continuing without', error: e, stack: st);
    }

    final subscription = RevenueCatSubscriptionService(settings);
    final consent = UmpConsentService();
    final ads = AdMobService();
    final health = PlatformHealthService();
    return AppServices._(
      db: db,
      core: core,
      notifications: notifications,
      errors: errors,
      analytics: analytics,
      subscription: subscription,
      consent: consent,
      ads: ads,
      adCoordinator: AdCoordinator(
        service: ads,
        consent: consent,
        subscription: subscription,
        settings: settings,
        remote: remote,
        totalLogs: core.totalLogCount,
        installAgeDays: core.installAgeDays,
        now: c.now,
      ),
      health: health,
      healthSync: HealthSyncService(
        health: health,
        hydration: core.hydration,
        settings: settings,
        timezoneName: () => _cachedZone,
        now: c.now,
      ),
      export: ExportService(
        hydration: core.hydration,
        vessels: core.vessels,
        routines: core.routines,
        profile: core.profiles,
        now: c.now,
      ),
      remote: remote,
      smartBottle: UnsupportedSmartBottleService(),
      clock: c,
    );
  }

  /// Work that touches the network or third-party SDKs; started *after* the
  /// first frame so utility comes first. Every step is independently
  /// fault-tolerant.
  Future<void> deferredInit() async {
    await errors.init();
    final fb = await FirebaseAnalyticsSink.tryCreate();
    if (fb != null) analytics.addSink(fb);

    unawaited(errors.guard(ErrorArea.purchases, subscription.start));
    unawaited(errors.guard(ErrorArea.other, remote.refresh));
    await errors.guard(ErrorArea.other, () async {
      await consent.gather();
      // Diagnostics/analytics defaults follow the privacy region.
      final settings = core.settings;
      final stored = await settings.getString(SettingKeys.analyticsEnabled);
      final enabled = stored == null ? !consent.regionRequiresConsent : stored == '1';
      await analytics.setEnabled(enabled);
      await errors.setRemoteEnabled(enabled);
      if (consent.canRequestAds && !subscription.current.isPro) {
        await ads.initialize();
      }
    });
    consent.canRequestAdsChanges.listen((can) {
      if (can && !subscription.current.isPro) unawaited(ads.initialize());
    });
    analytics.log(AnalyticsEvent.appOpen);
  }

  static Future<void> _initNotifications(HydraCore core, NotificationService n) async {
    final ctx = await core.plans.load(core.clock.now().toUtc());
    final l = localizationsFor(ctx.profile.locale);
    await n.init(
      labels: core.coordinator.labelsFor(ctx, l),
      channelName: l.notifChannelName,
      channelDescription: l.notifChannelDescription,
    );
  }

  /// Applies a user-visible analytics preference.
  Future<void> setAnalyticsEnabled(bool v) async {
    await core.settings.setString(SettingKeys.analyticsEnabled, v ? '1' : '0');
    await analytics.setEnabled(v);
    await errors.setRemoteEnabled(v);
  }

  bool get debugToolsAvailable => AppConfig.debugToolsAvailable;
  FeatureFlags get flags => remote.current.flags;
}

/// Entry point for notification responses delivered when the app is not in
/// the foreground (including terminated). Runs the *same* [HydraCore] logic
/// — persist, recompute, reschedule, widget — without opening the UI.
@pragma('vm:entry-point')
Future<void> hydraBackgroundNotificationHandler(NotificationResponse r) async {
  final action = NotificationAction.parse(actionId: r.actionId, payload: r.payload);
  if (action == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase? db;
  try {
    ensureTimeZonesInitialized();
    db = await AppDatabase.openOnDevice();
    final notifications = LocalNotificationService();
    final core = buildCore(
      db: db,
      notifications: notifications,
      widgets: HomeWidgetPublisher(),
      analytics: AnalyticsService([]),
      errors: ErrorReporter(),
      timezoneName: AppServices.deviceTimezone,
    );
    await core.bootstrap();
    await AppServices._initNotifications(core, notifications);
    await core.handleNotificationAction(action);
    // Let the post-log reschedule finish before the isolate is torn down.
    await core.reschedule(reason: 'background_action');
  } catch (e, st) {
    Log.error('notifications', 'background handler failed', error: e, stack: st);
  } finally {
    await db?.close();
  }
}
