import 'package:boxing_timer/l10n/l10n.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/models/round.dart';
import 'package:boxing_timer/models/tts_voice_gender.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/material.dart';

class MatchEditorPage extends StatefulWidget {
  const MatchEditorPage({super.key, this.initialMatch});

  final Match? initialMatch;

  static const List<String> imageAssets = <String>[
    'assets/svg/boxing-fighter.svg',
    'assets/svg/person-fight-punch.svg',
    'assets/svg/boxing-punch-bag.svg',
    'assets/svg/boxing-training.svg',
    'assets/svg/boxing-equipment.svg',
    'assets/svg/run-fast.svg',
    'assets/svg/run.svg',
    'assets/svg/training.svg',
    'assets/svg/weightlifter.svg',
    'assets/svg/weightlifting.svg',
    'assets/svg/kickboxing.svg',
    'assets/svg/kickboxing-high.svg',
    'assets/svg/fite.svg',
  ];

  static const List<String> soundAssets = <String>[
    'assets/sounds/boxing-bell-1.mp3',
    'assets/sounds/boxing-bell-2.mp3',
    'assets/sounds/warning-1.mp3',
    'assets/sounds/warning-3.mp3',
  ];

  @override
  State<MatchEditorPage> createState() => _MatchEditorPageState();
}

class _MatchEditorPageState extends State<MatchEditorPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roundsCountController;
  late final TextEditingController _workController;
  late final TextEditingController _restController;
  late final TextEditingController _delayController;
  late final TextEditingController _warnWorkController;
  late final TextEditingController _warnRestController;

  late String _imageAsset;
  late String _roundStartSoundAsset;
  late String _roundEndSoundAsset;
  late String _warningSoundAsset;
  late bool _keepScreenOn;
  late bool _announceRounds;
  late TtsVoiceGender _ttsVoiceGender;

  bool get _isEditing => widget.initialMatch != null;

  @override
  void initState() {
    super.initState();
    final match = widget.initialMatch;

    _nameController = TextEditingController(text: match?.name ?? '');
    _roundsCountController = TextEditingController(
      text: (match?.roundsCount ?? 3).toString(),
    );
    _workController = TextEditingController(
      text: (match?.defaultWork ?? 180).toString(),
    );
    _restController = TextEditingController(
      text: (match?.defaultRest ?? 60).toString(),
    );
    _delayController = TextEditingController(
      text: (match?.delay ?? 10).toString(),
    );
    _warnWorkController = TextEditingController(
      text: match?.warnWork?.toString() ?? '',
    );
    _warnRestController = TextEditingController(
      text: match?.warnRest?.toString() ?? '',
    );

    _imageAsset = match?.imageAsset ?? Match.defaultImageAsset;
    _roundStartSoundAsset =
        match?.roundStartSoundAsset ?? Match.defaultRoundSignalSound;
    _roundEndSoundAsset =
        match?.roundEndSoundAsset ?? Match.defaultRoundSignalSound;
    _warningSoundAsset = match?.warningSoundAsset ?? Match.defaultWarningSound;
    _keepScreenOn = match?.keepScreenOn ?? true;
    _announceRounds = match?.announceRounds ?? false;
    _ttsVoiceGender = match?.ttsVoiceGender ?? TtsVoiceGender.female;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roundsCountController.dispose();
    _workController.dispose();
    _restController.dispose();
    _delayController.dispose();
    _warnWorkController.dispose();
    _warnRestController.dispose();
    super.dispose();
  }

  int? _requiredPositiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  int? _nonNegativeInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      return null;
    }
    return parsed;
  }

  int? _optionalNonNegativeInt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return _nonNegativeInt(value.trim());
  }

  String? _requiredText(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validationRequired;
    }
    return null;
  }

  String? _requiredPositiveValidator(String? value, AppLocalizations l10n) {
    if (_requiredPositiveInt(value) == null) {
      return l10n.validationPositiveInt;
    }
    return null;
  }

  String? _nonNegativeValidator(String? value, AppLocalizations l10n) {
    if (_nonNegativeInt(value) == null) {
      return l10n.validationNonNegativeInt;
    }
    return null;
  }

  String? _warnWorkValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return l10n.validationNonNegativeInt;
    }
    final work = _requiredPositiveInt(_workController.text);
    if (work != null && parsed > work ~/ 2) {
      return l10n.validationWarnWorkMax(work);
    }
    return null;
  }

  String? _warnRestValidator(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return l10n.validationNonNegativeInt;
    }
    final rest = _nonNegativeInt(_restController.text);
    if (rest != null && parsed > rest ~/ 2) {
      return l10n.validationWarnRestMax(rest);
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final roundsCount = _requiredPositiveInt(_roundsCountController.text)!;
    final work = _requiredPositiveInt(_workController.text)!;
    final rest = _nonNegativeInt(_restController.text)!;
    final delay = _nonNegativeInt(_delayController.text)!;
    final warnWork = _optionalNonNegativeInt(_warnWorkController.text);
    final warnRest = _optionalNonNegativeInt(_warnRestController.text);

    final match = Match(
      name: _nameController.text.trim(),
      imageAsset: _imageAsset,
      defaultWork: work,
      defaultRest: rest,
      delay: delay,
      warnWork: warnWork,
      warnRest: warnRest,
      roundStartSoundAsset: _roundStartSoundAsset,
      roundEndSoundAsset: _roundEndSoundAsset,
      warningSoundAsset: _warningSoundAsset,
      keepScreenOn: _keepScreenOn,
      announceRounds: isTtsSupported && _announceRounds,
      ttsVoiceGender: _ttsVoiceGender,
      rounds: List<Round>.generate(
        roundsCount,
        (_) => Round(work: work, rest: rest),
      ),
    );

    Navigator.of(context).pop(match);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMatch : l10n.addMatch),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fieldName),
                validator: (value) => _requiredText(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roundsCountController,
                decoration: InputDecoration(labelText: l10n.fieldRoundsCount),
                keyboardType: TextInputType.number,
                validator: (value) => _requiredPositiveValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _workController,
                decoration: InputDecoration(labelText: l10n.fieldWorkSeconds),
                keyboardType: TextInputType.number,
                validator: (value) => _requiredPositiveValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _restController,
                decoration: InputDecoration(labelText: l10n.fieldRestSeconds),
                keyboardType: TextInputType.number,
                validator: (value) => _nonNegativeValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _delayController,
                decoration: InputDecoration(labelText: l10n.fieldDelaySeconds),
                keyboardType: TextInputType.number,
                validator: (value) => _nonNegativeValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warnWorkController,
                decoration: InputDecoration(
                  labelText: l10n.fieldWarnWorkOptional,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _warnWorkValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warnRestController,
                decoration: InputDecoration(
                  labelText: l10n.fieldWarnRestOptional,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => _warnRestValidator(value, l10n),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.keepScreenOn),
                value: _keepScreenOn,
                onChanged: (value) {
                  setState(() {
                    _keepScreenOn = value;
                  });
                },
              ),
              if (isTtsSupported) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.announceRounds),
                  value: _announceRounds,
                  onChanged: (value) {
                    setState(() {
                      _announceRounds = value;
                    });
                  },
                ),
                if (_announceRounds) ...[
                  const SizedBox(height: 4),
                  DropdownButtonFormField<TtsVoiceGender>(
                    initialValue: _ttsVoiceGender,
                    decoration: InputDecoration(labelText: l10n.ttsVoiceGender),
                    items: [
                      DropdownMenuItem(
                        value: TtsVoiceGender.female,
                        child: Text(l10n.ttsVoiceFemale),
                      ),
                      DropdownMenuItem(
                        value: TtsVoiceGender.male,
                        child: Text(l10n.ttsVoiceMale),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _ttsVoiceGender = value;
                      });
                    },
                  ),
                ],
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _imageAsset,
                decoration: InputDecoration(labelText: l10n.fieldImage),
                items: MatchEditorPage.imageAssets
                    .map(
                      (asset) => DropdownMenuItem<String>(
                        value: asset,
                        child: Text(asset.split('/').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _imageAsset = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _roundStartSoundAsset,
                decoration:
                    InputDecoration(labelText: l10n.fieldRoundStartSound),
                items: MatchEditorPage.soundAssets
                    .map(
                      (asset) => DropdownMenuItem<String>(
                        value: asset,
                        child: Text(asset.split('/').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _roundStartSoundAsset = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _roundEndSoundAsset,
                decoration: InputDecoration(labelText: l10n.fieldRoundEndSound),
                items: MatchEditorPage.soundAssets
                    .map(
                      (asset) => DropdownMenuItem<String>(
                        value: asset,
                        child: Text(asset.split('/').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _roundEndSoundAsset = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _warningSoundAsset,
                decoration: InputDecoration(labelText: l10n.fieldWarningSound),
                items: MatchEditorPage.soundAssets
                    .map(
                      (asset) => DropdownMenuItem<String>(
                        value: asset,
                        child: Text(asset.split('/').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _warningSoundAsset = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
