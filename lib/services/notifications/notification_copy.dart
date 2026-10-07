import '../../domain/hre/types.dart';
import '../../l10n/gen/app_localizations.dart';

/// Resolves structured engine output to localized sentences. The text always
/// derives from the decision's own keys, so it cannot drift from the logic.
abstract final class NotificationCopy {
  static String body(AppLocalizations l, CopyKey key, int variant, {required int percent}) {
    final v = variant.abs() % 2;
    switch (key) {
      case CopyKey.firstOfDay:
        return v == 0 ? l.notifFirstOfDay1 : l.notifFirstOfDay2;
      case CopyKey.gentle:
        return v == 0 ? l.notifGentle1 : l.notifGentle2;
      case CopyKey.neutral:
        return v == 0 ? l.notifNeutral1 : l.notifNeutral2;
      case CopyKey.encouraging:
        return v == 0 ? l.notifEncouraging1 : l.notifEncouraging2;
      case CopyKey.progress:
        return v == 0 ? l.notifProgress1(percent) : l.notifProgress2(percent);
      case CopyKey.onPace:
        return v == 0 ? l.notifOnPace1 : l.notifOnPace2;
      case CopyKey.behind:
        return v == 0 ? l.notifBehind1 : l.notifBehind2;
      case CopyKey.recovery:
        return v == 0 ? l.notifRecovery1 : l.notifRecovery2;
      case CopyKey.closing:
        return v == 0 ? l.notifClosing1 : l.notifClosing2;
      case CopyKey.afterWorkout:
        return v == 0 ? l.notifAfterWorkout1 : l.notifAfterWorkout2;
    }
  }

  static String explain(AppLocalizations l, ExplanationKey key) => switch (key) {
        ExplanationKey.firstOfDay => l.whyFirstOfDay,
        ExplanationKey.onTrackScheduled => l.whyOnTrackScheduled,
        ExplanationKey.aheadStayQuiet => l.whyAheadStayQuiet,
        ExplanationKey.slightlyBehindEarlier => l.whySlightlyBehindEarlier,
        ExplanationKey.significantlyBehindSpread => l.whySignificantlyBehindSpread,
        ExplanationKey.snoozedUntil => l.whySnoozedUntil,
        ExplanationKey.quietHoursExit => l.whyQuietHoursExit,
        ExplanationKey.workoutEnded => l.whyWorkoutEnded,
        ExplanationKey.fatigueQuiet => l.whyFatigueQuiet,
        ExplanationKey.fatigueSlowed => l.whyFatigueSlowed,
        ExplanationKey.dayClosingTomorrow => l.whyDayClosingTomorrow,
        ExplanationKey.goalReachedTomorrow => l.whyGoalReachedTomorrow,
        ExplanationKey.pausedUntilLog => l.whyPausedUntilLog,
        ExplanationKey.pausedUntilTime => l.whyPausedUntilTime,
        ExplanationKey.remindersOff => l.whyRemindersOff,
      };
}
