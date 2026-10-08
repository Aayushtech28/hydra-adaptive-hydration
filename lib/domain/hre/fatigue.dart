import '../models/enums.dart';
import 'types.dart';

/// Notification-fatigue estimation from resolved reminder outcomes.
///
/// `index = (ignored·1.0 + snoozed·0.5 + opened·0.2) / resolved`, over the
/// most recent [window] resolved reminders. Needs [minSample] resolved
/// reminders before it is considered meaningful (data sufficiency).
abstract final class FatigueCalculator {
  static const int window = 20;
  static const int minSample = 6;
  static const double moderateAt = 0.30;
  static const double highAt = 0.55;
  static const int suggestMinSample = 10;

  /// [outcomes] must be ordered oldest → newest. Pending/cancelled outcomes
  /// are ignored.
  static FatigueState compute(
    List<ReminderOutcome> outcomes, {
    bool alreadyAskedRecently = false,
  }) {
    final resolved = outcomes
        .where(
          (o) => o != ReminderOutcome.pending && o != ReminderOutcome.cancelled,
        )
        .toList();
    final recent = resolved.length > window
        ? resolved.sublist(resolved.length - window)
        : resolved;
    final n = recent.length;
    if (n < minSample) {
      return FatigueState(
        index: 0,
        level: FatigueLevel.low,
        sampleSize: n,
        sufficient: false,
      );
    }
    var weighted = 0.0;
    for (final o in recent) {
      weighted += switch (o) {
        ReminderOutcome.ignored => 1.0,
        ReminderOutcome.snoozed => 0.5,
        ReminderOutcome.opened => 0.2,
        _ => 0.0,
      };
    }
    final idx = (weighted / n).clamp(0.0, 1.0);
    final level = idx >= highAt
        ? FatigueLevel.high
        : idx >= moderateAt
        ? FatigueLevel.moderate
        : FatigueLevel.low;
    return FatigueState(
      index: idx,
      level: level,
      sampleSize: n,
      sufficient: true,
      suggestFewerReminders:
          level == FatigueLevel.high &&
          n >= suggestMinSample &&
          !alreadyAskedRecently,
    );
  }

  /// Consecutive trailing reminders with no engagement (ignored only).
  static int trailingUnanswered(List<ReminderOutcome> outcomes) {
    var n = 0;
    for (var i = outcomes.length - 1; i >= 0; i--) {
      final o = outcomes[i];
      if (o == ReminderOutcome.cancelled) continue;
      if (o == ReminderOutcome.ignored || o == ReminderOutcome.pending) {
        n++;
      } else {
        break;
      }
    }
    return n;
  }
}
