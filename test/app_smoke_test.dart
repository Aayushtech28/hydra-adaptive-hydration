import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/app/app.dart';
import 'package:hydra/app/providers.dart';
import 'package:hydra/app/router.dart';
import 'package:hydra/app/services.dart';
import 'package:hydra/data/database/app_database.dart';

import 'package:hydra/services/notifications/notification_service.dart';

import 'support/harness.dart';

Future<(AppServices, FakeNotificationService)> testServices() async {
  final n = FakeNotificationService();
  final s = await AppServices.assemble(
    db: AppDatabase(NativeDatabase.memory()),
    notifications: n,
    widgets: FakeWidgets(),
    timezone: () async => 'Asia/Kolkata',
  );
  return (s, n);
}

Widget _app(AppServices s, {required bool onboarded}) => ProviderScope(
  overrides: [
    servicesProvider.overrideWithValue(s),
    initialOnboardedProvider.overrideWithValue(onboarded),
  ],
  child: const HydraApp(),
);

/// The dashboard has perpetual animations (water wave, minute ticker), so
/// pumpAndSettle would never finish; advance time explicitly instead.
Future<void> settle(WidgetTester t, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    // Let real async work (SQLite) complete, then advance fake time.
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  testWidgets('fresh install: onboarding → dashboard → log → tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final (s, n) = await testServices();
    await tester.pumpWidget(_app(s, onboarded: false));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.text('Hydration that adapts to your day.'), findsWidgets);
    await tester.tap(find.text('Get started'));
    for (var i = 0; i < 5; i++) {
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      await tester.tap(find.text('Continue'));
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Your hydration rhythm is ready.'), findsOneWidget);
    await tester.tap(find.text('Start without reminders'));
    await settle(tester, 20);

    // Dashboard
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('First day starts here.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('First day starts here.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('+250 ml'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quick add'), findsOneWidget);

    // One-tap log
    await tester.tap(find.text('+250 ml'));
    await settle(tester);
    expect(find.textContaining('Logged'), findsOneWidget);
    expect(await s.core.hydration.totalForDay(await s.core.today()), 250);

    // Tabs
    for (final tab in ['History', 'Insights', 'You', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await settle(tester);
    }
    expect(n.scheduled, isA<List<ScheduledReminder>>());
    // Dispose the widget tree (cancels timers/streams). The in-memory DB is
    // left to GC: drift's close() waits on fake-async timers in widget tests.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('returning user lands on the dashboard; settings pages open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final (s, _) = await testServices();
    await s.core.completeOnboarding();
    await tester.pumpWidget(_app(s, onboarded: true));
    await settle(tester, 20);
    expect(find.text('Quick add'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('You'),
      ),
    );
    await settle(tester);
    for (final label in [
      'Daily target',
      'Wake and sleep',
      'Vessels',
      'Routines',
      'Privacy Center',
      'Health sync',
      'Appearance',
      'Help and support',
      'Notifications',
    ]) {
      await tester.ensureVisible(find.text(label).first);
      await settle(tester, 2);
      await tester.tap(find.text(label).first);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: label);
      await tester.pageBack();
      await settle(tester);
    }
    // Dispose the widget tree (cancels timers/streams). The in-memory DB is
    // left to GC: drift's close() waits on fake-async timers in widget tests.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
