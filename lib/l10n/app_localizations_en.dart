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
  String get skipToRest => 'Skip to rest';

  @override
  String get skipToNextRound => 'Next round';
}
