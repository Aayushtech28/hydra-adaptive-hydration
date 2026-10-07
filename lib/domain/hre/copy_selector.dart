import '../models/enums.dart';
import 'types.dart';

/// Chooses which notification sentence family (and variant) to use from
/// structured state. Pure; localization happens elsewhere.
abstract final class CopySelector {
  static const int variantsPerKey = 2;

  static (CopyKey, int) select({
    required NotificationTone tone,
    required ReminderMode mode,
    required PaceSnapshot snapshot,
    required List<ReasonCode> reasons,
    required int seed,
  }) {
    final variant = seed.abs() % variantsPerKey;

    if (reasons.contains(ReasonCode.firstOfDay)) {
      return (CopyKey.firstOfDay, variant);
    }
    if (reasons.contains(ReasonCode.workoutEnded)) {
      return (CopyKey.afterWorkout, variant);
    }
    if (snapshot.state == PaceState.dayClosing) {
      return (CopyKey.closing, variant);
    }
    if (snapshot.state == PaceState.significantlyBehind) {
      return (CopyKey.recovery, variant);
    }

    // Explicit tones win for calm states.
    switch (tone) {
      case NotificationTone.gentle:
        return (CopyKey.gentle, variant);
      case NotificationTone.neutral:
        return (CopyKey.neutral, variant);
      case NotificationTone.encouraging:
        return (CopyKey.encouraging, variant);
      case NotificationTone.progress:
        return (CopyKey.progress, variant);
      case NotificationTone.auto:
        break;
    }

    return switch (snapshot.state) {
      PaceState.ahead => (CopyKey.onPace, variant),
      PaceState.onTrack => (
          mode == ReminderMode.gentle ? CopyKey.gentle : CopyKey.neutral,
          variant
        ),
      PaceState.slightlyBehind => (CopyKey.behind, variant),
      _ => (CopyKey.neutral, variant),
    };
  }
}
