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
  String wait(String time) {
    return 'Готовьтесь: $time';
  }

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
  String roundsCount(int count) {
    return 'Раундов: $count';
  }

  @override
  String get skipToRest => 'К отдыху';

  @override
  String get skipToNextRound => 'След. раунд';

  @override
  String get deleteMatch => 'Удалить таймер';

  @override
  String deleteMatchConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get editMatch => 'Изменить';

  @override
  String get addMatch => 'Новый таймер';

  @override
  String get save => 'Сохранить';

  @override
  String get fieldName => 'Название';

  @override
  String get fieldRoundsCount => 'Число раундов';

  @override
  String get fieldWorkSeconds => 'Работа, сек';

  @override
  String get fieldRestSeconds => 'Отдых, сек';

  @override
  String get fieldDelaySeconds => 'Задержка старта, сек';

  @override
  String get fieldWarnWorkOptional => 'Предупреждение работы, сек (необяз.)';

  @override
  String get fieldWarnRestOptional => 'Предупреждение отдыха, сек (необяз.)';

  @override
  String get keepScreenOn => 'Не гасить экран во время матча';

  @override
  String get fieldImage => 'Иконка';

  @override
  String get fieldRoundStartSound => 'Звук начала раунда';

  @override
  String get fieldRoundEndSound => 'Звук конца раунда';

  @override
  String get fieldWarningSound => 'Звук предупреждения';

  @override
  String get validationRequired => 'Обязательное поле';

  @override
  String get validationPositiveInt => 'Число должно быть > 0';

  @override
  String get validationNonNegativeInt => 'Число должно быть ≥ 0';

  @override
  String validationWarnWorkMax(int work) {
    return 'Не больше половины работы ($work сек)';
  }

  @override
  String validationWarnRestMax(int rest) {
    return 'Не больше половины отдыха ($rest сек)';
  }

  @override
  String get mma => 'MMA';

  @override
  String get kickboxingAmateur => 'Кикбоксинг любительский';

  @override
  String get kickboxingClassic => 'Кикбоксинг классический';

  @override
  String get notificationChannelName => 'Таймер боксёра';

  @override
  String get notificationChannelDescription => 'Статус раунда, пока идёт матч';

  @override
  String get notificationInitialTitle => 'Таймер боксёра';

  @override
  String get notificationInitialContent => 'Матч не запущен';

  @override
  String get defaultMatchName => 'Таймер боксёра';

  @override
  String get announceRounds => 'Озвучивать раунды';

  @override
  String get ttsVoiceGender => 'Голос';

  @override
  String get ttsVoiceFemale => 'Женский';

  @override
  String get ttsVoiceMale => 'Мужской';

  @override
  String ttsRound(int number) {
    return 'Раунд $number';
  }

  @override
  String ttsLastRound(int number) {
    return 'Раунд $number. Последний.';
  }
}
