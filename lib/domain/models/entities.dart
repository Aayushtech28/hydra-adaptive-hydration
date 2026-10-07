import '../../core/time/local_date.dart';
import '../../core/units/volume_unit.dart';
import 'enums.dart';

class HydrationEntry {
  const HydrationEntry({
    required this.id,
    required this.timestampUtc,
    required this.timezone,
    required this.localDate,
    required this.volumeMl,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.beverage = BeverageType.water,
    this.vesselId,
    this.externalRecordId,
  });

  final String id;

  /// Absolute instant. Never rewritten when the device timezone changes.
  final DateTime timestampUtc;

  /// IANA zone in effect when the entry was logged.
  final String timezone;

  /// Logical date in [timezone] at log time (stored so history is stable).
  final LocalDate localDate;

  /// Canonical volume in millilitres.
  final int volumeMl;
  final BeverageType beverage;
  final String? vesselId;
  final EntrySource source;
  final String? externalRecordId;
  final DateTime createdAt;
  final DateTime updatedAt;

  HydrationEntry copyWith({
    DateTime? timestampUtc,
    String? timezone,
    LocalDate? localDate,
    int? volumeMl,
    String? vesselId,
    bool clearVessel = false,
    String? externalRecordId,
    DateTime? updatedAt,
  }) =>
      HydrationEntry(
        id: id,
        timestampUtc: timestampUtc ?? this.timestampUtc,
        timezone: timezone ?? this.timezone,
        localDate: localDate ?? this.localDate,
        volumeMl: volumeMl ?? this.volumeMl,
        beverage: beverage,
        vesselId: clearVessel ? null : (vesselId ?? this.vesselId),
        source: source,
        externalRecordId: externalRecordId ?? this.externalRecordId,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class Vessel {
  const Vessel({
    required this.id,
    required this.name,
    required this.volumeMl,
    required this.icon,
    required this.isFavorite,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int volumeMl;
  final String icon;
  final bool isFavorite;
  final int sortOrder;

  Vessel copyWith({
    String? name,
    int? volumeMl,
    String? icon,
    bool? isFavorite,
    int? sortOrder,
  }) =>
      Vessel(
        id: id,
        name: name ?? this.name,
        volumeMl: volumeMl ?? this.volumeMl,
        icon: icon ?? this.icon,
        isFavorite: isFavorite ?? this.isFavorite,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}

/// A wall-clock span within a day, possibly crossing midnight.
class TimeSpan {
  const TimeSpan(this.startMinute, this.endMinute);
  final int startMinute;
  final int endMinute;

  bool get isOvernight => endMinute <= startMinute;

  Map<String, int> toJson() => {'s': startMinute, 'e': endMinute};
  static TimeSpan? fromJson(Object? j) {
    if (j is! Map) return null;
    final s = j['s'];
    final e = j['e'];
    if (s is! int || e is! int) return null;
    if (s < 0 || s > 1439 || e < 0 || e > 1439) return null;
    return TimeSpan(s, e);
  }

  @override
  bool operator ==(Object other) =>
      other is TimeSpan &&
      other.startMinute == startMinute &&
      other.endMinute == endMinute;
  @override
  int get hashCode => Object.hash(startMinute, endMinute);
}

class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.kind,
    required this.weekdays,
    required this.wakeMinute,
    required this.sleepMinute,
    required this.mode,
    required this.quietSpans,
    required this.workoutSpans,
    required this.quickAddsMl,
    required this.enabled,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final RoutineKind kind;

  /// ISO weekdays (1 = Monday … 7 = Sunday) this routine applies to.
  final Set<int> weekdays;
  final int wakeMinute;
  final int sleepMinute;
  final ReminderMode mode;
  final List<TimeSpan> quietSpans;
  final List<TimeSpan> workoutSpans;

  /// Preferred quick-add amounts for this routine (empty = use profile's).
  final List<int> quickAddsMl;
  final bool enabled;

  /// The built-in fallback routine every profile has. Cannot be deleted.
  final bool isDefault;

  Routine copyWith({
    String? name,
    RoutineKind? kind,
    Set<int>? weekdays,
    int? wakeMinute,
    int? sleepMinute,
    ReminderMode? mode,
    List<TimeSpan>? quietSpans,
    List<TimeSpan>? workoutSpans,
    List<int>? quickAddsMl,
    bool? enabled,
  }) =>
      Routine(
        id: id,
        name: name ?? this.name,
        kind: kind ?? this.kind,
        weekdays: weekdays ?? this.weekdays,
        wakeMinute: wakeMinute ?? this.wakeMinute,
        sleepMinute: sleepMinute ?? this.sleepMinute,
        mode: mode ?? this.mode,
        quietSpans: quietSpans ?? this.quietSpans,
        workoutSpans: workoutSpans ?? this.workoutSpans,
        quickAddsMl: quickAddsMl ?? this.quickAddsMl,
        enabled: enabled ?? this.enabled,
        isDefault: isDefault,
      );
}

class UserProfile {
  const UserProfile({
    required this.createdAt,
    required this.locale,
    required this.timezone,
    required this.unit,
    required this.dailyTargetMl,
    required this.targetIsUserChosen,
    required this.wakeMinute,
    required this.sleepMinute,
    required this.mode,
    required this.tone,
    required this.weekendWakeMinute,
    required this.weekendSleepMinute,
    required this.weekendDifferent,
    required this.quickAddsMl,
    required this.onboardingComplete,
    required this.remindersEnabled,
    required this.theme,
    required this.activeRoutineId,
    required this.environmentHot,
  });

  final DateTime createdAt;
  final String? locale;

  /// Last timezone the app scheduled for (used to detect travel).
  final String timezone;
  final VolumeUnit unit;
  final int dailyTargetMl;
  final bool targetIsUserChosen;
  final int wakeMinute;
  final int sleepMinute;
  final ReminderMode mode;
  final NotificationTone tone;
  final bool weekendDifferent;
  final int weekendWakeMinute;
  final int weekendSleepMinute;
  final List<int> quickAddsMl;
  final bool onboardingComplete;
  final bool remindersEnabled;
  final ThemeChoice theme;

  /// Manually selected routine (one-tap switch); null = automatic by weekday.
  final String? activeRoutineId;

  /// User-declared environment: normal vs hot. Informational for the planner.
  final bool environmentHot;

  UserProfile copyWith({
    String? locale,
    String? timezone,
    VolumeUnit? unit,
    int? dailyTargetMl,
    bool? targetIsUserChosen,
    int? wakeMinute,
    int? sleepMinute,
    ReminderMode? mode,
    NotificationTone? tone,
    bool? weekendDifferent,
    int? weekendWakeMinute,
    int? weekendSleepMinute,
    List<int>? quickAddsMl,
    bool? onboardingComplete,
    bool? remindersEnabled,
    ThemeChoice? theme,
    String? activeRoutineId,
    bool clearActiveRoutine = false,
    bool? environmentHot,
  }) =>
      UserProfile(
        createdAt: createdAt,
        locale: locale ?? this.locale,
        timezone: timezone ?? this.timezone,
        unit: unit ?? this.unit,
        dailyTargetMl: dailyTargetMl ?? this.dailyTargetMl,
        targetIsUserChosen: targetIsUserChosen ?? this.targetIsUserChosen,
        wakeMinute: wakeMinute ?? this.wakeMinute,
        sleepMinute: sleepMinute ?? this.sleepMinute,
        mode: mode ?? this.mode,
        tone: tone ?? this.tone,
        weekendDifferent: weekendDifferent ?? this.weekendDifferent,
        weekendWakeMinute: weekendWakeMinute ?? this.weekendWakeMinute,
        weekendSleepMinute: weekendSleepMinute ?? this.weekendSleepMinute,
        quickAddsMl: quickAddsMl ?? this.quickAddsMl,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        theme: theme ?? this.theme,
        activeRoutineId:
            clearActiveRoutine ? null : (activeRoutineId ?? this.activeRoutineId),
        environmentHot: environmentHot ?? this.environmentHot,
      );
}

/// A reminder the app scheduled and later resolved.
class ReminderEvent {
  const ReminderEvent({
    required this.id,
    required this.scheduledAt,
    required this.localDate,
    required this.type,
    required this.outcome,
    required this.reason,
    required this.algorithmVersion,
    this.resolvedAt,
  });

  final String id;
  final DateTime scheduledAt;
  final LocalDate localDate;
  final ReminderType type;
  final ReminderOutcome outcome;

  /// Comma-separated ReasonCode names (kept for explainability/debug).
  final String reason;
  final String algorithmVersion;
  final DateTime? resolvedAt;

  ReminderEvent copyWith({ReminderOutcome? outcome, DateTime? resolvedAt}) =>
      ReminderEvent(
        id: id,
        scheduledAt: scheduledAt,
        localDate: localDate,
        type: type,
        outcome: outcome ?? this.outcome,
        reason: reason,
        algorithmVersion: algorithmVersion,
        resolvedAt: resolvedAt ?? this.resolvedAt,
      );
}
