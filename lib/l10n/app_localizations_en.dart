// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Boxer\'s timer';

  @override
  String get timers => 'Timers';

  @override
  String get run => 'Run';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get stop => 'Stop';

  @override
  String get classicBoxing => 'Classic boxing';

  @override
  String get amateurBoxing => 'Amateur boxing';

  @override
  String workTime(String time) {
    return 'Work: $time';
  }

  @override
  String restTime(String time) {
    return 'Rest: $time';
  }

  @override
  String prepareTime(String time) {
    return 'Prepare: $time';
  }

  @override
  String round(int number, int count) {
    return 'Round: $number / $count';
  }

  @override
  String roundsCount(int count) {
    return 'Rounds: $count';
  }

  @override
  String get skipToRest => 'Skip to rest';

  @override
  String get skipToNextRound => 'Next round';

  @override
  String get deleteMatch => 'Delete match';

  @override
  String deleteMatchConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editMatch => 'Edit match';

  @override
  String get addMatch => 'Add match';

  @override
  String get save => 'Save';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldRoundsCount => 'Rounds count';

  @override
  String get fieldWorkSeconds => 'Work seconds';

  @override
  String get fieldRestSeconds => 'Rest seconds';

  @override
  String get fieldDelaySeconds => 'Start delay seconds';

  @override
  String get fieldWarnWorkOptional => 'Warn work seconds (optional)';

  @override
  String get fieldWarnRestOptional => 'Warn rest seconds (optional)';

  @override
  String get keepScreenOn => 'Keep screen on during match';

  @override
  String get fieldImage => 'Image';

  @override
  String get fieldRoundStartSound => 'Round start sound';

  @override
  String get fieldRoundEndSound => 'Round end sound';

  @override
  String get fieldWarningSound => 'Warning sound';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationPositiveInt => 'Use a value > 0';

  @override
  String get validationNonNegativeInt => 'Use a value >= 0';

  @override
  String validationWarnWorkMax(int work) {
    return 'At most half of work seconds ($work)';
  }

  @override
  String validationWarnRestMax(int rest) {
    return 'At most half of rest seconds ($rest)';
  }

  @override
  String get mma => 'MMA';

  @override
  String get kickboxingAmateur => 'Kickboxing amateur';

  @override
  String get kickboxingClassic => 'Kickboxing classic';

  @override
  String get notificationChannelName => 'Boxing timer';

  @override
  String get notificationChannelDescription =>
      'Round timer status while a match is running';

  @override
  String get notificationInitialTitle => 'Boxing timer';

  @override
  String get notificationInitialContent => 'Match not running';

  @override
  String get defaultMatchName => 'Boxing timer';
}
