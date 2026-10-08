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

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonOn => 'On';

  @override
  String get commonOff => 'Off';

  @override
  String get commonLearnMore => 'Learn more';

  @override
  String get commonProBadge => 'Pro';

  @override
  String get commonLoadFailed => 'Couldn\'t load this right now.';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navInsights => 'Insights';

  @override
  String get navYou => 'You';

  @override
  String get onbWelcomeTitle => 'Hydration that adapts to your day.';

  @override
  String get onbWelcomeBody =>
      'HYDRA learns your rhythm and quietly keeps you on pace. The smarter it gets, the quieter it gets.';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbWakeTitle => 'When do you usually start your day?';

  @override
  String get onbWakeBody => 'Your first check-in will come shortly after this.';

  @override
  String get onbSleepTitle => 'When does your day usually end?';

  @override
  String get onbSleepBody =>
      'HYDRA stays quiet from your last check-in until you wake.';

  @override
  String get onbTimeTooShort =>
      'That\'s a very short day. Try at least six hours between waking and sleeping.';

  @override
  String get onbTimeWakeEarly =>
      'Wake times before 4:00 are not supported. Pick a later time.';

  @override
  String get onbTimeOvernight =>
      'Overnight days can end by 4:00 at the latest.';

  @override
  String get onbStyleTitle => 'How much prompting do you prefer?';

  @override
  String get onbStyleBody =>
      'You can change this any time, and HYDRA adapts as it learns.';

  @override
  String get styleGentle => 'Gentle';

  @override
  String get styleGentleBody => 'Fewer, softer reminders and a quieter day.';

  @override
  String get styleBalanced => 'Balanced';

  @override
  String get styleBalancedBody => 'A steady rhythm that adapts to your pace.';

  @override
  String get styleFocus => 'Focus';

  @override
  String get styleFocusBody =>
      'More persistent check-ins for people who often forget.';

  @override
  String get onbUnitTitle => 'Choose your measurement.';

  @override
  String get onbUnitBody =>
      'Everything is stored in millilitres, so you can switch whenever you like.';

  @override
  String get unitMl => 'Millilitres (ml)';

  @override
  String get unitL => 'Litres (L)';

  @override
  String get unitFlOz => 'US fluid ounces (fl oz)';

  @override
  String get unitCups => 'US cups';

  @override
  String get onbTargetTitle => 'Set your daily target.';

  @override
  String get onbTargetBody =>
      'This is the amount you choose. It isn\'t medical advice.';

  @override
  String get onbStarterTarget => 'Starter target';

  @override
  String get onbStarterTargetBody =>
      'A general planning preset. Adjust it to whatever suits you.';

  @override
  String get onbCustomTarget => 'Custom target';

  @override
  String get onbYourTarget => 'Your target';

  @override
  String get onbYourTargetBody =>
      'How much you want to drink each day. You decide this.';

  @override
  String get onbHydraSchedule => 'HYDRA schedule';

  @override
  String get onbHydraScheduleBody =>
      'When to check in during your day. HYDRA decides this and adapts it.';

  @override
  String onbTargetInvalid(String min, String max) {
    return 'Enter a target between $min and $max.';
  }

  @override
  String get onbReadyTitle => 'Your hydration rhythm is ready.';

  @override
  String get onbReadyNotifTitle => 'Notifications';

  @override
  String get onbReadyNotifBody =>
      'HYDRA can remind you at the right moments, and you can log right from the notification.';

  @override
  String get onbReadyPrivacyTitle => 'Private by design';

  @override
  String get onbReadyPrivacyBody =>
      'Your hydration history stays on this device. No account needed.';

  @override
  String get onbReadyHealthTitle => 'Optional Health sync';

  @override
  String get onbReadyHealthBody =>
      'After you\'ve logged a few drinks, you can choose to sync with your health app.';

  @override
  String get onbAllowNotifications => 'Allow notifications';

  @override
  String get onbStartWithout => 'Start without reminders';

  @override
  String get onbStart => 'Open HYDRA';

  @override
  String onbStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get dashGreetMorning => 'Good morning';

  @override
  String get dashGreetAfternoon => 'Good afternoon';

  @override
  String get dashGreetEvening => 'Good evening';

  @override
  String get dashGreetNight => 'Hello';

  @override
  String get dashToday => 'Today';

  @override
  String dashConsumedOfTarget(String consumed, String target) {
    return '$consumed / $target';
  }

  @override
  String dashProgressSemantics(String percent, String consumed, String target) {
    return '$percent percent of today\'s target. $consumed of $target.';
  }

  @override
  String get paceAhead => 'Ahead of pace';

  @override
  String get paceOnTrack => 'On pace';

  @override
  String get paceSlightlyBehind => 'Adjusting';

  @override
  String get paceNeedsAttention => 'Needs attention';

  @override
  String get paceDayClosing => 'Day winding down';

  @override
  String get paceGoalReached => 'Goal reached';

  @override
  String get paceBeforeWake => 'Your day starts soon';

  @override
  String paceFinishBy(String time) {
    return 'On pace to finish by $time';
  }

  @override
  String get paceFinishLater =>
      'At this pace you\'d finish after your planned window. We\'ll adjust gently.';

  @override
  String get paceGoalReachedBody =>
      'You\'ve reached today\'s target. Nicely done.';

  @override
  String get paceClosingBody =>
      'No need to force a catch-up tonight. Tomorrow starts fresh.';

  @override
  String paceSpreadBody(String amount) {
    return 'About $amount per check-in keeps you comfortable.';
  }

  @override
  String get nextReminderTitle => 'Next reminder';

  @override
  String nextReminderAt(String time) {
    return '$time';
  }

  @override
  String nextReminderTomorrowAt(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String get nextReminderNone => 'No reminder scheduled';

  @override
  String get nextReminderPaused => 'Paused';

  @override
  String get nextReminderOff => 'Reminders are off';

  @override
  String get nextReminderWhy => 'Why now?';

  @override
  String nextReminderLastDrink(String minutes) {
    return 'Last drink $minutes min ago.';
  }

  @override
  String get nextReminderPause => 'Pause';

  @override
  String get nextReminderResume => 'Resume';

  @override
  String get pause15 => '15 minutes';

  @override
  String get pause30 => '30 minutes';

  @override
  String get pause60 => '1 hour';

  @override
  String get pauseUntil3pm => 'Until 3 PM';

  @override
  String get pauseUntilLog => 'Until I log again';

  @override
  String get pauseWelcomeBack => 'Welcome back. Picking up where you left off.';

  @override
  String get quickAddTitle => 'Quick add';

  @override
  String get quickAddCustom => 'Custom';

  @override
  String get quickAddVessels => 'My vessels';

  @override
  String logged(String amount) {
    return 'Logged $amount';
  }

  @override
  String get loggedUndone => 'Removed';

  @override
  String get logFailed => 'That amount isn\'t valid.';

  @override
  String get timelineTitle => 'Today';

  @override
  String get timelineEmptyTitle => 'First day starts here.';

  @override
  String get timelineEmptyBody =>
      'Tap an amount above when you drink. HYDRA will start learning your rhythm from your first log.';

  @override
  String timelineEntry(String time, String amount) {
    return '$time · $amount';
  }

  @override
  String get entryEdit => 'Edit entry';

  @override
  String get entryDeleted => 'Entry removed';

  @override
  String entryAmount(String unit) {
    return 'Amount ($unit)';
  }

  @override
  String get entryTime => 'Time';

  @override
  String get entryDate => 'Date';

  @override
  String get entryYesterday => 'Yesterday';

  @override
  String get entryNow => 'Now';

  @override
  String get logSheetTitle => 'Add hydration';

  @override
  String get logSheetLog => 'Log now';

  @override
  String get logSheetRecent => 'Recent';

  @override
  String get logSheetLogAt => 'Log at';

  @override
  String get logSheetFuture => 'That time is in the future.';

  @override
  String get insightCardTitle => 'Today\'s insight';

  @override
  String get insightNoData =>
      'Log your first drink and HYDRA will begin learning your rhythm.';

  @override
  String get insightFirstDay =>
      'You\'ve started your first day. Patterns appear after about a week.';

  @override
  String insightEarlyDays(String days) {
    return '$days days in. A little more history and HYDRA can spot your patterns.';
  }

  @override
  String insightMorningStrength(String percent) {
    return 'Your mornings are consistently strong ($percent% of your morning plan).';
  }

  @override
  String insightAfternoonDrift(String percent) {
    return 'Your afternoon is where your rhythm usually drifts ($percent% of the plan).';
  }

  @override
  String insightEveningDrift(String percent) {
    return 'Evenings are where you tend to fall behind ($percent% of the plan).';
  }

  @override
  String insightEarlyFirstDrink(String minutes) {
    return 'Your strongest days start with a drink within $minutes minutes of waking.';
  }

  @override
  String get insightWeekdayStable =>
      'Your routine holds steady on weekdays and weekends.';

  @override
  String insightWeekendVariance(String weekday, String weekend) {
    return 'Weekdays average $weekday% of plan versus $weekend% on weekends.';
  }

  @override
  String insightReminderResponse(String percent, String count) {
    return 'You logged after $percent% of your last $count reminders.';
  }

  @override
  String insightRoutineImprovement(String points) {
    return 'Your routine improved by $points points since last week.';
  }

  @override
  String get insightRecovery =>
      'Yesterday didn\'t erase your progress. Your rhythm is still building.';

  @override
  String get tzChangedTitle => 'Your timezone changed';

  @override
  String tzChangedBody(String zone) {
    return 'HYDRA moved your reminders to $zone local time. Your history stays exactly as it was.';
  }

  @override
  String get tzChangedAdjust => 'Got it';

  @override
  String get fatigueTitle => 'Want fewer reminders?';

  @override
  String get fatigueBody =>
      'You haven\'t needed many recent reminders. We can make HYDRA quieter.';

  @override
  String get fatigueAccept => 'Make it quieter';

  @override
  String get fatigueDecline => 'Keep as is';

  @override
  String get permNudgeTitle => 'Reminders are off';

  @override
  String get permNudgeBody =>
      'Notifications are turned off for HYDRA. Tracking still works; turn them on if you\'d like reminders.';

  @override
  String get permNudgeAction => 'Allow notifications';

  @override
  String get healthNudgeTitle => 'Sync with your health app?';

  @override
  String get healthNudgeBody =>
      'Optional. HYDRA only reads and writes water intake, and works fine without it.';

  @override
  String get healthNudgeAction => 'Set up Health sync';

  @override
  String get disclaimerShort =>
      'HYDRA is a wellness and habit tool, not medical advice. If you have a medical condition or a clinician-directed fluid limit, follow your healthcare professional\'s guidance.';

  @override
  String a11yLogAmount(String amount) {
    return 'Log $amount';
  }

  @override
  String a11yVesselLog(String name, String amount) {
    return 'Log $name, $amount';
  }

  @override
  String get a11yDeleteEntry => 'Delete entry';

  @override
  String get a11yRemindersMenu => 'Reminder options';

  @override
  String get dashAllEntries => 'Show details';

  @override
  String get dashWhyHide => 'Hide';

  @override
  String dashLastLogged(String time) {
    return 'Last logged $time';
  }

  @override
  String get dashLogFailedOffline => 'Couldn\'t save that. Please try again.';

  @override
  String get logSheetAmountHint => 'Amount';

  @override
  String get logSheetVesselsEmpty =>
      'Add a bottle or glass in You → Vessels for one-tap logging.';

  @override
  String get logSheetEditing => 'Edit entry';

  @override
  String get logSheetSaved => 'Saved';

  @override
  String get entryConfirmDeleteTitle => 'Remove this entry?';

  @override
  String get entryConfirmDeleteBody => 'Your total and pace will update.';

  @override
  String get proRequiredHistoryEdit =>
      'Editing past days is part of HYDRA Pro.';

  @override
  String get pace3Seconds => 'Pace';

  @override
  String get historyTitle => 'History';

  @override
  String get historyDay => 'Day';

  @override
  String get historyWeek => 'Week';

  @override
  String get historyMonth => 'Month';

  @override
  String get historyCalendar => 'Calendar';

  @override
  String historyDayTotal(String amount, String target) {
    return '$amount of $target';
  }

  @override
  String get historyPrevDay => 'Previous day';

  @override
  String get historyNextDay => 'Next day';

  @override
  String get historyToday => 'Today';

  @override
  String get historyNoEntriesTitle => 'Nothing logged this day';

  @override
  String get historyNoEntriesBody =>
      'Entries you log appear here. You can add one for this day with Custom.';

  @override
  String get historyFutureTitle => 'This day hasn\'t happened yet';

  @override
  String get historyFutureBody => 'Come back once it\'s underway.';

  @override
  String get historyPlanVsActual => 'Plan vs. actual';

  @override
  String historyChartSemantics(String planned, String actual) {
    return 'Planned $planned, actual $actual';
  }

  @override
  String get historyLegendPlan => 'Plan';

  @override
  String get historyLegendActual => 'Actual';

  @override
  String get historyWeekEmptyTitle => 'No weekly history yet';

  @override
  String get historyWeekEmptyBody =>
      'After a few days of logging, your week appears here as a calm overview, not a scoreboard.';

  @override
  String get historyDayStatusOnPlan => 'On plan';

  @override
  String get historyDayStatusSteady => 'Building';

  @override
  String get historyDayStatusAttention => 'Needs attention';

  @override
  String get historyDayStatusNoData => 'No data';

  @override
  String historyDayPercentStatus(String percent, String status) {
    return '$percent% · $status';
  }

  @override
  String get historyMonthTrendTitle => 'Weekly rhythm';

  @override
  String historyMonthSummary(String days, String complete) {
    return '$days active days · $complete on plan';
  }

  @override
  String historyMonthAverage(String percent) {
    return 'Average plan adherence $percent%';
  }

  @override
  String get historyMonthEmptyTitle => 'Your month starts here';

  @override
  String get historyMonthEmptyBody =>
      'Trends appear once there are a few days of history to compare.';

  @override
  String historyCalendarCell(String date, String status) {
    return '$date: $status';
  }

  @override
  String get historyEditPro => 'Editing earlier days is part of HYDRA Pro.';

  @override
  String historyWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get adLabel => 'Advertisement';

  @override
  String get adSponsored => 'Sponsored';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get momentumTitle => 'Hydration momentum';

  @override
  String get momentumDisclaimer =>
      'A behaviour score about your routine. It isn\'t a health measure.';

  @override
  String get momentumTierBuilding => 'Building';

  @override
  String get momentumTierSteady => 'Steady';

  @override
  String get momentumTierStrong => 'Strong';

  @override
  String get momentumTierExcellent => 'Excellent';

  @override
  String momentumTrendUp(String points) {
    return 'Up $points from the previous two weeks';
  }

  @override
  String momentumTrendDown(String points) {
    return 'Down $points from the previous two weeks';
  }

  @override
  String get momentumTrendFlat => 'Holding steady';

  @override
  String get momentumInsufficient =>
      'Momentum appears after about five days of use. There\'s no rush.';

  @override
  String get momentumComponentConsistency => 'Consistency';

  @override
  String get momentumComponentStability => 'Routine stability';

  @override
  String get momentumComponentResponse => 'Reminder response';

  @override
  String get momentumComponentTiming => 'Plan timing';

  @override
  String get momentumComponentIndependence => 'Self-started logging';

  @override
  String get consistencyTitle => 'Consistency';

  @override
  String get consistencyBody =>
      'Your last 30 days, with recent days counting a little more. One quiet day doesn\'t undo your rhythm.';

  @override
  String get consistencyInsufficient =>
      'Consistency appears after about three days.';

  @override
  String get consistencyBuilding => 'You\'re building a reliable rhythm.';

  @override
  String get streakTitle => 'Streak';

  @override
  String streakDays(String days) {
    return '$days days';
  }

  @override
  String streakBest(String days) {
    return 'Best: $days';
  }

  @override
  String get streakRecovery =>
      'A recovery day is available, so one miss won\'t reset you.';

  @override
  String get streakRecoveryUsed => 'Yesterday didn\'t end your streak.';

  @override
  String get independenceTitle => 'Reminder independence';

  @override
  String independenceCelebrate(String percent) {
    return 'You needed $percent% fewer reminders than when you started.';
  }

  @override
  String get independenceCelebrateBody =>
      'Your consistency held while you relied on reminders less. That\'s habit forming.';

  @override
  String get independenceSteady =>
      'Your reminder use is steady. HYDRA never reduces reminders just to improve this number.';

  @override
  String get independenceInsufficient =>
      'This appears after about four weeks of use.';

  @override
  String get habitTitle => 'Habit stage';

  @override
  String habitNext(String stage) {
    return 'Next: $stage';
  }

  @override
  String get stageRemember => 'Remember';

  @override
  String get stageRememberBody => 'HYDRA reminds you while you settle in.';

  @override
  String get stageRespond => 'Respond';

  @override
  String get stageRespondBody => 'You regularly act on reminders.';

  @override
  String get stagePredict => 'Predict';

  @override
  String get stagePredictBody =>
      'Your routine is becoming predictable, so HYDRA can time reminders better.';

  @override
  String get stageRoutine => 'Routine';

  @override
  String get stageRoutineBody => 'Hydration fits into your day.';

  @override
  String get stageAutomatic => 'Automatic';

  @override
  String get stageAutomaticBody =>
      'It\'s second nature now. HYDRA mostly stays quiet.';

  @override
  String get insightsPatternsTitle => 'Patterns';

  @override
  String get challengesTitle => 'Challenges';

  @override
  String get challengesBody =>
      'Gentle goals about routine, never about drinking more.';

  @override
  String challengeProgress(String progress, String goal) {
    return '$progress of $goal';
  }

  @override
  String get challengeCompleted => 'Completed';

  @override
  String get challengeMorningMomentumTitle => 'Morning Momentum';

  @override
  String get challengeMorningMomentumBody =>
      'Have your first drink within 90 minutes of waking.';

  @override
  String get challengeQuietConsistencyTitle => 'Quiet Consistency';

  @override
  String get challengeQuietConsistencyBody =>
      'Stay on plan with three reminders or fewer in a day.';

  @override
  String get challengeWeekdayRhythmTitle => 'Weekday Rhythm';

  @override
  String get challengeWeekdayRhythmBody =>
      'Keep your routine going on weekdays.';

  @override
  String get challengeAfternoonRescueTitle => 'Afternoon Rescue';

  @override
  String get challengeAfternoonRescueBody =>
      'Stay on plan through the afternoon.';

  @override
  String get challengeRoutineBuilderTitle => 'Routine Builder';

  @override
  String get challengeRoutineBuilderBody => 'Start your day at a similar time.';

  @override
  String challengeWindow(String days) {
    return 'Last $days days';
  }

  @override
  String get challengesEmptyTitle => 'No active challenges';

  @override
  String get challengesEmptyBody =>
      'Challenges appear here when they\'re available.';

  @override
  String get recapWeeklyTitle => 'Your week';

  @override
  String get recapWeeklyCta => 'See your week';

  @override
  String get recapMonthlyTitle => 'Your month';

  @override
  String get recapMonthlyCta => 'See your month';

  @override
  String get recapNeedMoreTitle => 'Your first recap is on its way';

  @override
  String get recapNeedMoreBody =>
      'A weekly recap appears after about three days of use.';

  @override
  String get recapConsistency => 'Consistency';

  @override
  String get recapStrongestDay => 'Strongest day';

  @override
  String get recapBestWindow => 'Most consistent window';

  @override
  String get recapOpportunity => 'Biggest opportunity';

  @override
  String get recapCompletion => 'Plan completion';

  @override
  String recapCompletionValue(String done, String total) {
    return '$done of $total days';
  }

  @override
  String get recapResponse => 'Reminder response';

  @override
  String get recapTrend => 'Compared with last week';

  @override
  String recapTrendUp(String points) {
    return 'Up $points points';
  }

  @override
  String recapTrendDown(String points) {
    return 'Down $points points';
  }

  @override
  String get recapTrendFlat => 'About the same';

  @override
  String get recapReminders => 'Reminders per day';

  @override
  String recapRemindersFewer(String percent) {
    return '$percent% fewer than last week';
  }

  @override
  String recapRemindersMore(String percent) {
    return '$percent% more than last week';
  }

  @override
  String get recapEncourageUp => 'You\'re becoming more consistent.';

  @override
  String get recapEncourageSteady => 'Your rhythm is holding steady.';

  @override
  String get recapEncourageDown =>
      'A quieter week. Your rhythm is still there.';

  @override
  String get recapShare => 'Share';

  @override
  String get recapShareChoose => 'Choose what to include';

  @override
  String get recapShareHint =>
      'Only the items you tick are added to the image.';

  @override
  String get recapShareFailed => 'Couldn\'t create the image.';

  @override
  String get segMorning => 'Morning';

  @override
  String get segAfternoon => 'Afternoon';

  @override
  String get segEvening => 'Evening';

  @override
  String get recapMonthlyActive => 'Active days';

  @override
  String get recapMonthlyBestRoutine => 'Best routine';

  @override
  String get recapMonthlyFavoriteVessel => 'Favorite vessel';

  @override
  String get recapMonthlyImproved => 'Most improved';

  @override
  String get recapMonthlyHabit => 'Habit stage';

  @override
  String get recapMonthlyMomentum => 'Momentum';

  @override
  String get recapMonthlyLocked =>
      'The full monthly report is part of HYDRA Pro.';

  @override
  String get recapMonthlyWatch => 'Watch a short ad to see it once';

  @override
  String get recapMonthlyUnlock => 'Unlock with HYDRA Pro';

  @override
  String get recapMonthlyAdFailed =>
      'No ad is available right now. Try again later.';

  @override
  String get routineKindWeekday => 'Weekday';

  @override
  String get routineKindWeekend => 'Weekend';

  @override
  String get routineKindWork => 'Work';

  @override
  String get routineKindStudy => 'Study';

  @override
  String get routineKindWorkout => 'Workout';

  @override
  String get routineKindTravel => 'Travel';

  @override
  String get routineKindCustom => 'Custom';

  @override
  String get youTitle => 'You';

  @override
  String get youProCardTitle => 'HYDRA Pro';

  @override
  String get youProCardBody =>
      'Your hydration system, optimized around your life.';

  @override
  String get youProActive => 'HYDRA Pro is active';

  @override
  String get youProManage => 'Manage subscription';

  @override
  String get youSectionPlan => 'Your plan';

  @override
  String get youSectionReminders => 'Reminders';

  @override
  String get youSectionData => 'Data and connections';

  @override
  String get youSectionApp => 'App';

  @override
  String get youGoal => 'Daily target';

  @override
  String get youSchedule => 'Wake and sleep';

  @override
  String get youStyle => 'Reminder style';

  @override
  String get youRoutines => 'Routines';

  @override
  String get youVessels => 'Vessels';

  @override
  String get youUnits => 'Measurement';

  @override
  String get youNotifications => 'Notifications';

  @override
  String get youHealth => 'Health sync';

  @override
  String get youPrivacy => 'Privacy Center';

  @override
  String get youAppearance => 'Appearance';

  @override
  String get youSupport => 'Help and support';

  @override
  String get youDebug => 'Developer tools';

  @override
  String get goalTitle => 'Daily target';

  @override
  String get goalBody =>
      'This is the amount you choose to aim for. HYDRA never changes it on its own, and it isn\'t medical advice.';

  @override
  String get goalCurrent => 'Current target';

  @override
  String get goalSave => 'Save target';

  @override
  String get goalSaved => 'Target updated';

  @override
  String get goalHotNote =>
      'If it\'s hot or you\'re very active, you may want a higher target. That\'s your call.';

  @override
  String get scheduleTitle => 'Wake and sleep';

  @override
  String get scheduleBody =>
      'HYDRA spreads your target across your waking hours and stays quiet while you sleep.';

  @override
  String get scheduleWake => 'Wake time';

  @override
  String get scheduleSleep => 'Sleep time';

  @override
  String get scheduleWeekendToggle => 'Different on weekends';

  @override
  String get scheduleWeekendWake => 'Weekend wake time';

  @override
  String get scheduleWeekendSleep => 'Weekend sleep time';

  @override
  String get scheduleInvalid =>
      'Those times don\'t make a valid day. Try at least six hours awake.';

  @override
  String get scheduleSaved => 'Schedule updated';

  @override
  String get scheduleEnvironment => 'Hydration environment';

  @override
  String get scheduleEnvironmentNormal => 'Normal';

  @override
  String get scheduleEnvironmentHot => 'Hot or very active';

  @override
  String get scheduleEnvironmentBody =>
      'Hot days make HYDRA check in a little more often. Your target stays yours.';

  @override
  String get remindersTitle => 'Notifications';

  @override
  String get remindersToggle => 'Reminders';

  @override
  String get remindersToggleBody => 'Adaptive check-ins during your day.';

  @override
  String get remindersPermissionOff =>
      'Notifications are off for HYDRA in system settings.';

  @override
  String get remindersPermissionAllow => 'Allow notifications';

  @override
  String get remindersStyle => 'Reminder style';

  @override
  String get remindersTone => 'Wording';

  @override
  String get toneAuto => 'Adaptive';

  @override
  String get toneAutoBody => 'Wording follows how your day is going.';

  @override
  String get toneGentle => 'Gentle';

  @override
  String get toneNeutral => 'Neutral';

  @override
  String get toneEncouraging => 'Encouraging';

  @override
  String get toneProgress => 'Progress';

  @override
  String get remindersQuietHours => 'Smart quiet hours';

  @override
  String get remindersQuietBody =>
      'HYDRA notices times you usually skip reminders and can stay quiet then.';

  @override
  String remindersQuietSuggestion(String start, String end) {
    return 'You usually skip reminders around $start to $end. Stay quiet then?';
  }

  @override
  String get remindersQuietAccept => 'Add quiet time';

  @override
  String get remindersQuietNone =>
      'No pattern yet. HYDRA learns from a few days of responses.';

  @override
  String get remindersHelp => 'Notifications not arriving?';

  @override
  String get remindersFatigueNote =>
      'HYDRA slows down automatically when reminders aren\'t helping.';

  @override
  String get notifHelpTitle => 'Notification check-up';

  @override
  String get notifHelpBody =>
      'HYDRA checks each thing that has to be right for reminders to arrive.';

  @override
  String get notifHelpPermission => 'Notifications allowed';

  @override
  String get notifHelpRemindersOn => 'Reminders turned on';

  @override
  String get notifHelpNotPaused => 'Not paused';

  @override
  String get notifHelpScheduled => 'Next reminder scheduled';

  @override
  String notifHelpNextAt(String time) {
    return 'Next reminder: $time';
  }

  @override
  String get notifHelpBattery =>
      'Your phone\'s battery saver may delay reminders. If they arrive late, exclude HYDRA from battery optimization.';

  @override
  String get notifHelpFocus =>
      'Focus or Do Not Disturb modes can silence reminders on purpose.';

  @override
  String get notifHelpTest => 'Send a test notification';

  @override
  String get notifHelpTestSent => 'Test sent';

  @override
  String get notifHelpFix => 'Fix';

  @override
  String get notifHelpOk => 'OK';

  @override
  String get notifHelpNeedsAttention => 'Needs attention';

  @override
  String get notifTestBody => 'This is a test reminder from HYDRA.';

  @override
  String get vesselsTitle => 'Vessels';

  @override
  String get vesselsBody => 'Log your own bottle or glass in one tap.';

  @override
  String get vesselsEmptyTitle => 'No vessels yet';

  @override
  String get vesselsEmptyBody =>
      'Add the glass or bottle you actually use, and logging becomes a single tap.';

  @override
  String get vesselsAdd => 'Add vessel';

  @override
  String get vesselName => 'Name';

  @override
  String vesselAmount(String unit) {
    return 'Volume ($unit)';
  }

  @override
  String get vesselIcon => 'Icon';

  @override
  String get vesselFavorite => 'Show on home';

  @override
  String vesselLimit(String count) {
    return 'Free includes $count vessels. HYDRA Pro has no limit.';
  }

  @override
  String get vesselLimitWatch => 'Watch a short ad for one extra slot today';

  @override
  String get vesselDeleteTitle => 'Delete this vessel?';

  @override
  String get vesselDeleteBody => 'Past entries keep their amounts.';

  @override
  String get vesselSaved => 'Vessel saved';

  @override
  String get vesselDefaultGlass => 'Glass';

  @override
  String get vesselDefaultDesk => 'Desk bottle';

  @override
  String get vesselDefaultGym => 'Gym bottle';

  @override
  String get routinesTitle => 'Routines';

  @override
  String get routinesBody =>
      'A routine sets wake, sleep and quiet times for certain days. Switch with one tap.';

  @override
  String get routinesEmptyTitle => 'No routines yet';

  @override
  String get routinesEmptyBody =>
      'Your wake and sleep times apply every day. Add a routine for work days, study, workouts or travel.';

  @override
  String get routinesAdd => 'Add routine';

  @override
  String get routinesActive => 'In use';

  @override
  String get routinesUse => 'Use now';

  @override
  String get routinesUseAuto => 'Back to automatic';

  @override
  String get routinesDays => 'Days';

  @override
  String get routinesName => 'Name';

  @override
  String get routinesKind => 'Type';

  @override
  String get routinesQuiet => 'Quiet times';

  @override
  String get routinesQuietAdd => 'Add quiet time';

  @override
  String get routinesWorkout => 'Workout window';

  @override
  String get routinesWorkoutBody =>
      'Reminders pause during this time and resume right after.';

  @override
  String get routinesFrom => 'From';

  @override
  String get routinesTo => 'To';

  @override
  String routinesLimit(String count) {
    return 'Free includes $count routines. HYDRA Pro has no limit.';
  }

  @override
  String get routinesProKind =>
      'Workout and Travel routines are part of HYDRA Pro.';

  @override
  String get routinesDeleteTitle => 'Delete this routine?';

  @override
  String get routinesDeleteBody => 'Your history isn\'t affected.';

  @override
  String get routinesSaved => 'Routine saved';

  @override
  String get routinesInvalid => 'Check the wake and sleep times.';

  @override
  String get routinesNameInvalid => 'Give the routine a short name.';

  @override
  String get healthTitle => 'Health sync';

  @override
  String get healthIntro =>
      'Sync water intake with your health app. HYDRA reads and writes water only: nothing else.';

  @override
  String get healthProBody => 'Health sync is part of HYDRA Pro.';

  @override
  String get healthProCta => 'See HYDRA Pro';

  @override
  String get healthEnable => 'Turn on Health sync';

  @override
  String get healthDisable => 'Turn off';

  @override
  String get healthDirection => 'What to sync';

  @override
  String get healthDirectionTwoWay => 'Both ways';

  @override
  String get healthDirectionImport => 'Import from Health';

  @override
  String get healthDirectionExport => 'Send HYDRA to Health';

  @override
  String get healthSyncNow => 'Sync now';

  @override
  String healthLastSync(String time) {
    return 'Last synced $time';
  }

  @override
  String get healthNever => 'Not synced yet';

  @override
  String healthSynced(String imported, String exported) {
    return 'Synced: $imported imported, $exported sent';
  }

  @override
  String get healthAvailabilityMissing =>
      'Health Connect isn\'t installed on this device.';

  @override
  String get healthAvailabilityUnsupported =>
      'Health sync isn\'t available on this device.';

  @override
  String get healthInstall => 'Install Health Connect';

  @override
  String get healthPermissionDenied =>
      'HYDRA doesn\'t have permission to read or write water intake.';

  @override
  String get healthManagePermissions => 'Manage health permissions';

  @override
  String get healthFailedTitle => 'HYDRA couldn\'t sync right now.';

  @override
  String get healthFailedBody =>
      'Your drinks are safe in HYDRA and tracking continues as normal.';

  @override
  String get healthContinueWithout => 'Continue without sync';

  @override
  String get healthDeleteNote =>
      'Deleting HYDRA data doesn\'t delete records already in your health app. Remove those there.';

  @override
  String get healthDuplicateNote =>
      'HYDRA matches drinks it already knows about, so nothing is counted twice.';

  @override
  String get privacyTitle => 'Privacy Center';

  @override
  String get privacyIntro =>
      'Your hydration history stays on this device. No account. Health data is never used to choose ads.';

  @override
  String get privacyYourData => 'Your data';

  @override
  String get privacyHydration => 'Hydration history';

  @override
  String get privacyHydrationValue => 'On this device';

  @override
  String get privacyHealth => 'Health sync';

  @override
  String get privacyAnalytics => 'Anonymous usage statistics';

  @override
  String get privacyAnalyticsBody =>
      'Product events like \'onboarding completed\'. Never amounts or history.';

  @override
  String get privacyAds => 'Advertising';

  @override
  String get privacyAdsValue => 'Contextual only';

  @override
  String get privacyAdsBody => 'Ads never use your hydration or health data.';

  @override
  String get privacyPro => 'Ad-free with HYDRA Pro';

  @override
  String get privacyNotifications => 'Notifications';

  @override
  String get privacyStorage => 'Local storage';

  @override
  String get privacyStorageValue => 'Private app storage';

  @override
  String get privacyWidgetHide => 'Hide amounts in widgets';

  @override
  String get privacyWidgetHideBody => 'Widgets show only the percentage.';

  @override
  String get privacyExport => 'Export my data';

  @override
  String get privacyExportBody =>
      'A CSV or JSON file with every entry, vessel and routine.';

  @override
  String get privacyExportCsv => 'Export as CSV';

  @override
  String get privacyExportJson => 'Export as JSON';

  @override
  String get privacyExportFailed => 'Couldn\'t create the export.';

  @override
  String get privacyDelete => 'Delete my data';

  @override
  String get privacyDeleteBody => 'Removes everything from this device.';

  @override
  String get privacyDeleteConfirmTitle => 'Delete all HYDRA data?';

  @override
  String get privacyDeleteConfirmBody =>
      'This permanently deletes:\n• hydration history\n• vessels\n• routines\n• preferences\n• local insights\n\nHealth records in your health app are not deleted. Your subscription is separate and isn\'t cancelled.';

  @override
  String get privacyDeleteConfirmAction => 'Delete everything';

  @override
  String get privacyDeleted => 'Your data was deleted.';

  @override
  String get privacyChoices => 'Manage privacy choices';

  @override
  String get privacyHealthPerms => 'Manage health permissions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyTerms => 'Terms';

  @override
  String get privacyOpenFailed => 'Couldn\'t open the link.';

  @override
  String get privacyExportContents =>
      'Exports contain: id, date, time (UTC), timezone, volume in ml, vessel and source.';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceMode => 'Mode';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceThemes => 'Themes';

  @override
  String get appearanceOcean => 'Ocean';

  @override
  String get appearanceAurora => 'Aurora';

  @override
  String get appearanceGraphite => 'Graphite';

  @override
  String get appearanceThemeProNote =>
      'Aurora and Graphite are part of HYDRA Pro.';

  @override
  String get appearanceWatchTheme =>
      'Watch a short ad to try Aurora for 24 hours';

  @override
  String get appearanceThemeUntil => 'Aurora is on until tomorrow.';

  @override
  String get appearanceReduceMotion =>
      'HYDRA follows your system\'s reduce-motion setting.';

  @override
  String get paywallTitle => 'HYDRA Pro';

  @override
  String get paywallHeadline =>
      'Your hydration system, optimized around your life.';

  @override
  String get paywallBenefitNoAds => 'No ads';

  @override
  String get paywallBenefitScheduler => 'Advanced adaptive scheduling';

  @override
  String get paywallBenefitHealth => 'Health sync';

  @override
  String get paywallBenefitInsights => 'Advanced insights';

  @override
  String get paywallBenefitVessels => 'Unlimited vessels';

  @override
  String get paywallBenefitRoutines => 'Advanced routines';

  @override
  String get paywallBenefitTravel => 'Travel mode';

  @override
  String get paywallBenefitWidgets => 'Advanced widgets';

  @override
  String get paywallBenefitExport => 'Export';

  @override
  String get paywallBenefitThemes => 'Premium themes';

  @override
  String get paywallFreeNote =>
      'Logging, reminders, progress and privacy controls stay free.';

  @override
  String get paywallAnnual => 'Annual';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallLifetime => 'Lifetime';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String paywallPerMonth(String price) {
    return 'about $price per month';
  }

  @override
  String paywallTrial(String days, String price) {
    return '$days-day free trial, then $price';
  }

  @override
  String get paywallContinue => 'Continue';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String get paywallTerms =>
      'Subscriptions renew automatically unless cancelled at least 24 hours before the period ends. Manage or cancel any time in your store account settings.';

  @override
  String get paywallUnavailableTitle => 'Purchases aren\'t available right now';

  @override
  String get paywallUnavailableBody =>
      'HYDRA couldn\'t reach the store. Everything free keeps working. Please try again later.';

  @override
  String get paywallPurchased => 'Welcome to HYDRA Pro';

  @override
  String get paywallRestored => 'Purchases restored';

  @override
  String get paywallRestoreNone => 'No earlier purchase was found.';

  @override
  String get paywallCancelled => 'No charge was made.';

  @override
  String get paywallPending => 'Your purchase is pending approval.';

  @override
  String get paywallFailed =>
      'The purchase didn\'t go through. You haven\'t been charged.';

  @override
  String get paywallActiveTitle => 'You have HYDRA Pro';

  @override
  String get paywallBillingIssue =>
      'There\'s a problem with your payment method. Update it in your store account to keep Pro.';

  @override
  String get supportTitle => 'Help and support';

  @override
  String get supportFaqNotifTitle => 'Reminders aren\'t arriving';

  @override
  String get supportFaqNotifBody =>
      'Open the notification check-up to see what to fix.';

  @override
  String get supportFaqHealthTitle => 'Health sync problems';

  @override
  String get supportFaqHealthBody =>
      'Open Health sync to retry or continue without it.';

  @override
  String get supportFaqRestoreTitle => 'Restore purchases';

  @override
  String get supportFaqRestoreBody =>
      'Use Restore on the HYDRA Pro screen. No account is needed.';

  @override
  String get supportContact => 'Contact support';

  @override
  String get supportCopyDiagnostics => 'Copy diagnostics';

  @override
  String get supportDiagnosticsCopied =>
      'Diagnostics copied. They contain no hydration history.';

  @override
  String get supportAbout => 'About HYDRA';

  @override
  String supportVersion(String version) {
    return 'Version $version';
  }

  @override
  String get supportFeedbackTitle => 'How is HYDRA doing?';

  @override
  String get supportFeedbackLove => 'Love it';

  @override
  String get supportFeedbackGood => 'Good';

  @override
  String get supportFeedbackOkay => 'Okay';

  @override
  String get supportFeedbackNot => 'Not useful';

  @override
  String get supportFeedbackThanks => 'Thank you.';

  @override
  String get supportFeedbackFix => 'What should we fix?';

  @override
  String get supportLicenses => 'Open-source licenses';

  @override
  String get startupErrorTitle => 'HYDRA couldn\'t start';

  @override
  String get startupErrorBody =>
      'Your data is safe on this device. Please try again.';

  @override
  String get routeNotFound => 'That page doesn\'t exist.';

  @override
  String get commonOpenSettings => 'Open settings';

  @override
  String get paceFirstDay => 'Ready when you are';

  @override
  String get paceFirstDayBody =>
      'Your first day. Log a drink and HYDRA starts learning your rhythm.';
}
