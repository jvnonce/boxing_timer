import 'dart:ui';

import 'package:boxing_timer/l10n/app_localizations.dart';
import 'package:boxing_timer/models/tts_voice_gender.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MatchTtsService {
  FlutterTts? _tts;
  Future<void>? _initFuture;
  TtsVoiceGender? _targetGender;
  String? _appliedLanguage;

  Future<void> announceRound({
    required int roundNumber,
    required bool isLast,
    required TtsVoiceGender gender,
  }) async {
    if (!isTtsSupported) {
      return;
    }

    try {
      await _ensureReady(gender);
      final tts = _tts;
      if (tts == null) {
        return;
      }

      final l10n = _lookupL10n();
      final text = isLast
          ? l10n.ttsLastRound(roundNumber)
          : l10n.ttsRound(roundNumber);
      await tts.stop();
      await tts.speak(text);
    } catch (error) {
      debugPrint('MatchTtsService.announceRound failed: $error');
    }
  }

  Future<void> stop() async {
    if (!isTtsSupported) {
      return;
    }

    try {
      await _tts?.stop();
    } catch (error) {
      debugPrint('MatchTtsService.stop failed: $error');
    }
  }

  Future<void> dispose() async {
    await stop();
    _tts = null;
    _initFuture = null;
    _targetGender = null;
    _appliedLanguage = null;
  }

  Future<void> _ensureReady(TtsVoiceGender gender) {
    final existing = _initFuture;
    if (existing != null && _targetGender == gender) {
      return existing;
    }

    _targetGender = gender;
    _initFuture = _initialize(gender);
    return _initFuture!;
  }

  Future<void> _initialize(TtsVoiceGender gender) async {
    final tts = _tts ?? FlutterTts();
    _tts = tts;

    final locale = PlatformDispatcher.instance.locale;
    final language = _languageTag(locale);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await tts.setSharedInstance(true);
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }

    await tts.setVolume(1.0);
    await tts.setSpeechRate(0.5);
    await tts.awaitSpeakCompletion(false);

    final languageAvailable = await tts.isLanguageAvailable(language);
    if (languageAvailable == true) {
      await tts.setLanguage(language);
      _appliedLanguage = language;
    } else {
      const fallback = 'en-US';
      await tts.setLanguage(fallback);
      _appliedLanguage = fallback;
    }

    await _applyVoice(tts, gender, locale);
  }

  Future<void> _applyVoice(
    FlutterTts tts,
    TtsVoiceGender gender,
    Locale locale,
  ) async {
    final voicesRaw = await tts.getVoices;
    if (voicesRaw is! List) {
      await tts.setPitch(_pitchFor(gender));
      return;
    }

    final voices = voicesRaw
        .whereType<Map>()
        .map(
          (voice) => voice.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        )
        .toList();

    final preferred = _pickVoice(voices, gender, locale);
    if (preferred != null) {
      final payload = <String, String>{
        'name': preferred['name'] ?? '',
        'locale': preferred['locale'] ?? _appliedLanguage ?? 'en-US',
      };
      final identifier = preferred['identifier'];
      if (identifier != null && identifier.isNotEmpty) {
        payload['identifier'] = identifier;
      }
      await tts.setVoice(payload);
      await tts.setPitch(1.0);
      return;
    }

    await tts.setPitch(_pitchFor(gender));
  }

  Map<String, String>? _pickVoice(
    List<Map<String, String>> voices,
    TtsVoiceGender gender,
    Locale locale,
  ) {
    final localeTags = _localeCandidates(locale);

    Map<String, String>? firstWhere(
      bool Function(Map<String, String> voice) test,
    ) {
      for (final tag in localeTags) {
        for (final voice in voices) {
          if (_localeMatches(voice['locale'], tag) && test(voice)) {
            return voice;
          }
        }
      }
      for (final voice in voices) {
        if (test(voice)) {
          return voice;
        }
      }
      return null;
    }

    return switch (gender) {
      TtsVoiceGender.male => firstWhere(_looksMale),
      TtsVoiceGender.female => firstWhere(_looksFemale),
    };
  }

  bool _looksMale(Map<String, String> voice) {
    final gender = (voice['gender'] ?? '').toLowerCase();
    if (gender.contains('female')) {
      return false;
    }
    if (gender.contains('male')) {
      return true;
    }

    final name = (voice['name'] ?? '').toLowerCase();
    if (name.contains('female')) {
      return false;
    }
    return name.contains('male') || name.contains('#male');
  }

  bool _looksFemale(Map<String, String> voice) {
    final gender = (voice['gender'] ?? '').toLowerCase();
    if (gender.contains('female')) {
      return true;
    }
    if (gender.contains('male')) {
      return false;
    }

    final name = (voice['name'] ?? '').toLowerCase();
    return name.contains('female') || name.contains('#female');
  }

  bool _localeMatches(String? voiceLocale, String tag) {
    if (voiceLocale == null || voiceLocale.isEmpty) {
      return false;
    }
    final normalized = voiceLocale.replaceAll('_', '-').toLowerCase();
    final wanted = tag.replaceAll('_', '-').toLowerCase();
    return normalized == wanted || normalized.startsWith('$wanted-');
  }

  List<String> _localeCandidates(Locale locale) {
    final language = locale.languageCode;
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) {
      return <String>['$language-$country', language];
    }
    return switch (language) {
      'ru' => <String>['ru-RU', 'ru'],
      'es' => <String>['es-ES', 'es'],
      'en' => <String>['en-US', 'en-GB', 'en'],
      _ => <String>[language, 'en-US'],
    };
  }

  String _languageTag(Locale locale) {
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) {
      return '${locale.languageCode}-$country';
    }
    return switch (locale.languageCode) {
      'ru' => 'ru-RU',
      'es' => 'es-ES',
      'en' => 'en-US',
      _ => 'en-US',
    };
  }

  double _pitchFor(TtsVoiceGender gender) {
    return switch (gender) {
      TtsVoiceGender.male => 0.85,
      TtsVoiceGender.female => 1.1,
    };
  }

  AppLocalizations _lookupL10n() {
    try {
      return lookupAppLocalizations(PlatformDispatcher.instance.locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}
