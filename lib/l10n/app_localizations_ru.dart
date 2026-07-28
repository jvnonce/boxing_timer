// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Таймер боксёра';

  @override
  String get timers => 'Таймеры';

  @override
  String get run => 'Запуск';

  @override
  String get start => 'Старт';

  @override
  String get pause => 'Пауза';

  @override
  String get stop => 'Стоп';

  @override
  String get classicBoxing => 'Классический бокс';

  @override
  String get amateurBoxing => 'Любительский бокс';

  @override
  String workTime(String time) {
    return 'Работа: $time';
  }

  @override
  String restTime(String time) {
    return 'Отдых: $time';
  }

  @override
  String prepareTime(String time) {
    return 'Подготовка: $time';
  }

  @override
  String round(int number, int count) {
    return 'Раунд: $number / $count';
  }

  @override
  String get skipToRest => 'К отдыху';

  @override
  String get skipToNextRound => 'След. раунд';
}
