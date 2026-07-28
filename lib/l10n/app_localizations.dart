import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  /// App's title
  ///
  /// In en, this message translates to:
  /// **'Boxer\'s timer'**
  String get appTitle;

  /// Timers page
  ///
  /// In en, this message translates to:
  /// **'Timers'**
  String get timers;

  /// Run page
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// Start action
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Pause action
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Stop action
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Classic boxing
  ///
  /// In en, this message translates to:
  /// **'Classic boxing'**
  String get classicBoxing;

  /// Amateur boxing
  ///
  /// In en, this message translates to:
  /// **'Amateur boxing'**
  String get amateurBoxing;

  /// Work time
  ///
  /// In en, this message translates to:
  /// **'Work: {time}'**
  String workTime(String time);

  /// Rest time
  ///
  /// In en, this message translates to:
  /// **'Rest: {time}'**
  String restTime(String time);

  /// Prepare time
  ///
  /// In en, this message translates to:
  /// **'Prepare: {time}'**
  String prepareTime(String time);

  /// Round number
  ///
  /// In en, this message translates to:
  /// **'Round: {number} / {count}'**
  String round(int number, int count);

  /// Rounds count
  ///
  /// In en, this message translates to:
  /// **'Rounds: {count}'**
  String roundsCount(int count);

  /// Force transition from work to rest
  ///
  /// In en, this message translates to:
  /// **'Skip to rest'**
  String get skipToRest;

  /// Skip to the next round
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get skipToNextRound;

  /// Delete match dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete match'**
  String get deleteMatch;

  /// Delete match confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteMatchConfirm(String name);

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit match action
  ///
  /// In en, this message translates to:
  /// **'Edit match'**
  String get editMatch;

  /// Add match screen title
  ///
  /// In en, this message translates to:
  /// **'Add match'**
  String get addMatch;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Match name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Number of rounds field
  ///
  /// In en, this message translates to:
  /// **'Rounds count'**
  String get fieldRoundsCount;

  /// Work interval field
  ///
  /// In en, this message translates to:
  /// **'Work seconds'**
  String get fieldWorkSeconds;

  /// Rest interval field
  ///
  /// In en, this message translates to:
  /// **'Rest seconds'**
  String get fieldRestSeconds;

  /// Start delay field
  ///
  /// In en, this message translates to:
  /// **'Start delay seconds'**
  String get fieldDelaySeconds;

  /// Work warning threshold field
  ///
  /// In en, this message translates to:
  /// **'Warn work seconds (optional)'**
  String get fieldWarnWorkOptional;

  /// Rest warning threshold field
  ///
  /// In en, this message translates to:
  /// **'Warn rest seconds (optional)'**
  String get fieldWarnRestOptional;

  /// Wakelock toggle
  ///
  /// In en, this message translates to:
  /// **'Keep screen on during match'**
  String get keepScreenOn;

  /// Match icon field
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get fieldImage;

  /// Round start sound field
  ///
  /// In en, this message translates to:
  /// **'Round start sound'**
  String get fieldRoundStartSound;

  /// Round end sound field
  ///
  /// In en, this message translates to:
  /// **'Round end sound'**
  String get fieldRoundEndSound;

  /// Warning sound field
  ///
  /// In en, this message translates to:
  /// **'Warning sound'**
  String get fieldWarningSound;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// Positive integer validation
  ///
  /// In en, this message translates to:
  /// **'Use a value > 0'**
  String get validationPositiveInt;

  /// Non-negative integer validation
  ///
  /// In en, this message translates to:
  /// **'Use a value >= 0'**
  String get validationNonNegativeInt;

  /// Warn work max validation
  ///
  /// In en, this message translates to:
  /// **'At most half of work seconds ({work})'**
  String validationWarnWorkMax(int work);

  /// Warn rest max validation
  ///
  /// In en, this message translates to:
  /// **'At most half of rest seconds ({rest})'**
  String validationWarnRestMax(int rest);

  /// MMA preset name
  ///
  /// In en, this message translates to:
  /// **'MMA'**
  String get mma;

  /// Kickboxing amateur preset
  ///
  /// In en, this message translates to:
  /// **'Kickboxing amateur'**
  String get kickboxingAmateur;

  /// Kickboxing classic preset
  ///
  /// In en, this message translates to:
  /// **'Kickboxing classic'**
  String get kickboxingClassic;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Boxing timer'**
  String get notificationChannelName;

  /// Android notification channel description
  ///
  /// In en, this message translates to:
  /// **'Round timer status while a match is running'**
  String get notificationChannelDescription;

  /// Background service notification title before match
  ///
  /// In en, this message translates to:
  /// **'Boxing timer'**
  String get notificationInitialTitle;

  /// Background service notification body before match
  ///
  /// In en, this message translates to:
  /// **'Match not running'**
  String get notificationInitialContent;

  /// Fallback match name in notifications
  ///
  /// In en, this message translates to:
  /// **'Boxing timer'**
  String get defaultMatchName;
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
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
