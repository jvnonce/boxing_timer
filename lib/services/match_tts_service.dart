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
      if (tts == null || _appliedLanguage == null) {
        return;
      }

      // Speak in the language of the selected TTS engine, not only UI locale.
      // Avoids Russian text through an English Samsung voice (garbled digits).
      final l10n = _l10nForSpeechLanguage(_appliedLanguage!);
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
    // Samsung/Android often treat 0.5 as very slow; keep near default.
    await tts.setSpeechRate(
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? 0.45 : 0.5,
    );
    await tts.awaitSpeakCompletion(false);

    final language = await _resolveLanguage(tts, locale);
    await tts.setLanguage(language);
    _appliedLanguage = language;

    await _applyVoice(tts, gender, language);
  }

  Future<String> _resolveLanguage(FlutterTts tts, Locale locale) async {
    for (final tag in _localeCandidates(locale)) {
      final available = await tts.isLanguageAvailable(tag);
      if (available != true) {
        continue;
      }

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final installed = await tts.isLanguageInstalled(tag);
          if (installed == false) {
            continue;
          }
        } catch (_) {
          // Older engines may not implement isLanguageInstalled.
        }
      }

      return tag;
    }

    return 'en-US';
  }

  Future<void> _applyVoice(
    FlutterTts tts,
    TtsVoiceGender gender,
    String language,
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

    final preferred = _pickVoice(voices, gender, language);
    if (preferred != null) {
      final voiceLocale = preferred['locale'] ?? language;
      final payload = <String, String>{
        'name': preferred['name'] ?? '',
        'locale': voiceLocale,
      };
      final identifier = preferred['identifier'];
      if (identifier != null && identifier.isNotEmpty) {
        payload['identifier'] = identifier;
      }
      await tts.setVoice(payload);
      // Samsung often resets language when setVoice is applied.
      await tts.setLanguage(_normalizeLanguageTag(voiceLocale));
      _appliedLanguage = _normalizeLanguageTag(voiceLocale);
      await tts.setPitch(
        _voiceHasExplicitGender(preferred) ? 1.0 : _pitchFor(gender),
      );
      return;
    }

    await tts.setPitch(_pitchFor(gender));
  }

  /// Locale first, gender only within that locale. Never steal an en voice for ru text.
  Map<String, String>? _pickVoice(
    List<Map<String, String>> voices,
    TtsVoiceGender gender,
    String language,
  ) {
    final localeTags = _localeCandidatesForTag(language);
    final inLocale = voices
        .where(
          (voice) => localeTags.any(
            (tag) => _localeMatches(voice['locale'], tag),
          ),
        )
        .toList();

    if (inLocale.isEmpty) {
      return null;
    }

    final genderTest = switch (gender) {
      TtsVoiceGender.male => _looksMale,
      TtsVoiceGender.female => _looksFemale,
    };

    for (final voice in inLocale) {
      if (genderTest(voice)) {
        return voice;
      }
    }

    return inLocale.first;
  }

  bool _voiceHasExplicitGender(Map<String, String> voice) {
    return _looksMale(voice) || _looksFemale(voice);
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
    return name.contains('male') ||
        name.contains('#male') ||
        name.contains('-rum-') || // Google ru male network/local patterns
        name.contains('x-rum');
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
    return name.contains('female') ||
        name.contains('#female') ||
        name.contains('-ruf-') ||
        name.contains('x-ruf');
  }

  bool _localeMatches(String? voiceLocale, String tag) {
    if (voiceLocale == null || voiceLocale.isEmpty) {
      return false;
    }
    final normalized = _normalizeLanguageTag(voiceLocale).toLowerCase();
    final wanted = _normalizeLanguageTag(tag).toLowerCase();
    if (normalized == wanted) {
      return true;
    }
    final normalizedLang = normalized.split('-').first;
    final wantedLang = wanted.split('-').first;
    if (normalizedLang == wantedLang) {
      return true;
    }
    return normalized.startsWith('$wanted-') || wanted.startsWith('$normalized-');
  }

  String _normalizeLanguageTag(String tag) {
    return tag.replaceAll('_', '-');
  }

  List<String> _localeCandidates(Locale locale) {
    return _localeCandidatesForTag(_languageTag(locale));
  }

  List<String> _localeCandidatesForTag(String languageTag) {
    final normalized = _normalizeLanguageTag(languageTag);
    final parts = normalized.split('-');
    final language = parts.first.toLowerCase();
    final candidates = <String>[normalized];
    if (parts.length > 1) {
      candidates.add(language);
    }
    switch (language) {
      case 'ru':
        candidates.addAll(const ['ru-RU', 'ru']);
      case 'es':
        candidates.addAll(const ['es-ES', 'es-MX', 'es']);
      case 'en':
        candidates.addAll(const ['en-US', 'en-GB', 'en']);
    }
    return candidates.toSet().toList();
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

  AppLocalizations _l10nForSpeechLanguage(String languageTag) {
    final code = _normalizeLanguageTag(languageTag).split('-').first;
    try {
      return lookupAppLocalizations(Locale(code));
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}
