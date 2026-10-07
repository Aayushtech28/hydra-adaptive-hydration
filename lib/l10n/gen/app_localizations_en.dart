// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'HYDRA';

  @override
  String get tagline => 'Hydration that adapts to your day.';

  @override
  String get notifChannelName => 'Hydration check-ins';

  @override
  String get notifChannelDescription =>
      'Gentle, adaptive reminders to keep you on pace.';

  @override
  String get notifTitle => 'HYDRA';

  @override
  String get notifFirstOfDay1 => 'Good morning. Ready for a first sip?';

  @override
  String get notifFirstOfDay2 => 'A glass to start the day?';

  @override
  String get notifGentle1 => 'A small sip is enough.';

  @override
  String get notifGentle2 => 'No rush. A little water when you can.';

  @override
  String get notifNeutral1 => 'Ready for your next drink?';

  @override
  String get notifNeutral2 => 'Time for your next hydration check.';

  @override
  String get notifEncouraging1 => 'You\'re doing well. Keep your rhythm going.';

  @override
  String get notifEncouraging2 => 'Your rhythm is looking good.';

  @override
  String notifProgress1(int percent) {
    return 'You\'re $percent% through today\'s plan.';
  }

  @override
  String notifProgress2(int percent) {
    return '$percent% of today\'s plan so far. Nice pace.';
  }

  @override
  String get notifOnPace1 => 'You\'re still on pace.';

  @override
  String get notifOnPace2 => 'Right on rhythm. A sip keeps it that way.';

  @override
  String get notifBehind1 =>
      'A small drink will bring you back toward your plan.';

  @override
  String get notifBehind2 => 'A little behind pace. A few sips will help.';

  @override
  String get notifRecovery1 =>
      'Missed the last one? No problem. We\'ve adjusted the next check-in.';

  @override
  String get notifRecovery2 =>
      'We\'ve spread your plan across the rest of the day. One sip is a good start.';

  @override
  String get notifClosing1 => 'Your day is winding down. No need to catch up.';

  @override
  String get notifClosing2 =>
      'Nothing to force tonight. Tomorrow we\'ll start earlier.';

  @override
  String get notifAfterWorkout1 => 'Nice work. A drink after your workout?';

  @override
  String get notifAfterWorkout2 => 'Workout done. Time for some water?';

  @override
  String notifActionAdd(String amount) {
    return '+$amount';
  }

  @override
  String get notifActionSnooze => 'Snooze 30 min';

  @override
  String get whyFirstOfDay =>
      'This is your first check-in of the day, shortly after you wake up.';

  @override
  String get whyOnTrackScheduled =>
      'You\'re on track, so we\'re keeping the usual spacing.';

  @override
  String get whyAheadStayQuiet =>
      'You\'re ahead of your plan, so we\'ll stay quiet for longer.';

  @override
  String get whySlightlyBehindEarlier =>
      'You\'re slightly behind your plan, so we moved this reminder earlier.';

  @override
  String get whySignificantlyBehindSpread =>
      'You\'re behind your plan. We\'re spreading what\'s left across your remaining time instead of asking for a big catch-up.';

  @override
  String get whySnoozedUntil => 'You snoozed, so we\'ll check in again then.';

  @override
  String get whyQuietHoursExit =>
      'This was moved to the end of your quiet time.';

  @override
  String get whyWorkoutEnded => 'We waited until your workout window ended.';

  @override
  String get whyFatigueQuiet =>
      'You haven\'t needed the last few reminders, so we\'re quiet until tomorrow.';

  @override
  String get whyFatigueSlowed =>
      'You\'ve been responding to fewer reminders, so we\'re spacing them out more.';

  @override
  String get whyDayClosingTomorrow =>
      'Your day is almost over. We won\'t force a catch-up. Tomorrow we\'ll start earlier.';

  @override
  String get whyGoalReachedTomorrow =>
      'You\'ve reached today\'s target. Next check-in is tomorrow morning.';

  @override
  String get whyPausedUntilLog => 'Reminders are paused until you log a drink.';

  @override
  String get whyPausedUntilTime =>
      'Reminders are paused until the time you chose.';

  @override
  String get whyRemindersOff =>
      'Reminders are turned off. HYDRA still tracks your pace.';
}
