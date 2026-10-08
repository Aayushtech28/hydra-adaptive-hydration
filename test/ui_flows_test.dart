import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/domain/models/enums.dart';
import 'package:hydra/services/purchase/entitlement.dart';
import 'package:hydra/services/purchase/subscription_service.dart';

import 'support/fakes.dart';
import 'support/ui.dart';

/// The timeline's edit affordance (the Custom chip reuses the same glyph).
final timelineEditIcon = find.byWidgetPredicate(
  (w) =>
      w is Icon && w.icon == Icons.edit_outlined && w.semanticLabel == 'Edit',
);

void main() {
  group('log sheet', () {
    testWidgets(
      'custom amount is validated, then persisted with undo offered',
      (t) async {
        final env = await bootApp(t);
        final core = env.services.core;
        await tapVisible(t, find.text('Custom'));
        await settle(t, 6);
        expect(find.text('Add hydration'), findsOneWidget);

        // invalid input disables the primary action
        await t.enterText(find.byType(TextField), 'abc');
        await settle(t, 2);
        expect(
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Log now'),
              )
              .onPressed,
          isNull,
        );
        await t.enterText(find.byType(TextField), '0');
        await settle(t, 2);
        expect(
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Log now'),
              )
              .onPressed,
          isNull,
        );

        await t.enterText(find.byType(TextField), '400');
        await settle(t, 2);
        await t.tap(find.widgetWithText(FilledButton, 'Log now'));
        await settle(t, 10);
        expect(await core.hydration.totalForDay(await core.today()), 400);
        expect(find.text('Undo'), findsOneWidget);
        await t.tap(find.text('Undo'));
        await settle(t, 10);
        expect(await core.hydration.totalForDay(await core.today()), 0);
        await disposeApp(t);
      },
    );

    testWidgets('stepper changes amount; vessel chip presets the volume', (
      t,
    ) async {
      final env = await bootApp(t);
      await tapVisible(t, find.text('Custom'));
      await settle(t, 6);
      await t.tap(find.byTooltip('+'));
      await settle(t, 2);
      expect(find.widgetWithText(TextField, '300'), findsOneWidget); // 250 + 50
      await t.tap(find.text('Desk bottle · 750 ml'));
      await settle(t, 2);
      expect(find.widgetWithText(TextField, '750'), findsOneWidget);
      await t.tap(find.widgetWithText(FilledButton, 'Log now'));
      await settle(t, 10);
      final e = (await env.services.core.hydration.all()).single;
      expect(e.volumeMl, 750);
      expect(e.vesselId, isNotNull);
      await disposeApp(t);
    });

    testWidgets('editing and deleting an entry from the timeline', (t) async {
      final env = await bootApp(t);
      final core = env.services.core;
      await core.log(volumeMl: 250);
      await settle(t, 10);
      await t.scrollUntilVisible(
        timelineEditIcon,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(timelineEditIcon);
      await settle(t, 6);
      expect(find.text('Edit entry'), findsOneWidget);
      await t.enterText(find.byType(TextField), '320');
      await settle(t, 2);
      await t.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(t, 10);
      expect((await core.hydration.all()).single.volumeMl, 320);

      await t.tap(timelineEditIcon);
      await settle(t, 6);
      // let the "Saved" snackbar leave before reaching the sheet's Delete button
      ScaffoldMessenger.of(t.element(find.byType(Scaffold).first))
          .clearSnackBars();
      await settle(t, 6);
      await t.tap(find.widgetWithText(TextButton, 'Delete'));
      await settle(t, 10);
      expect(await core.hydration.count(), 0);
      await disposeApp(t);
    });
  });

  group('onboarding persistence', () {
    testWidgets(
      'choices are saved; notifications are only requested on explicit consent',
      (t) async {
        final env = await bootApp(t, onboarded: false);
        await t.tap(find.text('Get started'));
        await settle(t, 6);
        await t.tap(find.text('Continue')); // wake
        await settle(t, 6);
        await t.tap(find.text('Continue')); // sleep
        await settle(t, 6);
        await t.tap(find.text('Focus'));
        await t.tap(find.text('Continue'));
        await settle(t, 6);
        await t.tap(find.text('Litres (L)'));
        await t.tap(find.text('Continue'));
        await settle(t, 6);
        await t.tap(find.text('Custom target'));
        await settle(t, 2);
        await t.enterText(find.byType(TextField), '3');
        await settle(t, 2);
        await t.tap(find.text('Continue'));
        await settle(t, 6);
        expect(env.notifications.requestCalls, 0);

        await t.tap(find.text('Start without reminders'));
        await settle(t, 20);
        final p = (await env.services.core.profiles.get())!;
        expect(p.onboardingComplete, isTrue);
        expect(p.mode, ReminderMode.focus);
        expect(p.dailyTargetMl, 3000);
        expect(p.targetIsUserChosen, isTrue);
        expect(p.unit.name, 'l');
        expect(env.notifications.requestCalls, 0); // declined: never asked
        expect(env.notifications.scheduled, isEmpty);
        await t.scrollUntilVisible(
          find.text('Quick add'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Quick add'), findsOneWidget);
        await disposeApp(t);
      },
    );

    testWidgets(
      '"Allow notifications" asks exactly once and schedules reminders',
      (t) async {
        final env = await bootApp(t, onboarded: false);
        await t.tap(find.text('Get started'));
        for (var i = 0; i < 5; i++) {
          await settle(t, 6);
          await t.tap(find.text('Continue'));
        }
        await settle(t, 6);
        await t.tap(find.text('Allow notifications'));
        await settle(t, 20);
        expect(env.notifications.requestCalls, 1);
        expect(env.notifications.scheduled, isNotEmpty);
        await disposeApp(t);
      },
    );

    testWidgets('an unreasonable target blocks Continue', (t) async {
      await bootApp(t, onboarded: false);
      await t.tap(find.text('Get started'));
      for (var i = 0; i < 4; i++) {
        await settle(t, 6);
        await t.tap(find.text('Continue'));
      }
      await settle(t, 6);
      await t.tap(find.text('Custom target'));
      await settle(t, 2);
      await t.enterText(find.byType(TextField), '50000');
      await settle(t, 2);
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull,
      );
      await disposeApp(t);
    });
  });

  group('settings editors persist', () {
    testWidgets('daily target', (t) async {
      final env = await bootApp(t);
      await openYouPage(t, 'Daily target');
      await t.tap(find.byTooltip('+'));
      await t.tap(find.byTooltip('+'));
      await settle(t, 2);
      await t.tap(find.widgetWithText(FilledButton, 'Save target'));
      await settle(t, 10);
      expect((await env.services.core.profiles.get())!.dailyTargetMl, 2600);
      await disposeApp(t);
    });

    testWidgets(
      'reminders toggle clears the schedule; turning back on restores it',
      (t) async {
        final env = await bootApp(t);
        await env.services.core.reschedule();
        expect(env.notifications.scheduled, isNotEmpty);
        await openYouPage(t, 'Notifications');
        await t.tap(find.byType(Switch).first);
        await settle(t, 12);
        expect(
          (await env.services.core.profiles.get())!.remindersEnabled,
          isFalse,
        );
        expect(env.notifications.scheduled, isEmpty);
        await t.tap(find.byType(Switch).first);
        await settle(t, 12);
        expect(env.notifications.scheduled, isNotEmpty);
        await disposeApp(t);
      },
    );

    testWidgets('weekend schedule toggle', (t) async {
      final env = await bootApp(t);
      await openYouPage(t, 'Wake and sleep');
      await t.tap(find.text('Different on weekends'));
      await settle(t, 10);
      expect(
        (await env.services.core.profiles.get())!.weekendDifferent,
        isTrue,
      );
      await disposeApp(t);
    });

    testWidgets('add a vessel; free limit is enforced', (t) async {
      final env = await bootApp(t);
      await openYouPage(t, 'Vessels');
      expect(find.text('Glass'), findsOneWidget);
      await t.tap(find.text('Add vessel'));
      await settle(t, 8);
      await t.enterText(find.widgetWithText(TextField, 'Name'), 'Mug');
      await t.enterText(find.widgetWithText(TextField, 'Volume (ml)'), '350');
      await t.tap(find.widgetWithText(FilledButton, 'Save'));
      await settle(t, 10);
      final names = (await env.services.core.vessels.getAll()).map(
        (v) => v.name,
      );
      expect(names, contains('Mug'));
      expect(names.length, 4);
      // fill to the free limit (5), then the 6th is refused with an explanation
      await env.services.core.vessels.upsert(name: 'Five', volumeMl: 100);
      await settle(t, 6);
      await t.tap(find.text('Add vessel'));
      await settle(t, 8);
      expect(find.textContaining('Free includes 5 vessels'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('create a routine from the editor', (t) async {
      final env = await bootApp(t);
      await openYouPage(t, 'Routines');
      await t.tap(find.text('Add routine').last);
      await settle(t, 10);
      await t.enterText(find.widgetWithText(TextField, 'Name'), 'Office');
      await tapVisible(t, find.widgetWithText(FilledButton, 'Save'));
      await settle(t, 12);
      final rs = await env.services.core.routines.getAll();
      expect(rs.single.name, 'Office');
      expect(rs.single.weekdays, {1, 2, 3, 4, 5});
      await disposeApp(t);
    });
  });

  group('paywall states', () {
    testWidgets(
      'store unavailable: explains, offers retry, free features untouched',
      (t) async {
        await bootApp(
          t,
          subscription: FakeSubscriptionService(available: false),
        );
        await openYouPage(t, 'HYDRA Pro');
        expect(
          find.text("Purchases aren't available right now"),
          findsOneWidget,
        );
        expect(find.text('Try again'), findsOneWidget);
        await disposeApp(t);
      },
    );

    testWidgets(
      'plans: annual is highlighted with trial; purchase success unlocks Pro',
      (t) async {
        final sub = FakeSubscriptionService();
        await bootApp(t, tall: true, subscription: sub);
        await t.tap(find.text('You').last);
        await settle(t, 6);
        await t.tap(find.text('HYDRA Pro').first);
        await settle(t, 12);
        expect(find.text('Best value'), findsOneWidget);
        expect(find.textContaining('7-day free trial'), findsOneWidget);
        expect(find.text('Restore purchases'), findsOneWidget);
        expect(find.text('Manage subscription'), findsOneWidget);
        await t.tap(find.widgetWithText(FilledButton, 'Continue'));
        await settle(t, 12);
        expect(sub.purchases, 1);
        expect(sub.current.isPro, isTrue);
        await disposeApp(t);
      },
    );

    testWidgets(
      'cancelled purchase charges nothing and keeps the paywall open',
      (t) async {
        final sub = FakeSubscriptionService()
          ..nextPurchase = PurchaseOutcome.cancelled;
        await bootApp(t, tall: true, subscription: sub);
        await t.tap(find.text('You').last);
        await settle(t, 6);
        await t.tap(find.text('HYDRA Pro').first);
        await settle(t, 12);
        await t.tap(find.widgetWithText(FilledButton, 'Continue'));
        await settle(t, 8);
        expect(find.text('No charge was made.'), findsOneWidget);
        expect(sub.current.isPro, isFalse);
        await disposeApp(t);
      },
    );

    testWidgets('restore with nothing to restore says so', (t) async {
      final sub = FakeSubscriptionService()
        ..nextRestore = PurchaseOutcome.failed;
      await bootApp(t, tall: true, subscription: sub);
      await t.tap(find.text('You').last);
      await settle(t, 6);
      await t.tap(find.text('HYDRA Pro').first);
      await settle(t, 12);
      await t.tap(find.text('Restore purchases'));
      await settle(t, 8);
      expect(find.text('No earlier purchase was found.'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('active Pro and billing-issue states', (t) async {
      final sub = FakeSubscriptionService(
        initial: const Entitlement(status: SubscriptionStatus.gracePeriod),
      );
      await bootApp(t, tall: true, subscription: sub);
      await t.tap(find.text('You').last);
      await settle(t, 6);
      await t.tap(find.text('HYDRA Pro is active'));
      await settle(t, 12);
      expect(find.text('You have HYDRA Pro'), findsOneWidget);
      expect(
        find.textContaining('problem with your payment method'),
        findsOneWidget,
      );
      await disposeApp(t);
    });

    testWidgets('Pro-only surfaces point to the paywall for free users', (
      t,
    ) async {
      await bootApp(t, tall: true);
      await openYouPage(t, 'Health sync');
      expect(find.text('Health sync is part of HYDRA Pro.'), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('privacy center', () {
    testWidgets('export failure is reported, not swallowed', (t) async {
      await bootApp(t, tall: true);
      await openYouPage(t, 'Privacy Center');
      await t.tap(find.text('Export as CSV'));
      await settle(t, 10);
      // The share/path plugins are absent in unit tests → user sees a clear message.
      expect(find.text("Couldn't create the export."), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('delete my data wipes everything and returns to onboarding', (
      t,
    ) async {
      final env = await bootApp(t, tall: true);
      await env.services.core.log(volumeMl: 500);
      await openYouPage(t, 'Privacy Center');
      await t.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Delete my data'),
      );
      await settle(t, 2);
      await t.tap(find.widgetWithText(OutlinedButton, 'Delete my data'));
      await settle(t, 6);
      expect(find.text('Delete all HYDRA data?'), findsOneWidget);
      await t.tap(find.text('Delete everything'));
      await settle(t, 20);
      expect(await env.services.core.hydration.count(), 0);
      expect(await env.services.core.vessels.getAll(), isEmpty);
      expect(
        (await env.services.core.profiles.get())!.onboardingComplete,
        isFalse,
      );
      expect(
        find.text('Hydration that adapts to your day.'),
        findsWidgets,
      ); // back on onboarding
      await disposeApp(t);
    });

    testWidgets('cancelling the delete dialog keeps data', (t) async {
      final env = await bootApp(t, tall: true);
      await env.services.core.log(volumeMl: 500);
      await openYouPage(t, 'Privacy Center');
      await t.ensureVisible(
        find.widgetWithText(OutlinedButton, 'Delete my data'),
      );
      await settle(t, 2);
      await t.tap(find.widgetWithText(OutlinedButton, 'Delete my data'));
      await settle(t, 6);
      await t.tap(find.text('Cancel'));
      await settle(t, 6);
      expect(await env.services.core.hydration.count(), 1);
      await disposeApp(t);
    });
  });

  group('large text & guidelines on more screens', () {
    for (final page in [
      'Daily target',
      'Wake and sleep',
      'Vessels',
      'Routines',
      'Privacy Center',
      'Health sync',
      'Appearance',
      'Help and support',
      'Notifications',
      'HYDRA Pro',
    ]) {
      testWidgets('2x text: $page', (t) async {
        await bootApp(
          t,
          textScale: 2.0,
          subscription: FakeSubscriptionService(),
        );
        await openYouPage(t, page);
        expect(t.takeException(), isNull, reason: page);
        await disposeApp(t);
      });
    }
    testWidgets('log sheet at 2x text', (t) async {
      await bootApp(t, textScale: 2.0);
      await tapVisible(t, find.text('Custom'));
      await settle(t, 8);
      expect(t.takeException(), isNull);
      await disposeApp(t);
    });
    for (final tab in ['History', 'Insights', 'You']) {
      testWidgets('tap-target and label guidelines: $tab', (t) async {
        final h = t.ensureSemantics();
        await bootApp(t);
        await openTab(t, tab);
        await expectLater(t, meetsGuideline(androidTapTargetGuideline));
        await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
        h.dispose();
        await disposeApp(t);
      });
    }
  });
}
