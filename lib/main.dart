import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/router.dart';
import 'app/services.dart';
import 'core/config/app_config.dart';
import 'core/logging/log.dart';
import 'services/error_reporter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final earlyErrors = ErrorReporter()..installGlobalHandlers();
  await runZonedGuarded(
    () async => runApp(await _boot()),
    (e, st) => earlyErrors.record(e, st, ErrorArea.other),
  );
}

/// Local-only startup (database, profile, notification plugin). Everything
/// that needs the network or a third-party SDK is deferred until after the
/// first frame (`AppServices.deferredInit`) and is individually fault-tolerant.
Future<Widget> _boot() async {
  try {
    // Lets widget buttons log a drink without opening the app. Absent on
    // platforms without widgets; failure is harmless.
    try {
      await HomeWidget.registerInteractivityCallback(hydraWidgetCallback);
    } catch (_) {}
    for (final problem in AppConfig.problems) {
      Log.critical('config', 'release config: $problem');
    }
    final services = await AppServices.create();
    final profile = await services.core.profiles.get();
    return ProviderScope(
      overrides: [
        servicesProvider.overrideWithValue(services),
        initialOnboardedProvider.overrideWithValue(
          profile?.onboardingComplete ?? false,
        ),
      ],
      child: const HydraApp(),
    );
  } catch (e, st) {
    Log.critical('startup', 'startup failed', error: e, stack: st);
    return const StartupErrorApp();
  }
}

/// Shown only if local storage cannot be opened. Offers a retry; never
/// touches user data.
class StartupErrorApp extends StatefulWidget {
  const StartupErrorApp({super.key});
  @override
  State<StartupErrorApp> createState() => _StartupErrorAppState();
}

class _StartupErrorAppState extends State<StartupErrorApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    runApp(await _boot());
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop_outlined, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'HYDRA couldn\'t start',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your data is safe on this device. Please try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _retrying ? null : _retry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
