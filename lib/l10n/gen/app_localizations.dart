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
