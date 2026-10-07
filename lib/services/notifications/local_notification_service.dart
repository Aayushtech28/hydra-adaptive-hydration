import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/logging/log.dart';
import '../../core/time/hydra_time.dart';
import 'notification_service.dart';

const String kReminderChannelId = 'hydra_reminders';
const String kReminderCategory = 'hydra_reminder';

/// Hook for notification responses delivered to a *background isolate*
/// (app terminated or in background). Registered by the app entrypoint.
typedef BackgroundResponseHandler = void Function(NotificationResponse);

/// flutter_local_notifications-backed implementation.
///
/// * Uses inexact (Doze-friendly) scheduling — no exact-alarm permission.
/// * Reminders are scheduled as a short rolling chain; any state change
///   replaces the chain (see HydrationScheduler.planChain).
/// * Android: boot receiver (manifest) restores scheduled notifications.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    this.backgroundHandler,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final BackgroundResponseHandler? backgroundHandler;
  final StreamController<NotificationAction> _actions = StreamController.broadcast();
  String _channelName = 'Hydration check-ins';
  String _channelDescription = '';
  bool _initialized = false;

  @override
  Stream<NotificationAction> get actions => _actions.stream;

  @override
  Future<void> init({
    required ActionLabels labels,
    required String channelName,
    required String channelDescription,
  }) async {
    ensureTimeZonesInitialized();
    _channelName = channelName;
    _channelDescription = channelDescription;
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Permissions are requested contextually, never at launch.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [_category(labels)],
        ),
      ),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );
    _initialized = true;
  }

  DarwinNotificationCategory _category(ActionLabels labels) => DarwinNotificationCategory(
        kReminderCategory,
        actions: [
          for (final a in labels.logActions)
            DarwinNotificationAction.plain(NotificationAction.logActionId(a.ml), a.label),
          DarwinNotificationAction.plain(NotificationAction.snoozeId, labels.snooze),
        ],
      );

  void _onResponse(NotificationResponse r) {
    final a = NotificationAction.parse(actionId: r.actionId, payload: r.payload);
    if (a != null) _actions.add(a);
  }

  @override
  Future<NotificationPermission> permission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final ok = await android?.areNotificationsEnabled();
        return ok == true ? NotificationPermission.granted : NotificationPermission.denied;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final p = await ios?.checkPermissions();
        if (p == null) return NotificationPermission.notDetermined;
        if (p.isEnabled) return NotificationPermission.granted;
        // iOS reports "not determined" and "denied" identically through
        // checkPermissions; treat as notDetermined until a request occurred.
        return NotificationPermission.notDetermined;
      }
    } catch (e, st) {
      Log.error('notifications', 'permission check failed', error: e, stack: st);
    }
    return NotificationPermission.denied;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final ok = await android?.requestNotificationsPermission();
        return ok == true ? NotificationPermission.granted : NotificationPermission.denied;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        final ok = await ios?.requestPermissions(alert: true, badge: false, sound: true);
        return ok == true ? NotificationPermission.granted : NotificationPermission.denied;
      }
    } catch (e, st) {
      Log.error('notifications', 'permission request failed', error: e, stack: st);
    }
    return NotificationPermission.denied;
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders, {required ActionLabels labels}) async {
    if (!_initialized) return;
    await _plugin.cancelAllPendingNotifications();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        kReminderChannelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
        actions: [
          for (final a in labels.logActions)
            AndroidNotificationAction(NotificationAction.logActionId(a.ml), a.label),
          AndroidNotificationAction(NotificationAction.snoozeId, labels.snooze),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: kReminderCategory,
        threadIdentifier: 'hydra',
        interruptionLevel: InterruptionLevel.active,
      ),
    );
    final now = DateTime.now().toUtc();
    for (final r in reminders) {
      if (!r.at.toUtc().isAfter(now)) continue;
      try {
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: NotificationAction.payloadFor(r.eventId),
        );
      } catch (e, st) {
        Log.error('notifications', 'schedule failed', error: e, stack: st);
        rethrow;
      }
    }
  }

  @override
  Future<void> showTest({required String title, required String body}) async {
    if (!_initialized) return;
    await _plugin.show(
      id: 3999,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(kReminderChannelId, _channelName, channelDescription: _channelDescription),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAllPendingNotifications();

  @override
  Future<int> pendingCount() async => (await _plugin.pendingNotificationRequests()).length;

  @override
  Future<NotificationAction?> launchAction() async {
    final d = await _plugin.getNotificationAppLaunchDetails();
    final r = d?.notificationResponse;
    if (d?.didNotificationLaunchApp != true || r == null) return null;
    return NotificationAction.parse(actionId: r.actionId, payload: r.payload);
  }
}
