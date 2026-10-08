/// Reminder philosophy chosen by the user.
enum ReminderMode {
  gentle,
  balanced,
  focus;

  static ReminderMode parse(String? v) => ReminderMode.values.firstWhere(
    (m) => m.name == v,
    orElse: () => ReminderMode.balanced,
  );
}

/// How reminder copy sounds. `auto` lets the engine vary copy by state.
enum NotificationTone {
  auto,
  gentle,
  neutral,
  encouraging,
  progress;

  static NotificationTone parse(String? v) => NotificationTone.values
      .firstWhere((m) => m.name == v, orElse: () => NotificationTone.auto);
}

enum PaceState {
  ahead,
  onTrack,
  slightlyBehind,
  significantlyBehind,
  dayClosing,
}

/// Where a hydration entry came from. Used for dedupe/reconciliation.
enum EntrySource {
  manual,
  notificationAction,
  widget,
  healthkit,
  healthConnect,
  smartBottle,
  import;

  static EntrySource parse(String? v) => EntrySource.values.firstWhere(
    (m) => m.name == v,
    orElse: () => EntrySource.manual,
  );

  /// True for sources that originate outside HYDRA (never re-exported).
  bool get isExternal =>
      this == healthkit || this == healthConnect || this == smartBottle;
}

enum BeverageType { water, tea, coffee, other }

enum RoutineKind { weekday, weekend, work, study, workout, travel, custom }

enum ThemeChoice { system, light, dark }

enum HabitStage { remember, respond, predict, routine, automatic }

/// Outcome of a delivered reminder, resolved lazily (no delivery receipts on
/// either platform, so "ignored" means "no response within the window").
enum ReminderOutcome { pending, logged, opened, snoozed, ignored, cancelled }

enum ReminderType { adaptive, firstOfDay, recovery }
