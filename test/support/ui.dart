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
import 'package:hydra/services/health/health_service.dart';
import 'package:hydra/services/purchase/subscription_service.dart';

import 'harness.dart';

/// Advance fake time while letting real async work (SQLite) finish. The
/// dashboard animates forever, so pumpAndSettle can't be used.
Future<void> settle(WidgetTester t, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await t.pump(const Duration(milliseconds: 100));
  }
}

class UiEnv {
  UiEnv(this.services, this.notifications);
  final AppServices services;
  final FakeNotificationService notifications;
}

Future<UiEnv> bootApp(
  WidgetTester t, {
  bool onboarded = true,
  double textScale = 1.0,
  SubscriptionService? subscription,
  HealthService? health,
  bool tall = false,
}) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  // `tall` lets content-heavy pages render without scrolling in assertions.
  t.view.physicalSize = Size(1080, tall ? 5400 : 2400);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearTextScaleFactorTestValue();
  });
  final n = FakeNotificationService();
  final s = await AppServices.assemble(
    db: AppDatabase(NativeDatabase.memory()),
    notifications: n,
    widgets: FakeWidgets(),
    timezone: () async => 'Asia/Kolkata',
    subscription: subscription,
    healthService: health,
  );
  if (onboarded) await s.core.completeOnboarding();
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        servicesProvider.overrideWithValue(s),
        initialOnboardedProvider.overrideWithValue(onboarded),
      ],
      child: const HydraApp(),
    ),
  );
  await settle(t, 20);
  return UiEnv(s, n);
}

Future<void> disposeApp(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 1));
}

Future<void> openTab(WidgetTester t, String name) async {
  await t.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(name)),
  );
  await settle(t, 8);
}

/// Navigates You → [label] (scrolling it into view).
Future<void> openYouPage(WidgetTester t, String label) async {
  await openTab(t, 'You');
  await tapVisible(t, find.text(label));
  await settle(t, 10);
}

/// Scrolls the nearest scrollable until [f] is built and on screen, then taps it.
Future<void> tapVisible(WidgetTester t, Finder f, {Finder? within}) async {
  // A focused text field scrolls itself back into view on rebuild; drop focus
  // so the scroll position we set up is stable.
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pump();
  await t.scrollUntilVisible(
    f,
    250,
    scrollable:
        (within ??
                find.descendant(
                  of: find.byType(ListView).last,
                  matching: find.byType(Scrollable),
                ))
            .first,
    maxScrolls: 60,
  );
  await settle(t, 2);
  await t.tap(f.first);
}
