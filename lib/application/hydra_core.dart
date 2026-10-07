import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';

import '../core/config/feature_flags.dart';
import '../core/logging/log.dart';
import '../core/time/hydra_time.dart';
import '../core/time/local_date.dart';
import '../core/units/formatters.dart';
import '../core/units/volume_unit.dart';
import '../core/util/validation.dart';
import '../data/database/app_database.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../data/repositories/vessel_repository.dart';
import '../domain/hre/types.dart';
import '../domain/models/entities.dart';
import '../domain/models/enums.dart';
import '../services/analytics/analytics_service.dart';
import '../services/error_reporter.dart';
import '../services/notifications/notification_service.dart';
import '../services/widgets/widget_publisher.dart';
import 'plan_service.dart';
import 'reminder_coordinator.dart';
import 'stats_service.dart';

class LogResult {
  const LogResult(this.entry, this.dayTotalMl);
  final HydrationEntry entry;
  final int dayTotalMl;
}

/// The application's use-case facade. UI, notification handlers (including
/// background isolates) and widgets all go through this one class so that
/// every mutation follows the same pipeline:
///
///   validate → persist → recompute → reschedule reminders → publish widget
///
/// Animations are the UI's concern and run *after* [log] returns.
class HydraCore {
  HydraCore({
    required this.db,
    required this.profiles,
    required this.hydration,
    required this.vessels,
    required this.routines,
    required this.reminders,
    required this.settings,
    required this.summaries,
    required this.plans,
    required this.stats,
    required this.coordinator,
    required this.notifications,
    required this.widgets,
    required this.analytics,
    required this.errors,
    required this.timezoneName,
    required this.clock,
    required this.flags,
  });

  final AppDatabase db;
  final ProfileRepository profiles;
  final HydrationRepository hydration;
  final VesselRepository vessels;
  final RoutineRepository routines;
  final ReminderRepository reminders;
  final SettingsRepository settings;
  final SummaryRepository summaries;
  final PlanService plans;
  final StatsService stats;
  final ReminderCoordinator coordinator;
  final NotificationService notifications;
  final WidgetPublisher widgets;
  final AnalyticsService analytics;
  final ErrorReporter errors;
  final Future<String> Function() timezoneName;
  final AppClock clock;
  final FeatureFlags Function() flags;

  static const List<({String name, int ml, String icon})> defaultVessels = [
    (name: 'Glass', ml: 250, icon: 'glass'),
    (name: 'Desk bottle', ml: 750, icon: 'bottle'),
    (name: 'Gym bottle', ml: 1000, icon: 'bottle_large'),
  ];

  // ---- lifecycle ---------------------------------------------------------

  /// Ensures the profile exists. Runs before the first frame so the UI can
  /// render from local data immediately.
  Future<UserProfile> bootstrap({String? locale}) async {
    // Needed outside the widget tree too (background notification isolate,
    // widget labels), where no localization delegate has initialised intl.
    await initializeDateFormatting();
    final tz = await timezoneName();
    final p = await profiles.ensure(now: clock.now().toUtc(), timezone: tz, locale: locale);
    if (await settings.getTime(SettingKeys.firstLaunchAt) == null) {
      await settings.setTime(SettingKeys.firstLaunchAt, clock.now());
    }
    return p;
  }

  /// Called when the app resumes / starts: resolve elapsed reminders, detect
  /// timezone change, refresh schedule and widget.
  Future<void> onResume() async {
    // The background notification isolate writes through its own connection;
    // tell this isolate's streams to re-read.
    db.markTablesUpdated(db.allTables);
    await errors.guard(ErrorArea.notifications, () async {
      await reschedule(reason: 'resume');
    });
  }

  /// Compares the device timezone with the one last scheduled for.
  /// Returns the new zone if it changed (UI asks whether to adjust), else null.
  Future<String?> detectTimezoneChange() async {
    final p = await profiles.get();
    if (p == null) return null;
    final now = await timezoneName();
    return now != p.timezone ? now : null;
  }

  /// Adopt the device timezone: future reminders are recalculated; historical
  /// entries keep their original zone and absolute instants.
  Future<void> acceptTimezone(String zone) async {
    final p = await profiles.get();
    if (p == null) return;
    await profiles.save(p.copyWith(timezone: zone));
    await reschedule(reason: 'timezone');
  }

  // ---- hydration mutations ----------------------------------------------

  Future<LogResult> log({
    required int volumeMl,
    String? vesselId,
    EntrySource source = EntrySource.manual,
    DateTime? at,
    BeverageType beverage = BeverageType.water,
  }) async {
    final when = (at ?? clock.now()).toUtc();
    final tz = await timezoneName();
    final entry = await hydration.add(
      volumeMl: volumeMl,
      at: when,
      timezone: tz,
      source: source,
      vesselId: vesselId,
      beverage: beverage,
    );
    // Any user logging ends a "pause until I log" state.
    await settings.remove(SettingKeys.pausedUntilLog);
    await summaries.invalidate(entry.localDate);
    analytics.log(AnalyticsEvent.hydrationLogged, {
      'source': source == EntrySource.notificationAction
          ? 'notification'
          : source == EntrySource.widget
              ? 'widget'
              : 'manual',
      'has_vessel': vesselId != null,
    });
    final total = await hydration.totalForDay(entry.localDate);
    unawaited(_afterChange(reason: 'log'));
    return LogResult(entry, total);
  }

  Future<void> deleteEntry(String id) async {
    final e = await hydration.delete(id);
    if (e == null) return;
    await summaries.invalidate(e.localDate);
    unawaited(_afterChange(reason: 'delete'));
  }

  Future<void> restoreEntry(HydrationEntry e) async {
    await hydration.restore(e);
    await summaries.invalidate(e.localDate);
    unawaited(_afterChange(reason: 'restore'));
  }

  Future<void> editEntry(String id, {int? volumeMl, DateTime? at}) async {
    final before = await hydration.getById(id);
    final updated = await hydration.update(id, volumeMl: volumeMl, at: at);
    await summaries.invalidate(updated.localDate);
    if (before != null) await summaries.invalidate(before.localDate);
    unawaited(_afterChange(reason: 'edit'));
  }

  // ---- reminder controls -------------------------------------------------

  Future<void> snooze(Duration d, {String? eventId}) async {
    await settings.setTime(SettingKeys.snoozeUntil, clock.now().add(d));
    await coordinator.recordInteraction(eventId, ReminderOutcome.snoozed);
    analytics.log(AnalyticsEvent.reminderSnoozed);
    await reschedule(reason: 'snooze');
  }

  Future<void> pauseFor(Duration d) async {
    await settings.setTime(SettingKeys.pausedUntil, clock.now().add(d));
    await reschedule(reason: 'pause');
  }

  Future<void> pauseUntil(DateTime t) async {
    await settings.setTime(SettingKeys.pausedUntil, t);
    await reschedule(reason: 'pause');
  }

  Future<void> pauseUntilNextLog() async {
    await settings.setTime(SettingKeys.pausedUntilLog, clock.now());
    await reschedule(reason: 'pause');
  }

  Future<void> resumeReminders() async {
    await settings.remove(SettingKeys.pausedUntil);
    await settings.remove(SettingKeys.pausedUntilLog);
    await settings.remove(SettingKeys.snoozeUntil);
    await reschedule(reason: 'resume_reminders');
  }

  Future<void> acceptFewerReminders() async {
    final p = await profiles.get();
    if (p == null) return;
    final next = switch (p.mode) {
      ReminderMode.focus => ReminderMode.balanced,
      ReminderMode.balanced => ReminderMode.gentle,
      ReminderMode.gentle => ReminderMode.gentle,
    };
    await profiles.save(p.copyWith(mode: next));
    await settings.setTime(SettingKeys.askedFewerReminders, clock.now());
    analytics.log(AnalyticsEvent.fewerRemindersAccepted);
    await reschedule(reason: 'fewer_reminders');
  }

  Future<void> declineFewerReminders() =>
      settings.setTime(SettingKeys.askedFewerReminders, clock.now());

  // ---- notification actions (UI isolate *and* background isolate) --------

  Future<void> handleNotificationAction(NotificationAction a) async {
    try {
      switch (a.kind) {
        case NotificationActionKind.log:
          final r = await log(volumeMl: a.ml!, source: EntrySource.notificationAction);
          await coordinator.recordInteraction(a.eventId, ReminderOutcome.logged);
          analytics.log(AnalyticsEvent.reminderActionUsed, {'source': 'log'});
          Log.debug('notifications', 'action logged', fields: {'count': r.entry.volumeMl > 0 ? 1 : 0});
        case NotificationActionKind.snooze:
          await snooze(const Duration(minutes: 30), eventId: a.eventId);
          analytics.log(AnalyticsEvent.reminderActionUsed, {'source': 'snooze'});
        case NotificationActionKind.open:
          await coordinator.recordInteraction(a.eventId, ReminderOutcome.opened);
      }
    } on ValidationException catch (e) {
      Log.warning('notifications', 'invalid action ignored', fields: {'code': e.code.name});
    } catch (e, st) {
      errors.record(e, st, ErrorArea.notifications);
    }
  }

  // ---- planning ----------------------------------------------------------

  Future<PlanContext> currentContext() => plans.load(clock.now().toUtc());

  Future<SchedulerSummary?>? _inflight;
  bool _rerun = false;

  /// Serialised + coalesced: 100 rapid taps trigger at most one in-flight
  /// reschedule plus one follow-up, so the OS never sees interleaved
  /// cancel/schedule sequences and the event table never accumulates
  /// duplicate chains.
  Future<SchedulerSummary?> reschedule({String reason = 'manual'}) {
    final running = _inflight;
    if (running != null) {
      _rerun = true;
      return running;
    }
    final f = _rescheduleLoop(reason);
    _inflight = f;
    return f.whenComplete(() => _inflight = null);
  }

  Future<SchedulerSummary?> _rescheduleLoop(String reason) async {
    SchedulerSummary? summary;
    do {
      _rerun = false;
      summary = await coordinator.reschedule(reason: reason);
    } while (_rerun);
    if (summary != null) await publishWidget(summary.decision);
    return summary;
  }

  Future<void> _afterChange({required String reason}) async {
    try {
      await reschedule(reason: reason);
    } catch (e, st) {
      errors.record(e, st, ErrorArea.notifications);
    }
  }

  Future<void> publishWidget([SchedulerDecision? decision]) async {
    try {
      final PlanContext ctx;
      try {
        ctx = await plans.load(clock.now().toUtc());
      } on NoProfileException {
        return;
      }
      final d = decision ?? plans.decide(ctx);
      final loc = ctx.profile.locale ?? 'en';
      final unit = ctx.profile.unit;
      final hide = await settings.getBool('privacy.widgetHideAmounts');
      final next = d.nextReminder;
      await widgets.publish(WidgetSnapshot(
        percent: (d.snapshot.percent * 100).round().clamp(0, 100),
        progressLabel:
            '${Formatters.volumeValue(ctx.consumedMl, unit, loc)} / ${Formatters.volume(ctx.profile.dailyTargetMl, unit, loc)}',
        nextReminderLabel: next == null ? '' : Formatters.time(next, ctx.location, loc),
        quickAddsMl: ctx.today.quickAddsMl.take(3).toList(),
        stateSymbol: switch (d.state) {
          PaceState.ahead || PaceState.onTrack => '✓',
          PaceState.slightlyBehind => '→',
          PaceState.significantlyBehind || PaceState.dayClosing => '!',
        },
        updatedAtMs: clock.now().millisecondsSinceEpoch,
        hideAmounts: hide,
      ));
    } catch (e, st) {
      errors.record(e, st, ErrorArea.widgets);
    }
  }

  /// Smart quick-add (opt-in): the three most frequently used volumes, only
  /// when each has real repeated use. Never reorders the user's own list
  /// unless they enabled it.
  Future<List<int>> suggestedQuickAdds() async {
    final f = await hydration.frequentVolumes();
    return f.map((e) => e.ml).toList();
  }

  // ---- settings with side effects ---------------------------------------

  Future<void> updateProfile(UserProfile Function(UserProfile) change) async {
    final p = await profiles.get();
    if (p == null) return;
    await profiles.save(change(p));
    await summaries.invalidate(logicalDateOf(clock.now(), locationFor(await timezoneName())));
    await reschedule(reason: 'settings');
  }

  Future<void> completeOnboarding() async {
    await updateProfile((p) => p.copyWith(onboardingComplete: true));
    await vessels.seedDefaultsIfEmpty(defaultVessels);
    analytics.log(AnalyticsEvent.onboardingCompleted);
  }

  Future<int> totalLogCount() async => (await hydration.all()).length;

  Future<int> installAgeDays() async {
    final t = await settings.getTime(SettingKeys.firstLaunchAt);
    return t == null ? 0 : clock.now().difference(t).inDays;
  }

  /// Wipes all local HYDRA data and cancels reminders. Third-party health
  /// records are untouched (see Privacy Center copy).
  Future<void> deleteAllData() async {
    await notifications.cancelAll();
    await db.deleteEverything();
    await widgets.publish(const WidgetSnapshot(
      percent: 0,
      progressLabel: '',
      nextReminderLabel: '',
      quickAddsMl: [],
      stateSymbol: '',
      updatedAtMs: 0,
      hideAmounts: true,
    ));
    analytics.log(AnalyticsEvent.dataDeleted);
  }

  /// Convenience used by tests/diagnostics.
  Future<LocalDate> today() async =>
      logicalDateOf(clock.now(), locationFor(await timezoneName()));
}

/// Unit helper for validated user input at the UI boundary.
int? parseVolumeInput(String text, VolumeUnit unit, {String decimalSeparator = '.'}) {
  final v = parseLocalizedNumber(text, decimalSeparator: decimalSeparator);
  final r = validateVolume(v, unit);
  return r is VolumeOk ? r.ml : null;
}
