import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/hydra_core.dart';
import '../application/plan_service.dart';
import '../application/stats_bundle.dart';
import '../core/time/local_date.dart';
import '../data/repositories/misc_repositories.dart';
import '../domain/hre/types.dart';
import '../domain/models/entities.dart';
import '../domain/models/enums.dart';
import '../services/notifications/notification_service.dart';
import '../services/purchase/entitlement.dart';
import 'services.dart';
import 'theme/tokens.dart';

/// Overridden in `main()` with the already-initialised services so screens
/// can read synchronously (no loading spinner for local data).
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('servicesProvider not overridden'),
);

final coreProvider = Provider<HydraCore>(
  (ref) => ref.watch(servicesProvider).core,
);

// ---- raw data streams -------------------------------------------------------

final profileProvider = StreamProvider<UserProfile?>(
  (ref) => ref.watch(coreProvider).profiles.watch(),
);
final vesselsProvider = StreamProvider<List<Vessel>>(
  (ref) => ref.watch(coreProvider).vessels.watchAll(),
);
final routinesProvider = StreamProvider<List<Routine>>(
  (ref) => ref.watch(coreProvider).routines.watchAll(),
);

/// Fires once a minute while the app is in the foreground so "next reminder"
/// and pace stay fresh. No timers run in the background.
final tickProvider = StreamProvider<int>((ref) {
  final controller = StreamController<int>()..add(0);
  var n = 0;
  final timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => controller.add(++n),
  );
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Bumped by actions that change reminder state stored outside the profile
/// (pause/snooze), so dependent providers refresh.
class RevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final revisionProvider = NotifierProvider<RevisionNotifier, int>(
  RevisionNotifier.new,
);

final todayDateProvider = FutureProvider<LocalDate>((ref) async {
  ref.watch(tickProvider);
  return ref.watch(coreProvider).today();
});

final todayEntriesProvider = StreamProvider<List<HydrationEntry>>((ref) async* {
  final date = await ref.watch(todayDateProvider.future);
  yield* ref.watch(coreProvider).hydration.watchDay(date);
});

final entriesChangedProvider = StreamProvider<int>((ref) async* {
  var n = 0;
  yield n;
  await for (final _ in ref.watch(coreProvider).hydration.changes) {
    yield ++n;
  }
});

// ---- dashboard --------------------------------------------------------------

class DashboardState {
  const DashboardState({
    required this.ctx,
    required this.decision,
    required this.vessels,
    required this.permission,
    required this.timezoneChangedTo,
  });
  final PlanContext ctx;
  final SchedulerDecision decision;
  final List<Vessel> vessels;
  final NotificationPermission permission;
  final String? timezoneChangedTo;

  PaceSnapshot get snapshot => decision.snapshot;
}

final notificationPermissionProvider = FutureProvider<NotificationPermission>((
  ref,
) {
  ref.watch(revisionProvider);
  return ref.watch(servicesProvider).notifications.permission();
});

final dashboardProvider = FutureProvider<DashboardState>((ref) async {
  ref.watch(profileProvider);
  ref.watch(todayEntriesProvider);
  ref.watch(routinesProvider);
  ref.watch(tickProvider);
  ref.watch(revisionProvider);
  final vessels = ref.watch(vesselsProvider).value ?? const [];
  final svc = ref.watch(servicesProvider);
  final core = svc.core;
  final ctx = await core.currentContext();
  final decision = core.plans.decide(ctx);
  final perm = await svc.notifications.permission();
  return DashboardState(
    ctx: ctx,
    decision: decision,
    vessels: vessels,
    permission: perm,
    timezoneChangedTo: await core.detectTimezoneChange(),
  );
});

// ---- stats / insights -------------------------------------------------------

final statsProvider = FutureProvider<StatsBundle>((ref) async {
  ref.watch(profileProvider);
  ref.watch(entriesChangedProvider);
  ref.watch(routinesProvider);
  final core = ref.watch(coreProvider);
  final remote = ref.watch(servicesProvider).remote;
  final today = await core.today();
  final now = core.clock.now().toUtc();
  final completed = await core.stats.completedDays(today, now: now);
  final todayStats = await core.stats.computeDay(today, now: now);

  String? favName;
  int? favMl;
  final counts = await core.hydration.vesselUseCounts(days: 30);
  if (counts.isNotEmpty) {
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final v = await core.vessels.getById(top.key);
    favName = v?.name;
    favMl = v?.volumeMl;
  }
  return buildStatsBundle(
    today: today,
    completed: completed,
    todayStats: todayStats,
    challengeDefs: remote.current.effectiveChallenges,
    favoriteVesselName: favName,
    favoriteVesselMl: favMl,
  );
});

// ---- entitlement ------------------------------------------------------------

final entitlementProvider = StreamProvider<Entitlement>((ref) async* {
  final sub = ref.watch(servicesProvider).subscription;
  yield sub.current;
  yield* sub.changes;
});

/// Pro-ness with a debug-only override (never honoured in production).
class ProOverride extends Notifier<bool?> {
  @override
  bool? build() => null;
  void set(bool? v) => state = v;
}

final proOverrideProvider = NotifierProvider<ProOverride, bool?>(
  ProOverride.new,
);

final isProProvider = Provider<bool>((ref) {
  final svc = ref.watch(servicesProvider);
  final o = svc.debugToolsAvailable ? ref.watch(proOverrideProvider) : null;
  if (o != null) return o;
  return ref.watch(entitlementProvider).value?.isPro ??
      svc.subscription.current.isPro;
});

// ---- appearance / locale ----------------------------------------------------

final themeModeProvider = Provider<ThemeMode>((ref) {
  final t = ref.watch(profileProvider).value?.theme ?? ThemeChoice.system;
  return switch (t) {
    ThemeChoice.system => ThemeMode.system,
    ThemeChoice.light => ThemeMode.light,
    ThemeChoice.dark => ThemeMode.dark,
  };
});

/// Change-notifier used by the ring to ripple *after* persistence.
class LogPulse extends Notifier<int> {
  @override
  int build() => 0;
  void fire() => state++;
}

final logPulseProvider = NotifierProvider<LogPulse, int>(LogPulse.new);

/// Debug-only simulated clock offset (days) to exercise rollover.
class SimulatedDays extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

final simulatedDaysProvider = NotifierProvider<SimulatedDays, int>(
  SimulatedDays.new,
);

// ---- palette (premium themes) -------------------------------------------------

/// Active accent palette. Aurora/Graphite need Pro; Aurora can also be
/// unlocked for 24 hours with an optional rewarded ad.
final paletteProvider = StreamProvider<HydraPalette>((ref) async* {
  final svc = ref.watch(servicesProvider);
  final isPro = ref.watch(isProProvider);
  await for (final raw in svc.core.settings.watchString('ui.palette')) {
    var p = HydraPalette.parse(raw);
    if (p != HydraPalette.ocean && !isPro) {
      // Pro lapsed: Aurora survives only while a rewarded unlock is active.
      final until = await svc.core.settings.getTime(
        SettingKeys.rewardedThemeUntil,
      );
      final active = until != null && until.isAfter(svc.clock.now());
      if (!(p == HydraPalette.aurora && active)) p = HydraPalette.ocean;
    }
    yield p;
  }
});
