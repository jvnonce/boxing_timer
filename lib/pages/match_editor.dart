import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/models/round.dart';
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

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _requiredPositiveValidator(String? value) {
    if (_requiredPositiveInt(value) == null) {
      return 'Use a value > 0';
    }
    return null;
  }

  String? _nonNegativeValidator(String? value) {
    if (_nonNegativeInt(value) == null) {
      return 'Use a value >= 0';
    }
    return null;
  }

  String? _optionalNonNegativeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (_optionalNonNegativeInt(value) == null) {
      return 'Use a value >= 0';
    }
    return null;
  }

  String? _warnWorkValidator(String? value) {
    final base = _optionalNonNegativeValidator(value);
    if (base != null) {
      return base;
    }
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final warn = int.tryParse(value.trim());
    final work = _requiredPositiveInt(_workController.text);
    if (warn != null && work != null && warn > work ~/ 2) {
      return 'At most half of work seconds ($work)';
    }
    return null;
  }

  String? _warnRestValidator(String? value) {
    final base = _optionalNonNegativeValidator(value);
    if (base != null) {
      return base;
    }
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final warn = int.tryParse(value.trim());
    final rest = _nonNegativeInt(_restController.text);
    if (warn != null && rest != null && warn > rest ~/ 2) {
      return 'At most half of rest seconds ($rest)';
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
      rounds: List<Round>.generate(
        roundsCount,
        (_) => Round(work: work, rest: rest),
      ),
    );

    Navigator.of(context).pop(match);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit match' : 'Add match'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roundsCountController,
                decoration: const InputDecoration(labelText: 'Rounds count'),
                keyboardType: TextInputType.number,
                validator: _requiredPositiveValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _workController,
                decoration: const InputDecoration(labelText: 'Work seconds'),
                keyboardType: TextInputType.number,
                validator: _requiredPositiveValidator,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _restController,
                decoration: const InputDecoration(labelText: 'Rest seconds'),
                keyboardType: TextInputType.number,
                validator: _nonNegativeValidator,
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _delayController,
                decoration: const InputDecoration(labelText: 'Start delay seconds'),
                keyboardType: TextInputType.number,
                validator: _nonNegativeValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warnWorkController,
                decoration: const InputDecoration(labelText: 'Warn work seconds'),
                keyboardType: TextInputType.number,
                validator: _warnWorkValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warnRestController,
                decoration: const InputDecoration(labelText: 'Warn rest seconds'),
                keyboardType: TextInputType.number,
                validator: _warnRestValidator,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Keep screen on during match'),
                value: _keepScreenOn,
                onChanged: (value) {
                  setState(() {
                    _keepScreenOn = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _imageAsset,
                decoration: const InputDecoration(labelText: 'Image'),
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
                decoration: const InputDecoration(labelText: 'Round start sound'),
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
                decoration: const InputDecoration(labelText: 'Round end sound'),
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
                decoration: const InputDecoration(labelText: 'Warning sound'),
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
