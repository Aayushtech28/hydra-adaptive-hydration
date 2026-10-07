import '../core/time/hydra_time.dart';
import '../core/time/local_date.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../domain/hre/types.dart';
import '../domain/insights/day_stats.dart';
import '../domain/models/enums.dart';
import '../domain/models/routine_resolver.dart';

/// Builds (and caches) per-day behavioural stats from entries, reminders and
/// the routine that applied that day. Closed days are cached in
/// `daily_summaries`; the current day is always computed live.
class StatsService {
  StatsService({
    required this.profiles,
    required this.routines,
    required this.hydration,
    required this.reminders,
    required this.summaries,
    required this.timezoneName,
  });

  final ProfileRepository profiles;
  final RoutineRepository routines;
  final HydrationRepository hydration;
  final ReminderRepository reminders;
  final SummaryRepository summaries;
  final Future<String> Function() timezoneName;

  Future<DayStats> computeDay(LocalDate date, {DateTime? now}) async {
    final profile = (await profiles.get())!;
    final rs = await routines.getAll();
    final entries = await hydration.entriesForDay(date);
    final zone = entries.isNotEmpty ? entries.first.timezone : await timezoneName();
    final loc = locationFor(zone);
    final resolved = RoutineResolver.resolve(profile: profile, routines: rs, date: date);
    final window = DayWindow.build(
      date: date,
      location: loc,
      wakeMinute: resolved.wakeMinute,
      sleepMinute: resolved.sleepMinute,
    );
    final events = await reminders.forDate(date);
    final traj = PlanTrajectory(targetMl: profile.dailyTargetMl, window: window);
    return DayStatsBuilder.build(
      date: date,
      trajectory: traj,
      logs: [for (final e in entries) LogPoint(e.timestampUtc, e.volumeMl)],
      reminders: [
        for (final e in events)
          if (e.outcome != ReminderOutcome.pending || (now != null && now.difference(e.scheduledAt).inMinutes >= 45))
            ReminderPoint(
              e.scheduledAt,
              e.outcome == ReminderOutcome.pending ? ReminderOutcome.ignored : e.outcome,
            ),
      ],
      routineKind: resolved.kind,
    );
  }

  /// The first day the user has any data or started the app.
  Future<LocalDate> firstDay(LocalDate today) async {
    final profile = (await profiles.get())!;
    final loc = locationFor(await timezoneName());
    final created = logicalDateOf(profile.createdAt, loc);
    final firstEntry = await hydration.firstEntryDate();
    var first = created;
    if (firstEntry != null && firstEntry.isBefore(first)) first = firstEntry;
    return first.isAfter(today) ? today : first;
  }

  /// Contiguous completed days (up to yesterday) from the first day of use,
  /// each with stats (missed days are empty stats). Cached for closed days.
  Future<List<DayStats>> completedDays(LocalDate today, {DateTime? now, int maxDays = 120}) async {
    final profile = (await profiles.get())!;
    var first = await firstDay(today);
    final yesterday = today.addDays(-1);
    if (first.isAfter(yesterday)) return const [];
    final earliest = yesterday.addDays(-(maxDays - 1));
    if (first.isBefore(earliest)) first = earliest;
    final cached = await summaries.range(first, yesterday);
    final out = <DayStats>[];
    var d = first;
    while (!d.isAfter(yesterday)) {
      var s = cached[d];
      if (s == null) {
        final entries = await hydration.entriesForDay(d);
        if (entries.isEmpty) {
          s = DayStats.empty(d, profile.dailyTargetMl);
        } else {
          s = await computeDay(d, now: now);
        }
        await summaries.put(s, now: now ?? DateTime.now());
      }
      out.add(s);
      d = d.addDays(1);
    }
    return out;
  }
}
