import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/feature_flags.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/error_reporter.dart';
import '../services/notifications/notification_service.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

class HydraApp extends ConsumerStatefulWidget {
  const HydraApp({super.key});
  @override
  ConsumerState<HydraApp> createState() => _HydraAppState();
}

class _HydraAppState extends ConsumerState<HydraApp>
    with WidgetsBindingObserver {
  StreamSubscription<NotificationAction>? _actions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final svc = ref.read(servicesProvider);

    // Foreground notification taps / action buttons.
    _actions = svc.notifications.actions.listen((a) async {
      await svc.core.handleNotificationAction(a);
      _refreshState();
    });

    // After first frame: launch action, then network/SDK work (never blocks UI).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final launch = await svc.errors.guard(
        ErrorArea.notifications,
        svc.notifications.launchAction,
      );
      if (launch != null) await svc.core.handleNotificationAction(launch);
      await svc.core.onResume();
      _refreshState();
      unawaited(svc.deferredInit());
    });
  }

  void _refreshState() {
    if (!mounted) return;
    ref.invalidate(dashboardProvider);
    ref.invalidate(statsProvider);
    ref.read(revisionProvider.notifier).bump();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final svc = ref.read(servicesProvider);
    unawaited(() async {
      await svc.core
          .onResume(); // rolls over the day, resolves reminders, reschedules
      _refreshState();
      // Opportunistic health sync (Pro, enabled, flag on); failures are silent.
      if (ref.read(isProProvider) && svc.flags.isOn(Flag.healthSync)) {
        final r = await svc.healthSync.sync();
        if (r.ok && (r.imported > 0 || r.removed > 0)) {
          await svc.core.summaries.invalidateAll();
          _refreshState();
        }
      }
    }());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _actions?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    final palette = ref.watch(paletteProvider).value ?? HydraPalette.ocean;
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      routerConfig: router,
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      themeMode: mode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 2.0,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
