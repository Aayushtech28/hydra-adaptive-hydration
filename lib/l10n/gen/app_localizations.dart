import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'HYDRA'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Hydration that adapts to your day.'**
  String get tagline;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Hydration check-ins'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Gentle, adaptive reminders to keep you on pace.'**
  String get notifChannelDescription;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'HYDRA'**
  String get notifTitle;

  /// No description provided for @notifFirstOfDay1.
  ///
  /// In en, this message translates to:
  /// **'Good morning. Ready for a first sip?'**
  String get notifFirstOfDay1;

  /// No description provided for @notifFirstOfDay2.
  ///
  /// In en, this message translates to:
  /// **'A glass to start the day?'**
  String get notifFirstOfDay2;

  /// No description provided for @notifGentle1.
  ///
  /// In en, this message translates to:
  /// **'A small sip is enough.'**
  String get notifGentle1;

  /// No description provided for @notifGentle2.
  ///
  /// In en, this message translates to:
  /// **'No rush. A little water when you can.'**
  String get notifGentle2;

  /// No description provided for @notifNeutral1.
  ///
  /// In en, this message translates to:
  /// **'Ready for your next drink?'**
  String get notifNeutral1;

  /// No description provided for @notifNeutral2.
  ///
  /// In en, this message translates to:
  /// **'Time for your next hydration check.'**
  String get notifNeutral2;

  /// No description provided for @notifEncouraging1.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing well. Keep your rhythm going.'**
  String get notifEncouraging1;

  /// No description provided for @notifEncouraging2.
  ///
  /// In en, this message translates to:
  /// **'Your rhythm is looking good.'**
  String get notifEncouraging2;

  /// No description provided for @notifProgress1.
  ///
  /// In en, this message translates to:
  /// **'You\'re {percent}% through today\'s plan.'**
  String notifProgress1(int percent);

  /// No description provided for @notifProgress2.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of today\'s plan so far. Nice pace.'**
  String notifProgress2(int percent);

  /// No description provided for @notifOnPace1.
  ///
  /// In en, this message translates to:
  /// **'You\'re still on pace.'**
  String get notifOnPace1;

  /// No description provided for @notifOnPace2.
  ///
  /// In en, this message translates to:
  /// **'Right on rhythm. A sip keeps it that way.'**
  String get notifOnPace2;

  /// No description provided for @notifBehind1.
  ///
  /// In en, this message translates to:
  /// **'A small drink will bring you back toward your plan.'**
  String get notifBehind1;

  /// No description provided for @notifBehind2.
  ///
  /// In en, this message translates to:
  /// **'A little behind pace. A few sips will help.'**
  String get notifBehind2;

  /// No description provided for @notifRecovery1.
  ///
  /// In en, this message translates to:
  /// **'Missed the last one? No problem. We\'ve adjusted the next check-in.'**
  String get notifRecovery1;

  /// No description provided for @notifRecovery2.
  ///
  /// In en, this message translates to:
  /// **'We\'ve spread your plan across the rest of the day. One sip is a good start.'**
  String get notifRecovery2;

  /// No description provided for @notifClosing1.
  ///
  /// In en, this message translates to:
  /// **'Your day is winding down. No need to catch up.'**
  String get notifClosing1;

  /// No description provided for @notifClosing2.
  ///
  /// In en, this message translates to:
  /// **'Nothing to force tonight. Tomorrow we\'ll start earlier.'**
  String get notifClosing2;

  /// No description provided for @notifAfterWorkout1.
  ///
  /// In en, this message translates to:
  /// **'Nice work. A drink after your workout?'**
  String get notifAfterWorkout1;

  /// No description provided for @notifAfterWorkout2.
  ///
  /// In en, this message translates to:
  /// **'Workout done. Time for some water?'**
  String get notifAfterWorkout2;

  /// No description provided for @notifActionAdd.
  ///
  /// In en, this message translates to:
  /// **'+{amount}'**
  String notifActionAdd(String amount);

  /// No description provided for @notifActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 30 min'**
  String get notifActionSnooze;

  /// No description provided for @whyFirstOfDay.
  ///
  /// In en, this message translates to:
  /// **'This is your first check-in of the day, shortly after you wake up.'**
  String get whyFirstOfDay;

  /// No description provided for @whyOnTrackScheduled.
  ///
  /// In en, this message translates to:
  /// **'You\'re on track, so we\'re keeping the usual spacing.'**
  String get whyOnTrackScheduled;

  /// No description provided for @whyAheadStayQuiet.
  ///
  /// In en, this message translates to:
  /// **'You\'re ahead of your plan, so we\'ll stay quiet for longer.'**
  String get whyAheadStayQuiet;

  /// No description provided for @whySlightlyBehindEarlier.
  ///
  /// In en, this message translates to:
  /// **'You\'re slightly behind your plan, so we moved this reminder earlier.'**
  String get whySlightlyBehindEarlier;

  /// No description provided for @whySignificantlyBehindSpread.
  ///
  /// In en, this message translates to:
  /// **'You\'re behind your plan. We\'re spreading what\'s left across your remaining time instead of asking for a big catch-up.'**
  String get whySignificantlyBehindSpread;

  /// No description provided for @whySnoozedUntil.
  ///
  /// In en, this message translates to:
  /// **'You snoozed, so we\'ll check in again then.'**
  String get whySnoozedUntil;

  /// No description provided for @whyQuietHoursExit.
  ///
  /// In en, this message translates to:
  /// **'This was moved to the end of your quiet time.'**
  String get whyQuietHoursExit;

  /// No description provided for @whyWorkoutEnded.
  ///
  /// In en, this message translates to:
  /// **'We waited until your workout window ended.'**
  String get whyWorkoutEnded;

  /// No description provided for @whyFatigueQuiet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t needed the last few reminders, so we\'re quiet until tomorrow.'**
  String get whyFatigueQuiet;

  /// No description provided for @whyFatigueSlowed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been responding to fewer reminders, so we\'re spacing them out more.'**
  String get whyFatigueSlowed;

  /// No description provided for @whyDayClosingTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Your day is almost over. We won\'t force a catch-up. Tomorrow we\'ll start earlier.'**
  String get whyDayClosingTomorrow;

  /// No description provided for @whyGoalReachedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s target. Next check-in is tomorrow morning.'**
  String get whyGoalReachedTomorrow;

  /// No description provided for @whyPausedUntilLog.
  ///
  /// In en, this message translates to:
  /// **'Reminders are paused until you log a drink.'**
  String get whyPausedUntilLog;

  /// No description provided for @whyPausedUntilTime.
  ///
  /// In en, this message translates to:
  /// **'Reminders are paused until the time you chose.'**
  String get whyPausedUntilTime;

  /// No description provided for @whyRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are turned off. HYDRA still tracks your pace.'**
  String get whyRemindersOff;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// No description provided for @commonOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get commonOn;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get commonLearnMore;

  /// No description provided for @commonProBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get commonProBadge;

  /// No description provided for @commonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this right now.'**
  String get commonLoadFailed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration that adapts to your day.'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA learns your rhythm and quietly keeps you on pace. The smarter it gets, the quieter it gets.'**
  String get onbWelcomeBody;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onbWakeTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you usually start your day?'**
  String get onbWakeTitle;

  /// No description provided for @onbWakeBody.
  ///
  /// In en, this message translates to:
  /// **'Your first check-in will come shortly after this.'**
  String get onbWakeBody;

  /// No description provided for @onbSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'When does your day usually end?'**
  String get onbSleepTitle;

  /// No description provided for @onbSleepBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA stays quiet from your last check-in until you wake.'**
  String get onbSleepBody;

  /// No description provided for @onbTimeTooShort.
  ///
  /// In en, this message translates to:
  /// **'That\'s a very short day. Try at least six hours between waking and sleeping.'**
  String get onbTimeTooShort;

  /// No description provided for @onbTimeWakeEarly.
  ///
  /// In en, this message translates to:
  /// **'Wake times before 4:00 are not supported. Pick a later time.'**
  String get onbTimeWakeEarly;

  /// No description provided for @onbTimeOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight days can end by 4:00 at the latest.'**
  String get onbTimeOvernight;

  /// No description provided for @onbStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'How much prompting do you prefer?'**
  String get onbStyleTitle;

  /// No description provided for @onbStyleBody.
  ///
  /// In en, this message translates to:
  /// **'You can change this any time, and HYDRA adapts as it learns.'**
  String get onbStyleBody;

  /// No description provided for @styleGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get styleGentle;

  /// No description provided for @styleGentleBody.
  ///
  /// In en, this message translates to:
  /// **'Fewer, softer reminders and a quieter day.'**
  String get styleGentleBody;

  /// No description provided for @styleBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get styleBalanced;

  /// No description provided for @styleBalancedBody.
  ///
  /// In en, this message translates to:
  /// **'A steady rhythm that adapts to your pace.'**
  String get styleBalancedBody;

  /// No description provided for @styleFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get styleFocus;

  /// No description provided for @styleFocusBody.
  ///
  /// In en, this message translates to:
  /// **'More persistent check-ins for people who often forget.'**
  String get styleFocusBody;

  /// No description provided for @onbUnitTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your measurement.'**
  String get onbUnitTitle;

  /// No description provided for @onbUnitBody.
  ///
  /// In en, this message translates to:
  /// **'Everything is stored in millilitres, so you can switch whenever you like.'**
  String get onbUnitBody;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'Millilitres (ml)'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'Litres (L)'**
  String get unitL;

  /// No description provided for @unitFlOz.
  ///
  /// In en, this message translates to:
  /// **'US fluid ounces (fl oz)'**
  String get unitFlOz;

  /// No description provided for @unitCups.
  ///
  /// In en, this message translates to:
  /// **'US cups'**
  String get unitCups;

  /// No description provided for @onbTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your daily target.'**
  String get onbTargetTitle;

  /// No description provided for @onbTargetBody.
  ///
  /// In en, this message translates to:
  /// **'This is the amount you choose. It isn\'t medical advice.'**
  String get onbTargetBody;

  /// No description provided for @onbStarterTarget.
  ///
  /// In en, this message translates to:
  /// **'Starter target'**
  String get onbStarterTarget;

  /// No description provided for @onbStarterTargetBody.
  ///
  /// In en, this message translates to:
  /// **'A general planning preset. Adjust it to whatever suits you.'**
  String get onbStarterTargetBody;

  /// No description provided for @onbCustomTarget.
  ///
  /// In en, this message translates to:
  /// **'Custom target'**
  String get onbCustomTarget;

  /// No description provided for @onbYourTarget.
  ///
  /// In en, this message translates to:
  /// **'Your target'**
  String get onbYourTarget;

  /// No description provided for @onbYourTargetBody.
  ///
  /// In en, this message translates to:
  /// **'How much you want to drink each day. You decide this.'**
  String get onbYourTargetBody;

  /// No description provided for @onbHydraSchedule.
  ///
  /// In en, this message translates to:
  /// **'HYDRA schedule'**
  String get onbHydraSchedule;

  /// No description provided for @onbHydraScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'When to check in during your day. HYDRA decides this and adapts it.'**
  String get onbHydraScheduleBody;

  /// No description provided for @onbTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a target between {min} and {max}.'**
  String onbTargetInvalid(String min, String max);

  /// No description provided for @onbReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your hydration rhythm is ready.'**
  String get onbReadyTitle;

  /// No description provided for @onbReadyNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onbReadyNotifTitle;

  /// No description provided for @onbReadyNotifBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA can remind you at the right moments, and you can log right from the notification.'**
  String get onbReadyNotifBody;

  /// No description provided for @onbReadyPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get onbReadyPrivacyTitle;

  /// No description provided for @onbReadyPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your hydration history stays on this device. No account needed.'**
  String get onbReadyPrivacyBody;

  /// No description provided for @onbReadyHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional Health sync'**
  String get onbReadyHealthTitle;

  /// No description provided for @onbReadyHealthBody.
  ///
  /// In en, this message translates to:
  /// **'After you\'ve logged a few drinks, you can choose to sync with your health app.'**
  String get onbReadyHealthBody;

  /// No description provided for @onbAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onbAllowNotifications;

  /// No description provided for @onbStartWithout.
  ///
  /// In en, this message translates to:
  /// **'Start without reminders'**
  String get onbStartWithout;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Open HYDRA'**
  String get onbStart;

  /// No description provided for @onbStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStepOf(String current, String total);

  /// No description provided for @dashGreetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashGreetMorning;

  /// No description provided for @dashGreetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get dashGreetAfternoon;

  /// No description provided for @dashGreetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get dashGreetEvening;

  /// No description provided for @dashGreetNight.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get dashGreetNight;

  /// No description provided for @dashToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashToday;

  /// No description provided for @dashConsumedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{consumed} / {target}'**
  String dashConsumedOfTarget(String consumed, String target);

  /// No description provided for @dashProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent of today\'s target. {consumed} of {target}.'**
  String dashProgressSemantics(String percent, String consumed, String target);

  /// No description provided for @paceAhead.
  ///
  /// In en, this message translates to:
  /// **'Ahead of pace'**
  String get paceAhead;

  /// No description provided for @paceOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On pace'**
  String get paceOnTrack;

  /// No description provided for @paceSlightlyBehind.
  ///
  /// In en, this message translates to:
  /// **'Adjusting'**
  String get paceSlightlyBehind;

  /// No description provided for @paceNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get paceNeedsAttention;

  /// No description provided for @paceDayClosing.
  ///
  /// In en, this message translates to:
  /// **'Day winding down'**
  String get paceDayClosing;

  /// No description provided for @paceGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get paceGoalReached;

  /// No description provided for @paceBeforeWake.
  ///
  /// In en, this message translates to:
  /// **'Your day starts soon'**
  String get paceBeforeWake;

  /// No description provided for @paceFinishBy.
  ///
  /// In en, this message translates to:
  /// **'On pace to finish by {time}'**
  String paceFinishBy(String time);

  /// No description provided for @paceFinishLater.
  ///
  /// In en, this message translates to:
  /// **'At this pace you\'d finish after your planned window. We\'ll adjust gently.'**
  String get paceFinishLater;

  /// No description provided for @paceGoalReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s target. Nicely done.'**
  String get paceGoalReachedBody;

  /// No description provided for @paceClosingBody.
  ///
  /// In en, this message translates to:
  /// **'No need to force a catch-up tonight. Tomorrow starts fresh.'**
  String get paceClosingBody;

  /// No description provided for @paceSpreadBody.
  ///
  /// In en, this message translates to:
  /// **'About {amount} per check-in keeps you comfortable.'**
  String paceSpreadBody(String amount);

  /// No description provided for @nextReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Next reminder'**
  String get nextReminderTitle;

  /// No description provided for @nextReminderAt.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String nextReminderAt(String time);

  /// No description provided for @nextReminderTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String nextReminderTomorrowAt(String time);

  /// No description provided for @nextReminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder scheduled'**
  String get nextReminderNone;

  /// No description provided for @nextReminderPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get nextReminderPaused;

  /// No description provided for @nextReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get nextReminderOff;

  /// No description provided for @nextReminderWhy.
  ///
  /// In en, this message translates to:
  /// **'Why now?'**
  String get nextReminderWhy;

  /// No description provided for @nextReminderLastDrink.
  ///
  /// In en, this message translates to:
  /// **'Last drink {minutes} min ago.'**
  String nextReminderLastDrink(String minutes);

  /// No description provided for @nextReminderPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get nextReminderPause;

  /// No description provided for @nextReminderResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get nextReminderResume;

  /// No description provided for @pause15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get pause15;

  /// No description provided for @pause30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get pause30;

  /// No description provided for @pause60.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get pause60;

  /// No description provided for @pauseUntil3pm.
  ///
  /// In en, this message translates to:
  /// **'Until 3 PM'**
  String get pauseUntil3pm;

  /// No description provided for @pauseUntilLog.
  ///
  /// In en, this message translates to:
  /// **'Until I log again'**
  String get pauseUntilLog;

  /// No description provided for @pauseWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Picking up where you left off.'**
  String get pauseWelcomeBack;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAddTitle;

  /// No description provided for @quickAddCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get quickAddCustom;

  /// No description provided for @quickAddVessels.
  ///
  /// In en, this message translates to:
  /// **'My vessels'**
  String get quickAddVessels;

  /// No description provided for @logged.
  ///
  /// In en, this message translates to:
  /// **'Logged {amount}'**
  String logged(String amount);

  /// No description provided for @loggedUndone.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get loggedUndone;

  /// No description provided for @logFailed.
  ///
  /// In en, this message translates to:
  /// **'That amount isn\'t valid.'**
  String get logFailed;

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timelineTitle;

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'First day starts here.'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an amount above when you drink. HYDRA will start learning your rhythm from your first log.'**
  String get timelineEmptyBody;

  /// No description provided for @timelineEntry.
  ///
  /// In en, this message translates to:
  /// **'{time} · {amount}'**
  String timelineEntry(String time, String amount);

  /// No description provided for @entryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get entryEdit;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry removed'**
  String get entryDeleted;

  /// No description provided for @entryAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount ({unit})'**
  String entryAmount(String unit);

  /// No description provided for @entryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get entryTime;

  /// No description provided for @entryDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get entryDate;

  /// No description provided for @entryYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get entryYesterday;

  /// No description provided for @entryNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get entryNow;

  /// No description provided for @logSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add hydration'**
  String get logSheetTitle;

  /// No description provided for @logSheetLog.
  ///
  /// In en, this message translates to:
  /// **'Log now'**
  String get logSheetLog;

  /// No description provided for @logSheetRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get logSheetRecent;

  /// No description provided for @logSheetLogAt.
  ///
  /// In en, this message translates to:
  /// **'Log at'**
  String get logSheetLogAt;

  /// No description provided for @logSheetFuture.
  ///
  /// In en, this message translates to:
  /// **'That time is in the future.'**
  String get logSheetFuture;

  /// No description provided for @insightCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s insight'**
  String get insightCardTitle;

  /// No description provided for @insightNoData.
  ///
  /// In en, this message translates to:
  /// **'Log your first drink and HYDRA will begin learning your rhythm.'**
  String get insightNoData;

  /// No description provided for @insightFirstDay.
  ///
  /// In en, this message translates to:
  /// **'You\'ve started your first day. Patterns appear after about a week.'**
  String get insightFirstDay;

  /// No description provided for @insightEarlyDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days in. A little more history and HYDRA can spot your patterns.'**
  String insightEarlyDays(String days);

  /// No description provided for @insightMorningStrength.
  ///
  /// In en, this message translates to:
  /// **'Your mornings are consistently strong ({percent}% of your morning plan).'**
  String insightMorningStrength(String percent);

  /// No description provided for @insightAfternoonDrift.
  ///
  /// In en, this message translates to:
  /// **'Your afternoon is where your rhythm usually drifts ({percent}% of the plan).'**
  String insightAfternoonDrift(String percent);

  /// No description provided for @insightEveningDrift.
  ///
  /// In en, this message translates to:
  /// **'Evenings are where you tend to fall behind ({percent}% of the plan).'**
  String insightEveningDrift(String percent);

  /// No description provided for @insightEarlyFirstDrink.
  ///
  /// In en, this message translates to:
  /// **'Your strongest days start with a drink within {minutes} minutes of waking.'**
  String insightEarlyFirstDrink(String minutes);

  /// No description provided for @insightWeekdayStable.
  ///
  /// In en, this message translates to:
  /// **'Your routine holds steady on weekdays and weekends.'**
  String get insightWeekdayStable;

  /// No description provided for @insightWeekendVariance.
  ///
  /// In en, this message translates to:
  /// **'Weekdays average {weekday}% of plan versus {weekend}% on weekends.'**
  String insightWeekendVariance(String weekday, String weekend);

  /// No description provided for @insightReminderResponse.
  ///
  /// In en, this message translates to:
  /// **'You logged after {percent}% of your last {count} reminders.'**
  String insightReminderResponse(String percent, String count);

  /// No description provided for @insightRoutineImprovement.
  ///
  /// In en, this message translates to:
  /// **'Your routine improved by {points} points since last week.'**
  String insightRoutineImprovement(String points);

  /// No description provided for @insightRecovery.
  ///
  /// In en, this message translates to:
  /// **'Yesterday didn\'t erase your progress. Your rhythm is still building.'**
  String get insightRecovery;

  /// No description provided for @tzChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your timezone changed'**
  String get tzChangedTitle;

  /// No description provided for @tzChangedBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA moved your reminders to {zone} local time. Your history stays exactly as it was.'**
  String tzChangedBody(String zone);

  /// No description provided for @tzChangedAdjust.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tzChangedAdjust;

  /// No description provided for @fatigueTitle.
  ///
  /// In en, this message translates to:
  /// **'Want fewer reminders?'**
  String get fatigueTitle;

  /// No description provided for @fatigueBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t needed many recent reminders. We can make HYDRA quieter.'**
  String get fatigueBody;

  /// No description provided for @fatigueAccept.
  ///
  /// In en, this message translates to:
  /// **'Make it quieter'**
  String get fatigueAccept;

  /// No description provided for @fatigueDecline.
  ///
  /// In en, this message translates to:
  /// **'Keep as is'**
  String get fatigueDecline;

  /// No description provided for @permNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get permNudgeTitle;

  /// No description provided for @permNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for HYDRA. Tracking still works; turn them on if you\'d like reminders.'**
  String get permNudgeBody;

  /// No description provided for @permNudgeAction.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get permNudgeAction;

  /// No description provided for @healthNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with your health app?'**
  String get healthNudgeTitle;

  /// No description provided for @healthNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. HYDRA only reads and writes water intake, and works fine without it.'**
  String get healthNudgeBody;

  /// No description provided for @healthNudgeAction.
  ///
  /// In en, this message translates to:
  /// **'Set up Health sync'**
  String get healthNudgeAction;

  /// No description provided for @disclaimerShort.
  ///
  /// In en, this message translates to:
  /// **'HYDRA is a wellness and habit tool, not medical advice. If you have a medical condition or a clinician-directed fluid limit, follow your healthcare professional\'s guidance.'**
  String get disclaimerShort;

  /// No description provided for @a11yLogAmount.
  ///
  /// In en, this message translates to:
  /// **'Log {amount}'**
  String a11yLogAmount(String amount);

  /// No description provided for @a11yVesselLog.
  ///
  /// In en, this message translates to:
  /// **'Log {name}, {amount}'**
  String a11yVesselLog(String name, String amount);

  /// No description provided for @a11yDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get a11yDeleteEntry;

  /// No description provided for @a11yRemindersMenu.
  ///
  /// In en, this message translates to:
  /// **'Reminder options'**
  String get a11yRemindersMenu;

  /// No description provided for @dashAllEntries.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get dashAllEntries;

  /// No description provided for @dashWhyHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get dashWhyHide;

  /// No description provided for @dashLastLogged.
  ///
  /// In en, this message translates to:
  /// **'Last logged {time}'**
  String dashLastLogged(String time);

  /// No description provided for @dashLogFailedOffline.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that. Please try again.'**
  String get dashLogFailedOffline;

  /// No description provided for @logSheetAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get logSheetAmountHint;

  /// No description provided for @logSheetVesselsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a bottle or glass in You → Vessels for one-tap logging.'**
  String get logSheetVesselsEmpty;

  /// No description provided for @logSheetEditing.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get logSheetEditing;

  /// No description provided for @logSheetSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get logSheetSaved;

  /// No description provided for @entryConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this entry?'**
  String get entryConfirmDeleteTitle;

  /// No description provided for @entryConfirmDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your total and pace will update.'**
  String get entryConfirmDeleteBody;

  /// No description provided for @proRequiredHistoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Editing past days is part of HYDRA Pro.'**
  String get proRequiredHistoryEdit;

  /// No description provided for @pace3Seconds.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace3Seconds;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get historyDay;

  /// No description provided for @historyWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get historyWeek;

  /// No description provided for @historyMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get historyMonth;

  /// No description provided for @historyCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get historyCalendar;

  /// No description provided for @historyDayTotal.
  ///
  /// In en, this message translates to:
  /// **'{amount} of {target}'**
  String historyDayTotal(String amount, String target);

  /// No description provided for @historyPrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get historyPrevDay;

  /// No description provided for @historyNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get historyNextDay;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyNoEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this day'**
  String get historyNoEntriesTitle;

  /// No description provided for @historyNoEntriesBody.
  ///
  /// In en, this message translates to:
  /// **'Entries you log appear here. You can add one for this day with Custom.'**
  String get historyNoEntriesBody;

  /// No description provided for @historyFutureTitle.
  ///
  /// In en, this message translates to:
  /// **'This day hasn\'t happened yet'**
  String get historyFutureTitle;

  /// No description provided for @historyFutureBody.
  ///
  /// In en, this message translates to:
  /// **'Come back once it\'s underway.'**
  String get historyFutureBody;

  /// No description provided for @historyPlanVsActual.
  ///
  /// In en, this message translates to:
  /// **'Plan vs. actual'**
  String get historyPlanVsActual;

  /// No description provided for @historyChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Planned {planned}, actual {actual}'**
  String historyChartSemantics(String planned, String actual);

  /// No description provided for @historyLegendPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get historyLegendPlan;

  /// No description provided for @historyLegendActual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get historyLegendActual;

  /// No description provided for @historyWeekEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No weekly history yet'**
  String get historyWeekEmptyTitle;

  /// No description provided for @historyWeekEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'After a few days of logging, your week appears here as a calm overview, not a scoreboard.'**
  String get historyWeekEmptyBody;

  /// No description provided for @historyDayStatusOnPlan.
  ///
  /// In en, this message translates to:
  /// **'On plan'**
  String get historyDayStatusOnPlan;

  /// No description provided for @historyDayStatusSteady.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get historyDayStatusSteady;

  /// No description provided for @historyDayStatusAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get historyDayStatusAttention;

  /// No description provided for @historyDayStatusNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get historyDayStatusNoData;

  /// No description provided for @historyDayPercentStatus.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · {status}'**
  String historyDayPercentStatus(String percent, String status);

  /// No description provided for @historyMonthTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly rhythm'**
  String get historyMonthTrendTitle;

  /// No description provided for @historyMonthSummary.
  ///
  /// In en, this message translates to:
  /// **'{days} active days · {complete} on plan'**
  String historyMonthSummary(String days, String complete);

  /// No description provided for @historyMonthAverage.
  ///
  /// In en, this message translates to:
  /// **'Average plan adherence {percent}%'**
  String historyMonthAverage(String percent);

  /// No description provided for @historyMonthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your month starts here'**
  String get historyMonthEmptyTitle;

  /// No description provided for @historyMonthEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Trends appear once there are a few days of history to compare.'**
  String get historyMonthEmptyBody;

  /// No description provided for @historyCalendarCell.
  ///
  /// In en, this message translates to:
  /// **'{date}: {status}'**
  String historyCalendarCell(String date, String status);

  /// No description provided for @historyEditPro.
  ///
  /// In en, this message translates to:
  /// **'Editing earlier days is part of HYDRA Pro.'**
  String get historyEditPro;

  /// No description provided for @historyWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String historyWeekOf(String date);

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @adLabel.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get adLabel;

  /// No description provided for @adSponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get adSponsored;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @momentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration momentum'**
  String get momentumTitle;

  /// No description provided for @momentumDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A behaviour score about your routine. It isn\'t a health measure.'**
  String get momentumDisclaimer;

  /// No description provided for @momentumTierBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get momentumTierBuilding;

  /// No description provided for @momentumTierSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get momentumTierSteady;

  /// No description provided for @momentumTierStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get momentumTierStrong;

  /// No description provided for @momentumTierExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get momentumTierExcellent;

  /// No description provided for @momentumTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Up {points} from the previous two weeks'**
  String momentumTrendUp(String points);

  /// No description provided for @momentumTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Down {points} from the previous two weeks'**
  String momentumTrendDown(String points);

  /// No description provided for @momentumTrendFlat.
  ///
  /// In en, this message translates to:
  /// **'Holding steady'**
  String get momentumTrendFlat;

  /// No description provided for @momentumInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Momentum appears after about five days of use. There\'s no rush.'**
  String get momentumInsufficient;

  /// No description provided for @momentumComponentConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get momentumComponentConsistency;

  /// No description provided for @momentumComponentStability.
  ///
  /// In en, this message translates to:
  /// **'Routine stability'**
  String get momentumComponentStability;

  /// No description provided for @momentumComponentResponse.
  ///
  /// In en, this message translates to:
  /// **'Reminder response'**
  String get momentumComponentResponse;

  /// No description provided for @momentumComponentTiming.
  ///
  /// In en, this message translates to:
  /// **'Plan timing'**
  String get momentumComponentTiming;

  /// No description provided for @momentumComponentIndependence.
  ///
  /// In en, this message translates to:
  /// **'Self-started logging'**
  String get momentumComponentIndependence;

  /// No description provided for @consistencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistencyTitle;

  /// No description provided for @consistencyBody.
  ///
  /// In en, this message translates to:
  /// **'Your last 30 days, with recent days counting a little more. One quiet day doesn\'t undo your rhythm.'**
  String get consistencyBody;

  /// No description provided for @consistencyInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Consistency appears after about three days.'**
  String get consistencyInsufficient;

  /// No description provided for @consistencyBuilding.
  ///
  /// In en, this message translates to:
  /// **'You\'re building a reliable rhythm.'**
  String get consistencyBuilding;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String streakDays(String days);

  /// No description provided for @streakBest.
  ///
  /// In en, this message translates to:
  /// **'Best: {days}'**
  String streakBest(String days);

  /// No description provided for @streakRecovery.
  ///
  /// In en, this message translates to:
  /// **'A recovery day is available, so one miss won\'t reset you.'**
  String get streakRecovery;

  /// No description provided for @streakRecoveryUsed.
  ///
  /// In en, this message translates to:
  /// **'Yesterday didn\'t end your streak.'**
  String get streakRecoveryUsed;

  /// No description provided for @independenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder independence'**
  String get independenceTitle;

  /// No description provided for @independenceCelebrate.
  ///
  /// In en, this message translates to:
  /// **'You needed {percent}% fewer reminders than when you started.'**
  String independenceCelebrate(String percent);

  /// No description provided for @independenceCelebrateBody.
  ///
  /// In en, this message translates to:
  /// **'Your consistency held while you relied on reminders less. That\'s habit forming.'**
  String get independenceCelebrateBody;

  /// No description provided for @independenceSteady.
  ///
  /// In en, this message translates to:
  /// **'Your reminder use is steady. HYDRA never reduces reminders just to improve this number.'**
  String get independenceSteady;

  /// No description provided for @independenceInsufficient.
  ///
  /// In en, this message translates to:
  /// **'This appears after about four weeks of use.'**
  String get independenceInsufficient;

  /// No description provided for @habitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit stage'**
  String get habitTitle;

  /// No description provided for @habitNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {stage}'**
  String habitNext(String stage);

  /// No description provided for @stageRemember.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get stageRemember;

  /// No description provided for @stageRememberBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA reminds you while you settle in.'**
  String get stageRememberBody;

  /// No description provided for @stageRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get stageRespond;

  /// No description provided for @stageRespondBody.
  ///
  /// In en, this message translates to:
  /// **'You regularly act on reminders.'**
  String get stageRespondBody;

  /// No description provided for @stagePredict.
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get stagePredict;

  /// No description provided for @stagePredictBody.
  ///
  /// In en, this message translates to:
  /// **'Your routine is becoming predictable, so HYDRA can time reminders better.'**
  String get stagePredictBody;

  /// No description provided for @stageRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get stageRoutine;

  /// No description provided for @stageRoutineBody.
  ///
  /// In en, this message translates to:
  /// **'Hydration fits into your day.'**
  String get stageRoutineBody;

  /// No description provided for @stageAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get stageAutomatic;

  /// No description provided for @stageAutomaticBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s second nature now. HYDRA mostly stays quiet.'**
  String get stageAutomaticBody;

  /// No description provided for @insightsPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patterns'**
  String get insightsPatternsTitle;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challengesTitle;

  /// No description provided for @challengesBody.
  ///
  /// In en, this message translates to:
  /// **'Gentle goals about routine, never about drinking more.'**
  String get challengesBody;

  /// No description provided for @challengeProgress.
  ///
  /// In en, this message translates to:
  /// **'{progress} of {goal}'**
  String challengeProgress(String progress, String goal);

  /// No description provided for @challengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get challengeCompleted;

  /// No description provided for @challengeMorningMomentumTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Momentum'**
  String get challengeMorningMomentumTitle;

  /// No description provided for @challengeMorningMomentumBody.
  ///
  /// In en, this message translates to:
  /// **'Have your first drink within 90 minutes of waking.'**
  String get challengeMorningMomentumBody;

  /// No description provided for @challengeQuietConsistencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet Consistency'**
  String get challengeQuietConsistencyTitle;

  /// No description provided for @challengeQuietConsistencyBody.
  ///
  /// In en, this message translates to:
  /// **'Stay on plan with three reminders or fewer in a day.'**
  String get challengeQuietConsistencyBody;

  /// No description provided for @challengeWeekdayRhythmTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekday Rhythm'**
  String get challengeWeekdayRhythmTitle;

  /// No description provided for @challengeWeekdayRhythmBody.
  ///
  /// In en, this message translates to:
  /// **'Keep your routine going on weekdays.'**
  String get challengeWeekdayRhythmBody;

  /// No description provided for @challengeAfternoonRescueTitle.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Rescue'**
  String get challengeAfternoonRescueTitle;

  /// No description provided for @challengeAfternoonRescueBody.
  ///
  /// In en, this message translates to:
  /// **'Stay on plan through the afternoon.'**
  String get challengeAfternoonRescueBody;

  /// No description provided for @challengeRoutineBuilderTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Builder'**
  String get challengeRoutineBuilderTitle;

  /// No description provided for @challengeRoutineBuilderBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day at a similar time.'**
  String get challengeRoutineBuilderBody;

  /// No description provided for @challengeWindow.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String challengeWindow(String days);

  /// No description provided for @challengesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active challenges'**
  String get challengesEmptyTitle;

  /// No description provided for @challengesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Challenges appear here when they\'re available.'**
  String get challengesEmptyBody;

  /// No description provided for @recapWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get recapWeeklyTitle;

  /// No description provided for @recapWeeklyCta.
  ///
  /// In en, this message translates to:
  /// **'See your week'**
  String get recapWeeklyCta;

  /// No description provided for @recapMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your month'**
  String get recapMonthlyTitle;

  /// No description provided for @recapMonthlyCta.
  ///
  /// In en, this message translates to:
  /// **'See your month'**
  String get recapMonthlyCta;

  /// No description provided for @recapNeedMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first recap is on its way'**
  String get recapNeedMoreTitle;

  /// No description provided for @recapNeedMoreBody.
  ///
  /// In en, this message translates to:
  /// **'A weekly recap appears after about three days of use.'**
  String get recapNeedMoreBody;

  /// No description provided for @recapConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get recapConsistency;

  /// No description provided for @recapStrongestDay.
  ///
  /// In en, this message translates to:
  /// **'Strongest day'**
  String get recapStrongestDay;

  /// No description provided for @recapBestWindow.
  ///
  /// In en, this message translates to:
  /// **'Most consistent window'**
  String get recapBestWindow;

  /// No description provided for @recapOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Biggest opportunity'**
  String get recapOpportunity;

  /// No description provided for @recapCompletion.
  ///
  /// In en, this message translates to:
  /// **'Plan completion'**
  String get recapCompletion;

  /// No description provided for @recapCompletionValue.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} days'**
  String recapCompletionValue(String done, String total);

  /// No description provided for @recapResponse.
  ///
  /// In en, this message translates to:
  /// **'Reminder response'**
  String get recapResponse;

  /// No description provided for @recapTrend.
  ///
  /// In en, this message translates to:
  /// **'Compared with last week'**
  String get recapTrend;

  /// No description provided for @recapTrendUp.
  ///
  /// In en, this message translates to:
  /// **'Up {points} points'**
  String recapTrendUp(String points);

  /// No description provided for @recapTrendDown.
  ///
  /// In en, this message translates to:
  /// **'Down {points} points'**
  String recapTrendDown(String points);

  /// No description provided for @recapTrendFlat.
  ///
  /// In en, this message translates to:
  /// **'About the same'**
  String get recapTrendFlat;

  /// No description provided for @recapReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders per day'**
  String get recapReminders;

  /// No description provided for @recapRemindersFewer.
  ///
  /// In en, this message translates to:
  /// **'{percent}% fewer than last week'**
  String recapRemindersFewer(String percent);

  /// No description provided for @recapRemindersMore.
  ///
  /// In en, this message translates to:
  /// **'{percent}% more than last week'**
  String recapRemindersMore(String percent);

  /// No description provided for @recapEncourageUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re becoming more consistent.'**
  String get recapEncourageUp;

  /// No description provided for @recapEncourageSteady.
  ///
  /// In en, this message translates to:
  /// **'Your rhythm is holding steady.'**
  String get recapEncourageSteady;

  /// No description provided for @recapEncourageDown.
  ///
  /// In en, this message translates to:
  /// **'A quieter week. Your rhythm is still there.'**
  String get recapEncourageDown;

  /// No description provided for @recapShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get recapShare;

  /// No description provided for @recapShareChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose what to include'**
  String get recapShareChoose;

  /// No description provided for @recapShareHint.
  ///
  /// In en, this message translates to:
  /// **'Only the items you tick are added to the image.'**
  String get recapShareHint;

  /// No description provided for @recapShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image.'**
  String get recapShareFailed;

  /// No description provided for @segMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get segMorning;

  /// No description provided for @segAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get segAfternoon;

  /// No description provided for @segEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get segEvening;

  /// No description provided for @recapMonthlyActive.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get recapMonthlyActive;

  /// No description provided for @recapMonthlyBestRoutine.
  ///
  /// In en, this message translates to:
  /// **'Best routine'**
  String get recapMonthlyBestRoutine;

  /// No description provided for @recapMonthlyFavoriteVessel.
  ///
  /// In en, this message translates to:
  /// **'Favorite vessel'**
  String get recapMonthlyFavoriteVessel;

  /// No description provided for @recapMonthlyImproved.
  ///
  /// In en, this message translates to:
  /// **'Most improved'**
  String get recapMonthlyImproved;

  /// No description provided for @recapMonthlyHabit.
  ///
  /// In en, this message translates to:
  /// **'Habit stage'**
  String get recapMonthlyHabit;

  /// No description provided for @recapMonthlyMomentum.
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get recapMonthlyMomentum;

  /// No description provided for @recapMonthlyLocked.
  ///
  /// In en, this message translates to:
  /// **'The full monthly report is part of HYDRA Pro.'**
  String get recapMonthlyLocked;

  /// No description provided for @recapMonthlyWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to see it once'**
  String get recapMonthlyWatch;

  /// No description provided for @recapMonthlyUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with HYDRA Pro'**
  String get recapMonthlyUnlock;

  /// No description provided for @recapMonthlyAdFailed.
  ///
  /// In en, this message translates to:
  /// **'No ad is available right now. Try again later.'**
  String get recapMonthlyAdFailed;

  /// No description provided for @routineKindWeekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get routineKindWeekday;

  /// No description provided for @routineKindWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get routineKindWeekend;

  /// No description provided for @routineKindWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get routineKindWork;

  /// No description provided for @routineKindStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get routineKindStudy;

  /// No description provided for @routineKindWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get routineKindWorkout;

  /// No description provided for @routineKindTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get routineKindTravel;

  /// No description provided for @routineKindCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get routineKindCustom;

  /// No description provided for @youTitle.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youTitle;

  /// No description provided for @youProCardTitle.
  ///
  /// In en, this message translates to:
  /// **'HYDRA Pro'**
  String get youProCardTitle;

  /// No description provided for @youProCardBody.
  ///
  /// In en, this message translates to:
  /// **'Your hydration system, optimized around your life.'**
  String get youProCardBody;

  /// No description provided for @youProActive.
  ///
  /// In en, this message translates to:
  /// **'HYDRA Pro is active'**
  String get youProActive;

  /// No description provided for @youProManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get youProManage;

  /// No description provided for @youSectionPlan.
  ///
  /// In en, this message translates to:
  /// **'Your plan'**
  String get youSectionPlan;

  /// No description provided for @youSectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get youSectionReminders;

  /// No description provided for @youSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data and connections'**
  String get youSectionData;

  /// No description provided for @youSectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get youSectionApp;

  /// No description provided for @youGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily target'**
  String get youGoal;

  /// No description provided for @youSchedule.
  ///
  /// In en, this message translates to:
  /// **'Wake and sleep'**
  String get youSchedule;

  /// No description provided for @youStyle.
  ///
  /// In en, this message translates to:
  /// **'Reminder style'**
  String get youStyle;

  /// No description provided for @youRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get youRoutines;

  /// No description provided for @youVessels.
  ///
  /// In en, this message translates to:
  /// **'Vessels'**
  String get youVessels;

  /// No description provided for @youUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement'**
  String get youUnits;

  /// No description provided for @youNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get youNotifications;

  /// No description provided for @youHealth.
  ///
  /// In en, this message translates to:
  /// **'Health sync'**
  String get youHealth;

  /// No description provided for @youPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Center'**
  String get youPrivacy;

  /// No description provided for @youAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get youAppearance;

  /// No description provided for @youSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get youSupport;

  /// No description provided for @youDebug.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get youDebug;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily target'**
  String get goalTitle;

  /// No description provided for @goalBody.
  ///
  /// In en, this message translates to:
  /// **'This is the amount you choose to aim for. HYDRA never changes it on its own, and it isn\'t medical advice.'**
  String get goalBody;

  /// No description provided for @goalCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current target'**
  String get goalCurrent;

  /// No description provided for @goalSave.
  ///
  /// In en, this message translates to:
  /// **'Save target'**
  String get goalSave;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Target updated'**
  String get goalSaved;

  /// No description provided for @goalHotNote.
  ///
  /// In en, this message translates to:
  /// **'If it\'s hot or you\'re very active, you may want a higher target. That\'s your call.'**
  String get goalHotNote;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake and sleep'**
  String get scheduleTitle;

  /// No description provided for @scheduleBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA spreads your target across your waking hours and stays quiet while you sleep.'**
  String get scheduleBody;

  /// No description provided for @scheduleWake.
  ///
  /// In en, this message translates to:
  /// **'Wake time'**
  String get scheduleWake;

  /// No description provided for @scheduleSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep time'**
  String get scheduleSleep;

  /// No description provided for @scheduleWeekendToggle.
  ///
  /// In en, this message translates to:
  /// **'Different on weekends'**
  String get scheduleWeekendToggle;

  /// No description provided for @scheduleWeekendWake.
  ///
  /// In en, this message translates to:
  /// **'Weekend wake time'**
  String get scheduleWeekendWake;

  /// No description provided for @scheduleWeekendSleep.
  ///
  /// In en, this message translates to:
  /// **'Weekend sleep time'**
  String get scheduleWeekendSleep;

  /// No description provided for @scheduleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Those times don\'t make a valid day. Try at least six hours awake.'**
  String get scheduleInvalid;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule updated'**
  String get scheduleSaved;

  /// No description provided for @scheduleEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Hydration environment'**
  String get scheduleEnvironment;

  /// No description provided for @scheduleEnvironmentNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get scheduleEnvironmentNormal;

  /// No description provided for @scheduleEnvironmentHot.
  ///
  /// In en, this message translates to:
  /// **'Hot or very active'**
  String get scheduleEnvironmentHot;

  /// No description provided for @scheduleEnvironmentBody.
  ///
  /// In en, this message translates to:
  /// **'Hot days make HYDRA check in a little more often. Your target stays yours.'**
  String get scheduleEnvironmentBody;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get remindersTitle;

  /// No description provided for @remindersToggle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersToggle;

  /// No description provided for @remindersToggleBody.
  ///
  /// In en, this message translates to:
  /// **'Adaptive check-ins during your day.'**
  String get remindersToggleBody;

  /// No description provided for @remindersPermissionOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for HYDRA in system settings.'**
  String get remindersPermissionOff;

  /// No description provided for @remindersPermissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get remindersPermissionAllow;

  /// No description provided for @remindersStyle.
  ///
  /// In en, this message translates to:
  /// **'Reminder style'**
  String get remindersStyle;

  /// No description provided for @remindersTone.
  ///
  /// In en, this message translates to:
  /// **'Wording'**
  String get remindersTone;

  /// No description provided for @toneAuto.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get toneAuto;

  /// No description provided for @toneAutoBody.
  ///
  /// In en, this message translates to:
  /// **'Wording follows how your day is going.'**
  String get toneAutoBody;

  /// No description provided for @toneGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get toneGentle;

  /// No description provided for @toneNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get toneNeutral;

  /// No description provided for @toneEncouraging.
  ///
  /// In en, this message translates to:
  /// **'Encouraging'**
  String get toneEncouraging;

  /// No description provided for @toneProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get toneProgress;

  /// No description provided for @remindersQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Smart quiet hours'**
  String get remindersQuietHours;

  /// No description provided for @remindersQuietBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA notices times you usually skip reminders and can stay quiet then.'**
  String get remindersQuietBody;

  /// No description provided for @remindersQuietSuggestion.
  ///
  /// In en, this message translates to:
  /// **'You usually skip reminders around {start} to {end}. Stay quiet then?'**
  String remindersQuietSuggestion(String start, String end);

  /// No description provided for @remindersQuietAccept.
  ///
  /// In en, this message translates to:
  /// **'Add quiet time'**
  String get remindersQuietAccept;

  /// No description provided for @remindersQuietNone.
  ///
  /// In en, this message translates to:
  /// **'No pattern yet. HYDRA learns from a few days of responses.'**
  String get remindersQuietNone;

  /// No description provided for @remindersHelp.
  ///
  /// In en, this message translates to:
  /// **'Notifications not arriving?'**
  String get remindersHelp;

  /// No description provided for @remindersFatigueNote.
  ///
  /// In en, this message translates to:
  /// **'HYDRA slows down automatically when reminders aren\'t helping.'**
  String get remindersFatigueNote;

  /// No description provided for @notifHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification check-up'**
  String get notifHelpTitle;

  /// No description provided for @notifHelpBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA checks each thing that has to be right for reminders to arrive.'**
  String get notifHelpBody;

  /// No description provided for @notifHelpPermission.
  ///
  /// In en, this message translates to:
  /// **'Notifications allowed'**
  String get notifHelpPermission;

  /// No description provided for @notifHelpRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders turned on'**
  String get notifHelpRemindersOn;

  /// No description provided for @notifHelpNotPaused.
  ///
  /// In en, this message translates to:
  /// **'Not paused'**
  String get notifHelpNotPaused;

  /// No description provided for @notifHelpScheduled.
  ///
  /// In en, this message translates to:
  /// **'Next reminder scheduled'**
  String get notifHelpScheduled;

  /// No description provided for @notifHelpNextAt.
  ///
  /// In en, this message translates to:
  /// **'Next reminder: {time}'**
  String notifHelpNextAt(String time);

  /// No description provided for @notifHelpBattery.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s battery saver may delay reminders. If they arrive late, exclude HYDRA from battery optimization.'**
  String get notifHelpBattery;

  /// No description provided for @notifHelpFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus or Do Not Disturb modes can silence reminders on purpose.'**
  String get notifHelpFocus;

  /// No description provided for @notifHelpTest.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get notifHelpTest;

  /// No description provided for @notifHelpTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test sent'**
  String get notifHelpTestSent;

  /// No description provided for @notifHelpFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get notifHelpFix;

  /// No description provided for @notifHelpOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get notifHelpOk;

  /// No description provided for @notifHelpNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get notifHelpNeedsAttention;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'This is a test reminder from HYDRA.'**
  String get notifTestBody;

  /// No description provided for @vesselsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vessels'**
  String get vesselsTitle;

  /// No description provided for @vesselsBody.
  ///
  /// In en, this message translates to:
  /// **'Log your own bottle or glass in one tap.'**
  String get vesselsBody;

  /// No description provided for @vesselsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No vessels yet'**
  String get vesselsEmptyTitle;

  /// No description provided for @vesselsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the glass or bottle you actually use, and logging becomes a single tap.'**
  String get vesselsEmptyBody;

  /// No description provided for @vesselsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add vessel'**
  String get vesselsAdd;

  /// No description provided for @vesselName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get vesselName;

  /// No description provided for @vesselAmount.
  ///
  /// In en, this message translates to:
  /// **'Volume ({unit})'**
  String vesselAmount(String unit);

  /// No description provided for @vesselIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get vesselIcon;

  /// No description provided for @vesselFavorite.
  ///
  /// In en, this message translates to:
  /// **'Show on home'**
  String get vesselFavorite;

  /// No description provided for @vesselLimit.
  ///
  /// In en, this message translates to:
  /// **'Free includes {count} vessels. HYDRA Pro has no limit.'**
  String vesselLimit(String count);

  /// No description provided for @vesselLimitWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad for one extra slot today'**
  String get vesselLimitWatch;

  /// No description provided for @vesselDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this vessel?'**
  String get vesselDeleteTitle;

  /// No description provided for @vesselDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Past entries keep their amounts.'**
  String get vesselDeleteBody;

  /// No description provided for @vesselSaved.
  ///
  /// In en, this message translates to:
  /// **'Vessel saved'**
  String get vesselSaved;

  /// No description provided for @vesselDefaultGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get vesselDefaultGlass;

  /// No description provided for @vesselDefaultDesk.
  ///
  /// In en, this message translates to:
  /// **'Desk bottle'**
  String get vesselDefaultDesk;

  /// No description provided for @vesselDefaultGym.
  ///
  /// In en, this message translates to:
  /// **'Gym bottle'**
  String get vesselDefaultGym;

  /// No description provided for @routinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routinesTitle;

  /// No description provided for @routinesBody.
  ///
  /// In en, this message translates to:
  /// **'A routine sets wake, sleep and quiet times for certain days. Switch with one tap.'**
  String get routinesBody;

  /// No description provided for @routinesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get routinesEmptyTitle;

  /// No description provided for @routinesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your wake and sleep times apply every day. Add a routine for work days, study, workouts or travel.'**
  String get routinesEmptyBody;

  /// No description provided for @routinesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add routine'**
  String get routinesAdd;

  /// No description provided for @routinesActive.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get routinesActive;

  /// No description provided for @routinesUse.
  ///
  /// In en, this message translates to:
  /// **'Use now'**
  String get routinesUse;

  /// No description provided for @routinesUseAuto.
  ///
  /// In en, this message translates to:
  /// **'Back to automatic'**
  String get routinesUseAuto;

  /// No description provided for @routinesDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get routinesDays;

  /// No description provided for @routinesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get routinesName;

  /// No description provided for @routinesKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get routinesKind;

  /// No description provided for @routinesQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet times'**
  String get routinesQuiet;

  /// No description provided for @routinesQuietAdd.
  ///
  /// In en, this message translates to:
  /// **'Add quiet time'**
  String get routinesQuietAdd;

  /// No description provided for @routinesWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout window'**
  String get routinesWorkout;

  /// No description provided for @routinesWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders pause during this time and resume right after.'**
  String get routinesWorkoutBody;

  /// No description provided for @routinesFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get routinesFrom;

  /// No description provided for @routinesTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get routinesTo;

  /// No description provided for @routinesLimit.
  ///
  /// In en, this message translates to:
  /// **'Free includes {count} routines. HYDRA Pro has no limit.'**
  String routinesLimit(String count);

  /// No description provided for @routinesProKind.
  ///
  /// In en, this message translates to:
  /// **'Workout and Travel routines are part of HYDRA Pro.'**
  String get routinesProKind;

  /// No description provided for @routinesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this routine?'**
  String get routinesDeleteTitle;

  /// No description provided for @routinesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your history isn\'t affected.'**
  String get routinesDeleteBody;

  /// No description provided for @routinesSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get routinesSaved;

  /// No description provided for @routinesInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the wake and sleep times.'**
  String get routinesInvalid;

  /// No description provided for @routinesNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Give the routine a short name.'**
  String get routinesNameInvalid;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health sync'**
  String get healthTitle;

  /// No description provided for @healthIntro.
  ///
  /// In en, this message translates to:
  /// **'Sync water intake with your health app. HYDRA reads and writes water only: nothing else.'**
  String get healthIntro;

  /// No description provided for @healthProBody.
  ///
  /// In en, this message translates to:
  /// **'Health sync is part of HYDRA Pro.'**
  String get healthProBody;

  /// No description provided for @healthProCta.
  ///
  /// In en, this message translates to:
  /// **'See HYDRA Pro'**
  String get healthProCta;

  /// No description provided for @healthEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on Health sync'**
  String get healthEnable;

  /// No description provided for @healthDisable.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get healthDisable;

  /// No description provided for @healthDirection.
  ///
  /// In en, this message translates to:
  /// **'What to sync'**
  String get healthDirection;

  /// No description provided for @healthDirectionTwoWay.
  ///
  /// In en, this message translates to:
  /// **'Both ways'**
  String get healthDirectionTwoWay;

  /// No description provided for @healthDirectionImport.
  ///
  /// In en, this message translates to:
  /// **'Import from Health'**
  String get healthDirectionImport;

  /// No description provided for @healthDirectionExport.
  ///
  /// In en, this message translates to:
  /// **'Send HYDRA to Health'**
  String get healthDirectionExport;

  /// No description provided for @healthSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get healthSyncNow;

  /// No description provided for @healthLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String healthLastSync(String time);

  /// No description provided for @healthNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get healthNever;

  /// No description provided for @healthSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced: {imported} imported, {exported} sent'**
  String healthSynced(String imported, String exported);

  /// No description provided for @healthAvailabilityMissing.
  ///
  /// In en, this message translates to:
  /// **'Health Connect isn\'t installed on this device.'**
  String get healthAvailabilityMissing;

  /// No description provided for @healthAvailabilityUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Health sync isn\'t available on this device.'**
  String get healthAvailabilityUnsupported;

  /// No description provided for @healthInstall.
  ///
  /// In en, this message translates to:
  /// **'Install Health Connect'**
  String get healthInstall;

  /// No description provided for @healthPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'HYDRA doesn\'t have permission to read or write water intake.'**
  String get healthPermissionDenied;

  /// No description provided for @healthManagePermissions.
  ///
  /// In en, this message translates to:
  /// **'Manage health permissions'**
  String get healthManagePermissions;

  /// No description provided for @healthFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'HYDRA couldn\'t sync right now.'**
  String get healthFailedTitle;

  /// No description provided for @healthFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Your drinks are safe in HYDRA and tracking continues as normal.'**
  String get healthFailedBody;

  /// No description provided for @healthContinueWithout.
  ///
  /// In en, this message translates to:
  /// **'Continue without sync'**
  String get healthContinueWithout;

  /// No description provided for @healthDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Deleting HYDRA data doesn\'t delete records already in your health app. Remove those there.'**
  String get healthDeleteNote;

  /// No description provided for @healthDuplicateNote.
  ///
  /// In en, this message translates to:
  /// **'HYDRA matches drinks it already knows about, so nothing is counted twice.'**
  String get healthDuplicateNote;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Center'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Your hydration history stays on this device. No account. Health data is never used to choose ads.'**
  String get privacyIntro;

  /// No description provided for @privacyYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get privacyYourData;

  /// No description provided for @privacyHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration history'**
  String get privacyHydration;

  /// No description provided for @privacyHydrationValue.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get privacyHydrationValue;

  /// No description provided for @privacyHealth.
  ///
  /// In en, this message translates to:
  /// **'Health sync'**
  String get privacyHealth;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Anonymous usage statistics'**
  String get privacyAnalytics;

  /// No description provided for @privacyAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'Product events like \'onboarding completed\'. Never amounts or history.'**
  String get privacyAnalyticsBody;

  /// No description provided for @privacyAds.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get privacyAds;

  /// No description provided for @privacyAdsValue.
  ///
  /// In en, this message translates to:
  /// **'Contextual only'**
  String get privacyAdsValue;

  /// No description provided for @privacyAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Ads never use your hydration or health data.'**
  String get privacyAdsBody;

  /// No description provided for @privacyPro.
  ///
  /// In en, this message translates to:
  /// **'Ad-free with HYDRA Pro'**
  String get privacyPro;

  /// No description provided for @privacyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get privacyNotifications;

  /// No description provided for @privacyStorage.
  ///
  /// In en, this message translates to:
  /// **'Local storage'**
  String get privacyStorage;

  /// No description provided for @privacyStorageValue.
  ///
  /// In en, this message translates to:
  /// **'Private app storage'**
  String get privacyStorageValue;

  /// No description provided for @privacyWidgetHide.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts in widgets'**
  String get privacyWidgetHide;

  /// No description provided for @privacyWidgetHideBody.
  ///
  /// In en, this message translates to:
  /// **'Widgets show only the percentage.'**
  String get privacyWidgetHideBody;

  /// No description provided for @privacyExport.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get privacyExport;

  /// No description provided for @privacyExportBody.
  ///
  /// In en, this message translates to:
  /// **'A CSV or JSON file with every entry, vessel and routine.'**
  String get privacyExportBody;

  /// No description provided for @privacyExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get privacyExportCsv;

  /// No description provided for @privacyExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get privacyExportJson;

  /// No description provided for @privacyExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the export.'**
  String get privacyExportFailed;

  /// No description provided for @privacyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get privacyDelete;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Removes everything from this device.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all HYDRA data?'**
  String get privacyDeleteConfirmTitle;

  /// No description provided for @privacyDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes:\n• hydration history\n• vessels\n• routines\n• preferences\n• local insights\n\nHealth records in your health app are not deleted. Your subscription is separate and isn\'t cancelled.'**
  String get privacyDeleteConfirmBody;

  /// No description provided for @privacyDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get privacyDeleteConfirmAction;

  /// No description provided for @privacyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your data was deleted.'**
  String get privacyDeleted;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy choices'**
  String get privacyChoices;

  /// No description provided for @privacyHealthPerms.
  ///
  /// In en, this message translates to:
  /// **'Manage health permissions'**
  String get privacyHealthPerms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get privacyTerms;

  /// No description provided for @privacyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link.'**
  String get privacyOpenFailed;

  /// No description provided for @privacyExportContents.
  ///
  /// In en, this message translates to:
  /// **'Exports contain: id, date, time (UTC), timezone, volume in ml, vessel and source.'**
  String get privacyExportContents;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get appearanceMode;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get appearanceThemes;

  /// No description provided for @appearanceOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get appearanceOcean;

  /// No description provided for @appearanceAurora.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get appearanceAurora;

  /// No description provided for @appearanceGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get appearanceGraphite;

  /// No description provided for @appearanceThemeProNote.
  ///
  /// In en, this message translates to:
  /// **'Aurora and Graphite are part of HYDRA Pro.'**
  String get appearanceThemeProNote;

  /// No description provided for @appearanceWatchTheme.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to try Aurora for 24 hours'**
  String get appearanceWatchTheme;

  /// No description provided for @appearanceThemeUntil.
  ///
  /// In en, this message translates to:
  /// **'Aurora is on until tomorrow.'**
  String get appearanceThemeUntil;

  /// No description provided for @appearanceReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'HYDRA follows your system\'s reduce-motion setting.'**
  String get appearanceReduceMotion;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'HYDRA Pro'**
  String get paywallTitle;

  /// No description provided for @paywallHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your hydration system, optimized around your life.'**
  String get paywallHeadline;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallBenefitScheduler.
  ///
  /// In en, this message translates to:
  /// **'Advanced adaptive scheduling'**
  String get paywallBenefitScheduler;

  /// No description provided for @paywallBenefitHealth.
  ///
  /// In en, this message translates to:
  /// **'Health sync'**
  String get paywallBenefitHealth;

  /// No description provided for @paywallBenefitInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced insights'**
  String get paywallBenefitInsights;

  /// No description provided for @paywallBenefitVessels.
  ///
  /// In en, this message translates to:
  /// **'Unlimited vessels'**
  String get paywallBenefitVessels;

  /// No description provided for @paywallBenefitRoutines.
  ///
  /// In en, this message translates to:
  /// **'Advanced routines'**
  String get paywallBenefitRoutines;

  /// No description provided for @paywallBenefitTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel mode'**
  String get paywallBenefitTravel;

  /// No description provided for @paywallBenefitWidgets.
  ///
  /// In en, this message translates to:
  /// **'Advanced widgets'**
  String get paywallBenefitWidgets;

  /// No description provided for @paywallBenefitExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get paywallBenefitExport;

  /// No description provided for @paywallBenefitThemes.
  ///
  /// In en, this message translates to:
  /// **'Premium themes'**
  String get paywallBenefitThemes;

  /// No description provided for @paywallFreeNote.
  ///
  /// In en, this message translates to:
  /// **'Logging, reminders, progress and privacy controls stay free.'**
  String get paywallFreeNote;

  /// No description provided for @paywallAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallAnnual;

  /// No description provided for @paywallMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// No description provided for @paywallLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get paywallLifetime;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallBestValue;

  /// No description provided for @paywallPerMonth.
  ///
  /// In en, this message translates to:
  /// **'about {price} per month'**
  String paywallPerMonth(String price);

  /// No description provided for @paywallTrial.
  ///
  /// In en, this message translates to:
  /// **'{days}-day free trial, then {price}'**
  String paywallTrial(String days, String price);

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallContinue;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get paywallManage;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically unless cancelled at least 24 hours before the period ends. Manage or cancel any time in your store account settings.'**
  String get paywallTerms;

  /// No description provided for @paywallUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases aren\'t available right now'**
  String get paywallUnavailableTitle;

  /// No description provided for @paywallUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'HYDRA couldn\'t reach the store. Everything free keeps working. Please try again later.'**
  String get paywallUnavailableBody;

  /// No description provided for @paywallPurchased.
  ///
  /// In en, this message translates to:
  /// **'Welcome to HYDRA Pro'**
  String get paywallPurchased;

  /// No description provided for @paywallRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get paywallRestored;

  /// No description provided for @paywallRestoreNone.
  ///
  /// In en, this message translates to:
  /// **'No earlier purchase was found.'**
  String get paywallRestoreNone;

  /// No description provided for @paywallCancelled.
  ///
  /// In en, this message translates to:
  /// **'No charge was made.'**
  String get paywallCancelled;

  /// No description provided for @paywallPending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is pending approval.'**
  String get paywallPending;

  /// No description provided for @paywallFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase didn\'t go through. You haven\'t been charged.'**
  String get paywallFailed;

  /// No description provided for @paywallActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'You have HYDRA Pro'**
  String get paywallActiveTitle;

  /// No description provided for @paywallBillingIssue.
  ///
  /// In en, this message translates to:
  /// **'There\'s a problem with your payment method. Update it in your store account to keep Pro.'**
  String get paywallBillingIssue;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get supportTitle;

  /// No description provided for @supportFaqNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders aren\'t arriving'**
  String get supportFaqNotifTitle;

  /// No description provided for @supportFaqNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Open the notification check-up to see what to fix.'**
  String get supportFaqNotifBody;

  /// No description provided for @supportFaqHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health sync problems'**
  String get supportFaqHealthTitle;

  /// No description provided for @supportFaqHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Open Health sync to retry or continue without it.'**
  String get supportFaqHealthBody;

  /// No description provided for @supportFaqRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get supportFaqRestoreTitle;

  /// No description provided for @supportFaqRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Use Restore on the HYDRA Pro screen. No account is needed.'**
  String get supportFaqRestoreBody;

  /// No description provided for @supportContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get supportContact;

  /// No description provided for @supportCopyDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get supportCopyDiagnostics;

  /// No description provided for @supportDiagnosticsCopied.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied. They contain no hydration history.'**
  String get supportDiagnosticsCopied;

  /// No description provided for @supportAbout.
  ///
  /// In en, this message translates to:
  /// **'About HYDRA'**
  String get supportAbout;

  /// No description provided for @supportVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String supportVersion(String version);

  /// No description provided for @supportFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'How is HYDRA doing?'**
  String get supportFeedbackTitle;

  /// No description provided for @supportFeedbackLove.
  ///
  /// In en, this message translates to:
  /// **'Love it'**
  String get supportFeedbackLove;

  /// No description provided for @supportFeedbackGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get supportFeedbackGood;

  /// No description provided for @supportFeedbackOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get supportFeedbackOkay;

  /// No description provided for @supportFeedbackNot.
  ///
  /// In en, this message translates to:
  /// **'Not useful'**
  String get supportFeedbackNot;

  /// No description provided for @supportFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you.'**
  String get supportFeedbackThanks;

  /// No description provided for @supportFeedbackFix.
  ///
  /// In en, this message translates to:
  /// **'What should we fix?'**
  String get supportFeedbackFix;

  /// No description provided for @supportLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get supportLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
