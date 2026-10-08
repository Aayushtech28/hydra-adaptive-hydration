import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydra/app/app.dart';
import 'package:hydra/app/providers.dart';
import 'package:hydra/app/router.dart';

import 'app_smoke_test.dart' show settle, testServices;

Future<void> _boot(
  WidgetTester t, {
  double textScale = 1.0,
  bool onboarded = true,
}) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 3;
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    t.view.reset();
    t.platformDispatcher.clearTextScaleFactorTestValue();
  });
  final (s, _) = await testServices();
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
}

Future<void> _dispose(WidgetTester t) async {
  await t.pumpWidget(const SizedBox());
  await t.pump(const Duration(seconds: 1));
}

Future<void> _tab(WidgetTester t, String name) async {
  await t.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text(name)),
  );
  await settle(t, 8);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('large text (2.0x) does not overflow', () {
    for (final tab in ['Home', 'History', 'Insights', 'You']) {
      testWidgets(tab, (t) async {
        await _boot(t, textScale: 2.0);
        await _tab(t, tab);
        expect(t.takeException(), isNull);
        await _dispose(t);
      });
    }
    testWidgets('onboarding', (t) async {
      await _boot(t, textScale: 2.0, onboarded: false);
      expect(t.takeException(), isNull);
      await _dispose(t);
    });
  });

  group('guidelines (home)', () {
    testWidgets('tap targets and labels', (t) async {
      final handle = t.ensureSemantics();
      await _boot(t);
      await expectLater(t, meetsGuideline(androidTapTargetGuideline));
      await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
      await _dispose(t);
    });

    testWidgets('text contrast', (t) async {
      final handle = t.ensureSemantics();
      await _boot(t);
      await expectLater(t, meetsGuideline(textContrastGuideline));
      handle.dispose();
      await _dispose(t);
    });
  });

  testWidgets('home exposes a semantic progress description', (t) async {
    final handle = t.ensureSemantics();
    await _boot(t);
    expect(
      find.bySemanticsLabel(RegExp(r'percent of today.s target')),
      findsOneWidget,
    );
    handle.dispose();
    await _dispose(t);
  });
}
