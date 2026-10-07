import '../core/config/feature_flags.dart';
import '../core/time/hydra_time.dart';
import '../data/database/app_database.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../data/repositories/vessel_repository.dart';
import '../services/analytics/analytics_service.dart';
import '../services/error_reporter.dart';
import '../services/notifications/notification_service.dart';
import '../services/widgets/widget_publisher.dart';
import 'hydra_core.dart';
import 'plan_service.dart';
import 'reminder_coordinator.dart';
import 'stats_service.dart';

/// Wires repositories, engines and platform services into a [HydraCore].
/// Used by the Riverpod root, the background notification isolate and tests,
/// so all three execute *identical* logic.
HydraCore buildCore({
  required AppDatabase db,
  required NotificationService notifications,
  required WidgetPublisher widgets,
  required AnalyticsService analytics,
  required ErrorReporter errors,
  required Future<String> Function() timezoneName,
  AppClock? clock,
  FeatureFlags Function()? flags,
  String? Function()? localeCode,
}) {
  final c = clock ?? AppClock();
  final profiles = ProfileRepository(db);
  final hydration = HydrationRepository(db, now: c.now);
  final vessels = VesselRepository(db);
  final routines = RoutineRepository(db);
  final reminders = ReminderRepository(db);
  final settings = SettingsRepository(db);
  final summaries = SummaryRepository(db);
  final plans = PlanService(
    profiles: profiles,
    routines: routines,
    hydration: hydration,
    reminders: reminders,
    settings: settings,
    timezoneName: timezoneName,
  );
  final stats = StatsService(
    profiles: profiles,
    routines: routines,
    hydration: hydration,
    reminders: reminders,
    summaries: summaries,
    timezoneName: timezoneName,
  );
  final coordinator = ReminderCoordinator(
    plans: plans,
    reminders: reminders,
    hydration: hydration,
    settings: settings,
    notifications: notifications,
    localeCode: localeCode ?? () => null,
    now: c.now,
  );
  return HydraCore(
    db: db,
    profiles: profiles,
    hydration: hydration,
    vessels: vessels,
    routines: routines,
    reminders: reminders,
    settings: settings,
    summaries: summaries,
    plans: plans,
    stats: stats,
    coordinator: coordinator,
    notifications: notifications,
    widgets: widgets,
    analytics: analytics,
    errors: errors,
    timezoneName: timezoneName,
    clock: c,
    flags: flags ?? (() => const FeatureFlags()),
  );
}
