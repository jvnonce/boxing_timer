import 'package:boxing_timer/models/round.dart';

class Match {
  static const String defaultImageAsset = 'assets/svg/boxing-fighter.svg';
  static const String defaultRoundSignalSound = 'assets/sounds/boxing-bell-1.mp3';
  static const String defaultWarningSound = 'assets/sounds/warning-1.mp3';

  final String name;
  final String imageAsset;
  final int defaultWork;
  final int defaultRest;
  final int delay;
  final int? warnWork;
  final int? warnRest;
  final List<Round> rounds;
  final String roundStartSoundAsset;
  final String roundEndSoundAsset;
  final String warningSoundAsset;
  final bool keepScreenOn;

  Match({
    required this.name,
    this.imageAsset = defaultImageAsset,
    required this.defaultWork,
    required this.defaultRest,
    required this.delay,
    this.warnWork,
    this.warnRest,
    this.roundStartSoundAsset = defaultRoundSignalSound,
    this.roundEndSoundAsset = defaultRoundSignalSound,
    this.warningSoundAsset = defaultWarningSound,
    this.keepScreenOn = true,
    required this.rounds,
  });

  int get roundsCount => rounds.length;

  int get restCount => rounds.length - 1 < 0 ? 0 : rounds.length - 1;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageAsset': imageAsset,
      'defaultWork': defaultWork,
      'defaultRest': defaultRest,
      'delay': delay,
      'warnWork': warnWork,
      'warnRest': warnRest,
      'roundStartSoundAsset': roundStartSoundAsset,
      'roundEndSoundAsset': roundEndSoundAsset,
      'warningSoundAsset': warningSoundAsset,
      'keepScreenOn': keepScreenOn,
      'rounds': rounds.map((e) => e.toJson()).toList(),
    };
  }

  static Match? fromJson(Map<String, dynamic> map) {
    try {
      final roundsRaw = map['rounds'];
      if (roundsRaw is! List) {
        throw Exception();
      }

      final rounds = roundsRaw
          .map(
            (e) => Round.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .nonNulls
          .toList();
      if (rounds.isEmpty) {
        throw Exception();
      }

      return Match(
        name: map['name'] as String,
        imageAsset: map['imageAsset'] as String? ?? defaultImageAsset,
        defaultWork: _intFromJson(map['defaultWork']),
        defaultRest: _intFromJson(map['defaultRest']),
        delay: _intFromJson(map['delay']),
        warnWork: _optionalIntFromJson(map['warnWork']),
        warnRest: _optionalIntFromJson(map['warnRest']),
        roundStartSoundAsset:
            map['roundStartSoundAsset'] as String? ?? defaultRoundSignalSound,
        roundEndSoundAsset:
            map['roundEndSoundAsset'] as String? ?? defaultRoundSignalSound,
        warningSoundAsset:
            map['warningSoundAsset'] as String? ?? defaultWarningSound,
        keepScreenOn: map['keepScreenOn'] as bool? ?? true,
        rounds: rounds,
      );
    } catch (_) {
      return null;
    }
  }

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('Expected int, got $value');
  }

  static int? _optionalIntFromJson(Object? value) {
    if (value == null) {
      return null;
    }
    return _intFromJson(value);
  }

  static Match classicBoxing() {
    return Match(
      name: 'Classic boxing',
      imageAsset: 'assets/svg/boxing-fighter.svg',
      defaultWork: 180,
      defaultRest: 60,
      delay: 10,
      warnRest: 10,
      warnWork: 10,
      rounds: List.filled(12, Round(work: 180, rest: 60)),
    );
  }

  static Match amateurBoxing() {
    return Match(
      name: 'Amateur boxing',
      imageAsset: 'assets/svg/boxing-training.svg',
      defaultWork: 120,
      defaultRest: 60,
      delay: 10,
      warnRest: 10,
      warnWork: 10,
      rounds: List.filled(4, Round(work: 120, rest: 60)),
    );
  }

  static Match mma() {
    return Match(
      name: 'MMA',
      imageAsset: 'assets/svg/person-fight-punch.svg',
      defaultWork: 300,
      defaultRest: 60,
      delay: 10,
      warnRest: 10,
      warnWork: 10,
      rounds: List.filled(4, Round(work: 300, rest: 60)),
    );
  }

  static Match kickboxingAmateur() {
    return Match(
      name: 'Kickboxing amateur',
      imageAsset: 'assets/svg/kickboxing.svg',
      defaultWork: 120,
      defaultRest: 60,
      delay: 10,
      warnRest: 10,
      warnWork: 10,
      rounds: List.filled(3, Round(work: 120, rest: 60)),
    );
  }

  static Match kickboxingClassic() {
    return Match(
      name: 'Kickboxing classic',
      imageAsset: 'assets/svg/kickboxing-high.svg',
      defaultWork: 180,
      defaultRest: 60,
      delay: 10,
      warnRest: 10,
      warnWork: 10,
      rounds: List.filled(3, Round(work: 180, rest: 60)),
    );
  }

  static List<Match> defaultPresets() {
    return <Match>[classicBoxing(), amateurBoxing(), mma(), kickboxingAmateur(), kickboxingClassic()];
  }
}
