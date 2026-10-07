import '../../core/time/local_date.dart';
import 'entities.dart';
import 'enums.dart';

/// The effective schedule parameters for one logical day.
class ResolvedDay {
  const ResolvedDay({
    required this.date,
    required this.wakeMinute,
    required this.sleepMinute,
    required this.mode,
    required this.quietSpans,
    required this.workoutSpans,
    required this.quickAddsMl,
    required this.name,
    required this.kind,
    required this.routineId,
    required this.viaOverride,
  });

  final LocalDate date;
  final int wakeMinute;
  final int sleepMinute;
  final ReminderMode mode;
  final List<TimeSpan> quietSpans;
  final List<TimeSpan> workoutSpans;
  final List<int> quickAddsMl;
  final String? name;
  final RoutineKind? kind;

  /// Null when the profile defaults apply.
  final String? routineId;

  /// True if chosen by one-tap switch rather than weekday matching.
  final bool viaOverride;
}

/// Picks the routine for a date:
/// 1. the user's manual override (if still enabled),
/// 2. an enabled routine whose weekdays include the date (the most specific —
///    fewest weekdays — wins; ties by name),
/// 3. profile defaults (weekend variant when configured).
abstract final class RoutineResolver {
  static ResolvedDay resolve({
    required UserProfile profile,
    required List<Routine> routines,
    required LocalDate date,
  }) {
    Routine? chosen;
    var viaOverride = false;
    if (profile.activeRoutineId != null) {
      chosen = routines
          .where((r) => r.id == profile.activeRoutineId && r.enabled)
          .firstOrNull;
      viaOverride = chosen != null;
    }
    chosen ??= (routines
            .where((r) => r.enabled && r.weekdays.contains(date.weekday))
            .toList()
          ..sort((a, b) {
            final c = a.weekdays.length.compareTo(b.weekdays.length);
            return c != 0 ? c : a.name.compareTo(b.name);
          }))
        .firstOrNull;

    if (chosen != null) {
      return ResolvedDay(
        date: date,
        wakeMinute: chosen.wakeMinute,
        sleepMinute: chosen.sleepMinute,
        mode: chosen.mode,
        quietSpans: chosen.quietSpans,
        workoutSpans: chosen.workoutSpans,
        quickAddsMl: chosen.quickAddsMl.isEmpty ? profile.quickAddsMl : chosen.quickAddsMl,
        name: chosen.name,
        kind: chosen.kind,
        routineId: chosen.id,
        viaOverride: viaOverride,
      );
    }
    final weekendVariant = profile.weekendDifferent && date.isWeekend;
    return ResolvedDay(
      date: date,
      wakeMinute: weekendVariant ? profile.weekendWakeMinute : profile.wakeMinute,
      sleepMinute: weekendVariant ? profile.weekendSleepMinute : profile.sleepMinute,
      mode: profile.mode,
      quietSpans: const [],
      workoutSpans: const [],
      quickAddsMl: profile.quickAddsMl,
      name: null,
      kind: weekendVariant ? RoutineKind.weekend : RoutineKind.weekday,
      routineId: null,
      viaOverride: false,
    );
  }
}
