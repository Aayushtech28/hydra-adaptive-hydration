import 'dart:async';

import 'package:drift/native.dart';
import 'package:hydra/application/composition.dart';
import 'package:hydra/application/hydra_core.dart';
import 'package:hydra/core/time/hydra_time.dart';
import 'package:hydra/data/database/app_database.dart';
import 'package:hydra/services/analytics/analytics_service.dart';
import 'package:hydra/services/error_reporter.dart';
import 'package:hydra/services/notifications/notification_service.dart';
import 'package:hydra/services/widgets/widget_publisher.dart';

class FakeNotificationService implements NotificationService {
  NotificationPermission perm = NotificationPermission.granted;
  int requestCalls = 0;
  List<ScheduledReminder> scheduled = [];
  int replaceCalls = 0;
  int cancelCalls = 0;
  ActionLabels? lastLabels;
  final _ctrl = StreamController<NotificationAction>.broadcast();

  @override
  Stream<NotificationAction> get actions => _ctrl.stream;
  @override
  Future<void> init({
    required ActionLabels labels,
    required String channelName,
    required String channelDescription,
  }) async {}
  @override
  Future<NotificationPermission> permission() async => perm;
  @override
  Future<NotificationPermission> requestPermission() async {
    requestCalls++;
    return perm;
  }

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required ActionLabels labels,
  }) async {
    replaceCalls++;
    lastLabels = labels;
    scheduled = List.of(reminders);
  }

  @override
  Future<void> cancelAll() async {
    cancelCalls++;
    scheduled = [];
  }

  @override
  Future<int> pendingCount() async => scheduled.length;
  @override
  Future<NotificationAction?> launchAction() async => null;
  @override
  Future<void> showTest({required String title, required String body}) async {}
}

class FakeWidgets implements WidgetPublisher {
  WidgetSnapshot? last;
  int publishes = 0;
  @override
  Future<void> publish(WidgetSnapshot s) async {
    last = s;
    publishes++;
  }
}

class Harness {
  Harness._(
    this.db,
    this.core,
    this.notifications,
    this.widgets,
    this.nowRef,
    this.tzRef,
  );

  final AppDatabase db;
  final HydraCore core;
  final FakeNotificationService notifications;
  final FakeWidgets widgets;
  final Ref<DateTime> nowRef;
  final Ref<String> tzRef;

  set now(DateTime t) => nowRef.value = t.toUtc();
  DateTime get now => nowRef.value;
  set timezone(String z) => tzRef.value = z;

  void advance(Duration d) => nowRef.value = nowRef.value.add(d);

  static Future<Harness> create({
    DateTime? start,
    String tz = 'Asia/Kolkata',
    bool onboarded = true,
  }) async {
    ensureTimeZonesInitialized();
    final db = AppDatabase(NativeDatabase.memory());
    final nowRef = Ref(start ?? DateTime.utc(2026, 10, 7, 3, 30)); // 09:00 IST
    final tzRef = Ref(tz);
    final notifications = FakeNotificationService();
    final widgets = FakeWidgets();
    final core = buildCore(
      db: db,
      notifications: notifications,
      widgets: widgets,
      analytics: AnalyticsService([]),
      errors: ErrorReporter(),
      timezoneName: () async => tzRef.value,
      clock: AppClock(source: () => nowRef.value),
    );
    await core.bootstrap();
    if (onboarded) await core.completeOnboarding();
    return Harness._(db, core, notifications, widgets, nowRef, tzRef);
  }

  /// Lets unawaited post-log pipelines finish.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    await core.reschedule(reason: 'test-settle');
  }

  Future<void> dispose() => db.close();
}

class Ref<T> {
  Ref(this.value);
  T value;
}
