// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Temporizador de boxeo';

  @override
  String get timers => 'Temporizadores';

  @override
  String get run => 'Sesión';

  @override
  String wait(String time) {
    return 'Prepararse: $time';
  }

  @override
  String get start => 'Iniciar';

  @override
  String get pause => 'Pausa';

  @override
  String get stop => 'Detener';

  @override
  String get classicBoxing => 'Boxeo clásico';

  @override
  String get amateurBoxing => 'Boxeo amateur';

  @override
  String workTime(String time) {
    return 'Trabajo: $time';
  }

  @override
  String restTime(String time) {
    return 'Descanso: $time';
  }

  @override
  String prepareTime(String time) {
    return 'Preparación: $time';
  }

  @override
  String round(int number, int count) {
    return 'Asalto: $number / $count';
  }

  @override
  String roundsCount(int count) {
    return 'Asaltos: $count';
  }

  @override
  String get skipToRest => 'Al descanso';

  @override
  String get skipToNextRound => 'Siguiente asalto';

  @override
  String get deleteMatch => 'Eliminar temporizador';

  @override
  String deleteMatchConfirm(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get editMatch => 'Editar';

  @override
  String get addMatch => 'Nuevo temporizador';

  @override
  String get save => 'Guardar';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldRoundsCount => 'Número de asaltos';

  @override
  String get fieldWorkSeconds => 'Trabajo, seg';

  @override
  String get fieldRestSeconds => 'Descanso, seg';

  @override
  String get fieldDelaySeconds => 'Retardo inicial, seg';

  @override
  String get fieldWarnWorkOptional => 'Aviso trabajo, seg (opcional)';

  @override
  String get fieldWarnRestOptional => 'Aviso descanso, seg (opcional)';

  @override
  String get keepScreenOn => 'Mantener pantalla encendida';

  @override
  String get fieldImage => 'Icono';

  @override
  String get fieldRoundStartSound => 'Sonido inicio asalto';

  @override
  String get fieldRoundEndSound => 'Sonido fin asalto';

  @override
  String get fieldWarningSound => 'Sonido de aviso';

  @override
  String get validationRequired => 'Campo obligatorio';

  @override
  String get validationPositiveInt => 'Use un valor > 0';

  @override
  String get validationNonNegativeInt => 'Use un valor ≥ 0';

  @override
  String validationWarnWorkMax(int work) {
    return 'Como máximo la mitad del trabajo ($work seg)';
  }

  @override
  String validationWarnRestMax(int rest) {
    return 'Como máximo la mitad del descanso ($rest seg)';
  }

  @override
  String get mma => 'MMA';

  @override
  String get kickboxingAmateur => 'Kickboxing amateur';

  @override
  String get kickboxingClassic => 'Kickboxing clásico';

  @override
  String get notificationChannelName => 'Temporizador de boxeo';

  @override
  String get notificationChannelDescription =>
      'Estado del asalto mientras corre la sesión';

  @override
  String get notificationInitialTitle => 'Temporizador de boxeo';

  @override
  String get notificationInitialContent => 'Sesión no iniciada';

  @override
  String get defaultMatchName => 'Temporizador de boxeo';
}
