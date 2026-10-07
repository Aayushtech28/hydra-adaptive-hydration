import 'package:timezone/timezone.dart' as tz;

import '../core/time/hydra_time.dart';
import '../core/time/local_date.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../domain/hre/fatigue.dart';
import '../domain/hre/scheduler.dart';
import '../domain/hre/types.dart';
import '../domain/models/entities.dart';
import '../domain/models/enums.dart';
import '../domain/models/routine_resolver.dart';

/// Everything needed to answer "where am I today and what happens next".
class PlanContext {
  const PlanContext({
    required this.now,
    required this.profile,
    required this.routines,
    required this.location,
    required this.date,
    required this.today,
    required this.tomorrow,
    required this.input,
    required this.entries,
    required this.paused,
    required this.pausedUntil,
    required this.snoozeUntil,
  });

  final DateTime now;
  final UserProfile profile;
  final List<Routine> routines;
  final tz.Location location;
  final LocalDate date;
  final ResolvedDay today;
  final ResolvedDay tomorrow;
  final SchedulerInput input;
  final List<HydrationEntry> entries;
  final bool paused;
  final DateTime? pausedUntil;
  final DateTime? snoozeUntil;

  int get consumedMl => input.consumedMl;
}

/// Thrown when planning is requested before a profile exists.
class NoProfileException implements Exception {
  const NoProfileException();
  @override
  String toString() => 'NoProfileException';
}

class PlanService {
  PlanService({
    required this.profiles,
    required this.routines,
    required this.hydration,
    required this.reminders,
    required this.settings,
    required this.timezoneName,
    this.scheduler = const HydrationScheduler(),
  });

  final ProfileRepository profiles;
  final RoutineRepository routines;
  final HydrationRepository hydration;
  final ReminderRepository reminders;
  final SettingsRepository settings;

  /// Current *device* timezone (IANA).
  final Future<String> Function() timezoneName;
  final HydrationScheduler scheduler;

  /// Minutes after which an unanswered reminder counts as ignored.
  static const int responseWindowMin = 45;

  DayContext _ctx(ResolvedDay r, tz.Location loc) => DayContext(
        window: DayWindow.build(
          date: r.date,
          location: loc,
          wakeMinute: r.wakeMinute,
          sleepMinute: r.sleepMinute,
        ),
        quietSpans: r.quietSpans,
        workoutSpans: r.workoutSpans,
      );

  Future<PlanContext> load(DateTime now) async {
    final profile = await profiles.get();
    if (profile == null) throw const NoProfileException();
    final rs = await routines.getAll();
    final loc = locationFor(await timezoneName());
    final date = logicalDateOf(now, loc);
    final today = RoutineResolver.resolve(profile: profile, routines: rs, date: date);
    final tomorrow = RoutineResolver.resolve(profile: profile, routines: rs, date: date.addDays(1));

    final entries = await hydration.entriesForDay(date);
    final consumed = entries.fold<int>(0, (s, e) => s + e.volumeMl);
    final lastLogAt = entries.isEmpty ? null : entries.last.timestampUtc;

    final todayCtx = _ctx(today, loc);
    final dayEvents = await reminders.forDate(date);
    final fired = dayEvents
        .where((e) => !e.scheduledAt.isAfter(now) && e.outcome != ReminderOutcome.cancelled)
        .toList();
    final lastReminder = fired.isEmpty ? null : fired.last.scheduledAt;

    // Trailing run of reminders with no engagement since the last log.
    var unanswered = 0;
    for (var i = fired.length - 1; i >= 0; i--) {
      final e = fired[i];
      if (lastLogAt != null && e.scheduledAt.isBefore(lastLogAt)) break;
      final expiredPending = e.outcome == ReminderOutcome.pending &&
          now.difference(e.scheduledAt).inMinutes >= responseWindowMin;
      if (e.outcome == ReminderOutcome.ignored || expiredPending) {
        unanswered++;
      } else {
        break;
      }
    }

    final outcomes = (await reminders.recentResolved()).map((e) => e.outcome).toList();
    final askedAt = await settings.getTime(SettingKeys.askedFewerReminders);
    final fatigue = FatigueCalculator.compute(
      outcomes,
      alreadyAskedRecently: askedAt != null && now.difference(askedAt).inDays < 14,
    );

    final snooze = await settings.getTime(SettingKeys.snoozeUntil);
    final pausedUntil = await settings.getTime(SettingKeys.pausedUntil);
    final pauseLogStart = await settings.getTime(SettingKeys.pausedUntilLog);
    var pausedUntilLog = false;
    if (pauseLogStart != null) {
      final last = await hydration.lastEntry();
      pausedUntilLog = last == null || !last.createdAt.isAfter(pauseLogStart);
    }
    final timedPause = pausedUntil != null && pausedUntil.isAfter(now) ? pausedUntil : null;

    final first = await hydration.firstEntryDate();
    final historyDays = first == null ? 0 : date.differenceInDays(first).clamp(0, 10000) + 1;

    final input = SchedulerInput(
      now: now,
      today: todayCtx,
      tomorrow: _ctx(tomorrow, loc),
      targetMl: profile.dailyTargetMl,
      consumedMl: consumed,
      policy: ReminderPolicy.forMode(today.mode),
      lastLogAt: lastLogAt,
      lastReminderAt: lastReminder,
      consecutiveUnanswered: unanswered,
      fatigue: fatigue,
      snoozeUntil: snooze != null && snooze.isAfter(now) ? snooze : null,
      pausedUntil: timedPause,
      pausedUntilNextLog: pausedUntilLog,
      remindersEnabled: profile.remindersEnabled,
      tone: profile.tone,
      historyDays: historyDays,
      hotEnvironment: profile.environmentHot,
      copySeed: date.differenceInDays(const LocalDate(2026, 1, 1)),
    );

    return PlanContext(
      now: now,
      profile: profile,
      routines: rs,
      location: loc,
      date: date,
      today: today,
      tomorrow: tomorrow,
      input: input,
      entries: entries,
      paused: pausedUntilLog || timedPause != null,
      pausedUntil: timedPause,
      snoozeUntil: input.snoozeUntil,
    );
  }

  SchedulerDecision decide(PlanContext ctx) => scheduler.decide(ctx.input);
  List<SchedulerDecision> chain(PlanContext ctx, {int maxCount = 6}) =>
      scheduler.planChain(ctx.input, maxCount: maxCount);
}
