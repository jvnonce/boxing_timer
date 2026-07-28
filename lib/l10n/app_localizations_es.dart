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
  String get skipToRest => 'Al descanso';

  @override
  String get skipToNextRound => 'Siguiente asalto';
}
