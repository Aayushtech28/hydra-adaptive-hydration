import '../core/time/hydra_time.dart';
import '../core/time/local_date.dart';
import '../data/repositories/hydration_repository.dart';
import '../data/repositories/misc_repositories.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../domain/hre/types.dart';
import '../domain/insights/day_stats.dart';
import '../domain/models/entities.dart';
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

  /// Stats for an arbitrary inclusive range (cached for closed days, live for
  /// today). Missing days are returned as empty stats so calendars are dense.
  Future<List<DayStats>> rangeStats(LocalDate from, LocalDate to, {required LocalDate today, DateTime? now}) async {
    final profile = (await profiles.get())!;
    final cached = await summaries.range(from, to);
    final out = <DayStats>[];
    var d = from;
    while (!d.isAfter(to)) {
      DayStats? s;
      if (d == today) {
        s = await computeDay(d, now: now);
      } else if (d.isAfter(today)) {
        s = DayStats.empty(d, profile.dailyTargetMl);
      } else {
        s = cached[d];
        if (s == null) {
          final entries = await hydration.entriesForDay(d);
          s = entries.isEmpty ? DayStats.empty(d, profile.dailyTargetMl) : await computeDay(d, now: now);
          await summaries.put(s, now: now ?? DateTime.now());
        }
      }
      out.add(s);
      d = d.addDays(1);
    }
    return out;
  }

  /// Everything the Day view needs: entries, the day's plan curve and stats.
  Future<DayDetail> detail(LocalDate date, {DateTime? now}) async {
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
    return DayDetail(
      date: date,
      entries: entries,
      trajectory: PlanTrajectory(targetMl: profile.dailyTargetMl, window: window),
      stats: await computeDay(date, now: now),
      routineName: resolved.name,
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

class DayDetail {
  const DayDetail({
    required this.date,
    required this.entries,
    required this.trajectory,
    required this.stats,
    required this.routineName,
  });
  final LocalDate date;
  final List<HydrationEntry> entries;
  final PlanTrajectory trajectory;
  final DayStats stats;
  final String? routineName;
}
