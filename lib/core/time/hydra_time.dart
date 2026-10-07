import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'local_date.dart';

/// Minutes after local midnight (0–1439).
typedef MinuteOfDay = int;

/// The hour (as minutes after midnight) at which the logical hydration day
/// rolls over. Entries logged before this belong to the previous logical day,
/// which supports routines that end after midnight.
const MinuteOfDay kDayRolloverMinute = 4 * 60;

bool _tzReady = false;

/// Loads the timezone database once. Safe to call repeatedly.
void ensureTimeZonesInitialized() {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  _tzReady = true;
}

/// Looks up an IANA zone; falls back to UTC for unknown names so malformed
/// stored data can never crash the app.
tz.Location locationFor(String? name) {
  ensureTimeZonesInitialized();
  if (name == null || name.isEmpty) return tz.UTC;
  try {
    return tz.getLocation(name);
  } on tz.LocationNotFoundException {
    return tz.UTC;
  }
}

MinuteOfDay minuteOfDayOf(tz.TZDateTime t) => t.hour * 60 + t.minute;

/// The *logical* local date of an absolute instant in [loc].
LocalDate logicalDateOf(DateTime instant, tz.Location loc) {
  final local = tz.TZDateTime.from(instant.toUtc(), loc);
  final date = LocalDate(local.year, local.month, local.day);
  return minuteOfDayOf(local) < kDayRolloverMinute ? date.addDays(-1) : date;
}

/// Wall-clock time on [date] in [loc] (DST-safe: nonexistent times roll
/// forward, repeated times use the first occurrence).
tz.TZDateTime wallTime(
  tz.Location loc,
  LocalDate date,
  MinuteOfDay minute,
) {
  final extraDays = minute ~/ 1440;
  final m = minute % 1440;
  final d = date.addDays(extraDays);
  return tz.TZDateTime(loc, d.year, d.month, d.day, m ~/ 60, m % 60);
}

/// A waking window for a logical day: wake instant → sleep instant.
class DayWindow {
  const DayWindow({
    required this.date,
    required this.location,
    required this.wake,
    required this.sleep,
  });

  /// Builds a window from wall-clock minutes. If [sleepMinute] ≤ [wakeMinute]
  /// the routine is overnight and sleep falls on the following calendar day.
  factory DayWindow.build({
    required LocalDate date,
    required tz.Location location,
    required MinuteOfDay wakeMinute,
    required MinuteOfDay sleepMinute,
  }) {
    final wake = wallTime(location, date, wakeMinute);
    final sleepDate = sleepMinute <= wakeMinute ? date.addDays(1) : date;
    final sleep = wallTime(location, sleepDate, sleepMinute);
    return DayWindow(
      date: date,
      location: location,
      wake: wake,
      sleep: sleep,
    );
  }

  final LocalDate date;
  final tz.Location location;
  final tz.TZDateTime wake;
  final tz.TZDateTime sleep;

  Duration get length => sleep.difference(wake);
  int get lengthMinutes => length.inMinutes;
}

/// Validation of a wake/sleep pair. Returns null when valid.
enum RoutineTimeError { wakeBeforeRollover, tooShort, overnightPastRollover }

RoutineTimeError? validateWakeSleep(MinuteOfDay wake, MinuteOfDay sleep) {
  if (wake < kDayRolloverMinute) return RoutineTimeError.wakeBeforeRollover;
  final overnight = sleep <= wake;
  final length = overnight ? (1440 - wake) + sleep : sleep - wake;
  if (overnight && sleep > kDayRolloverMinute) {
    return RoutineTimeError.overnightPastRollover;
  }
  if (length < 6 * 60) return RoutineTimeError.tooShort;
  return null;
}

/// Injectable clock. `offset` lets the debug menu simulate "tomorrow".
class AppClock {
  AppClock({DateTime Function()? source}) : _source = source ?? DateTime.now;

  final DateTime Function() _source;
  Duration offset = Duration.zero;

  DateTime now() => _source().add(offset);
}

/// Converts an absolute instant to wall-clock time in [loc].
tz.TZDateTime tzFrom(DateTime instant, tz.Location loc) => tz.TZDateTime.from(instant.toUtc(), loc);
