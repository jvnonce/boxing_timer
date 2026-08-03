import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:boxing_timer/l10n/app_localizations.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/services/match_audio_service.dart';
import 'package:boxing_timer/services/match_run_engine.dart';
import 'package:boxing_timer/services/match_tts_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

/// Command names shared by UI <-> runner hosts.
abstract final class MatchTimerCommands {
  static const start = 'start';
  static const pause = 'pause';
  static const resume = 'resume';
  static const stop = 'stop';
  static const forceRest = 'force_rest';
  static const forceNextRound = 'force_next_round';
}

abstract final class MatchTimerMessages {
  static const state = 'match_state';
  static const cue = 'match_cue';
  static const ready = 'match_ready';
}

/// Owns [MatchRunEngine] + 1s wall-clock ticker.
class MatchTimerRunner {
  MatchTimerRunner({
    required this.onState,
    required this.onCue,
    this.onSessionEnded,
  });

  final void Function(MatchRunSnapshot snapshot) onState;
  final Future<void> Function(MatchCue cue, Match match) onCue;
  final VoidCallback? onSessionEnded;

  MatchRunEngine? _engine;
  Timer? _ticker;

  Match? get match => _engine?.match;

  void handleCommand(String command, [Map<String, dynamic>? payload]) {
    final now = DateTime.now();
    switch (command) {
      case MatchTimerCommands.start:
        final matchJson = payload?['match'];
        if (matchJson is! Map) {
          return;
        }
        final match = Match.fromJson(Map<String, dynamic>.from(matchJson));
        if (match == null) {
          return;
        }
        _engine = MatchRunEngine(match);
        _applyStep(_engine!.start(now));
        _startTicker();
      case MatchTimerCommands.pause:
        final engine = _engine;
        if (engine == null) return;
        _applyStep(engine.pause(now));
        _stopTicker();
      case MatchTimerCommands.resume:
        final engine = _engine;
        if (engine == null) return;
        _applyStep(engine.resume(now));
        _startTicker();
      case MatchTimerCommands.stop:
        _handleStop(now);
      case MatchTimerCommands.forceRest:
        final engine = _engine;
        if (engine == null) return;
        _applyStep(engine.forceRest(now));
        _syncTicker(engine);
      case MatchTimerCommands.forceNextRound:
        final engine = _engine;
        if (engine == null) return;
        _applyStep(engine.forceNextRound(now));
        _syncTicker(engine);
    }
  }

  void dispose() {
    _stopTicker();
    _engine = null;
  }

  void _handleStop(DateTime now) {
    final engine = _engine;
    _stopTicker();
    if (engine != null) {
      _applyStep(engine.stop(now));
    }
    onSessionEnded?.call();
  }

  void _syncTicker(MatchRunEngine engine) {
    if (engine.isActive && !engine.snapshot().isPaused) {
      _startTicker();
    } else {
      _stopTicker();
      if (!engine.isActive) {
        onSessionEnded?.call();
      }
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final engine = _engine;
      if (engine == null) {
        return;
      }
      _applyStep(engine.tick(DateTime.now()));
      if (!engine.isActive) {
        _stopTicker();
        onSessionEnded?.call();
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _applyStep(MatchRunStep step) {
    onState(step.snapshot);
    final match = _engine?.match;
    if (match == null) {
      return;
    }
    for (final cue in step.cues) {
      unawaited(onCue(cue, match));
    }
  }
}

/// Plays cues with local plugin services (main isolate or FGS FlutterEngine).
class MatchTimerCuePlayer {
  MatchTimerCuePlayer()
    : _audio = MatchAudioService(),
      _tts = MatchTtsService();

  final MatchAudioService _audio;
  final MatchTtsService _tts;
  int _roundStartGeneration = 0;

  void cancelRoundStart() {
    _roundStartGeneration++;
    unawaited(_tts.stop());
  }

  Future<void> play(MatchCue cue, Match match) async {
    switch (cue.kind) {
      case MatchCueKind.roundStart:
        final generation = ++_roundStartGeneration;
        await _audio.playRoundStart(
          match.roundStartSoundAsset,
          waitForCompletion: match.announceRounds,
        );
        if (generation != _roundStartGeneration) {
          return;
        }
        if (!match.announceRounds || cue.roundIndex == null) {
          return;
        }
        await _tts.announceRound(
          roundNumber: cue.roundIndex! + 1,
          isLast: cue.isLast,
          gender: match.ttsVoiceGender,
        );
      case MatchCueKind.roundEnd:
        await _audio.playRoundEnd(match.roundEndSoundAsset);
      case MatchCueKind.warning:
        await _audio.playWarning(match.warningSoundAsset);
      case MatchCueKind.finished:
      case MatchCueKind.stopped:
        cancelRoundStart();
    }
  }

  Future<void> dispose() async {
    cancelRoundStart();
    await _tts.dispose();
    await _audio.dispose();
  }
}

String matchTimerFormatTime(int totalSeconds) {
  if (totalSeconds < 60) {
    return totalSeconds.toString();
  }
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String matchTimerNotificationContent(
  AppLocalizations l10n,
  MatchRunSnapshot snapshot,
) {
  final roundLabel = snapshot.roundsCount > 0
      ? l10n.round(snapshot.roundIndex + 1, snapshot.roundsCount)
      : l10n.run;
  final time = matchTimerFormatTime(snapshot.remainingSeconds);
  final phaseTimeLabel = switch (snapshot.phase) {
    MatchRunPhase.delay => l10n.prepareTime(time),
    MatchRunPhase.rest => l10n.restTime(time),
    MatchRunPhase.work => l10n.workTime(time),
  };
  final pausedLabel = snapshot.isPaused ? ' | ${l10n.pause}' : '';
  return '$roundLabel | $phaseTimeLabel$pausedLabel';
}

AppLocalizations matchTimerLookupL10n() {
  try {
    return lookupAppLocalizations(PlatformDispatcher.instance.locale);
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}

/// Desktop isolate bootstrap. Message is the main [SendPort].
@pragma('vm:entry-point')
void matchTimerIsolateMain(SendPort mainSendPort) {
  final commandPort = ReceivePort();
  mainSendPort.send({
    'type': MatchTimerMessages.ready,
    'port': commandPort.sendPort,
  });

  MatchTimerRunner? runner;

  void publishState(MatchRunSnapshot snapshot) {
    mainSendPort.send({
      'type': MatchTimerMessages.state,
      'snapshot': snapshot.toJson(),
    });
  }

  Future<void> publishCue(MatchCue cue, Match match) async {
    mainSendPort.send({
      'type': MatchTimerMessages.cue,
      'cue': cue.toJson(),
      'match': match.toJson(),
    });
  }

  commandPort.listen((message) {
    if (message is! Map) {
      return;
    }
    final map = Map<String, dynamic>.from(message);
    final command = map['command'] as String?;
    if (command == null) {
      return;
    }

    runner ??= MatchTimerRunner(
      onState: publishState,
      onCue: publishCue,
      onSessionEnded: () {},
    );

    final payload = map['payload'];
    runner!.handleCommand(
      command,
      payload is Map ? Map<String, dynamic>.from(payload) : null,
    );

    if (command == MatchTimerCommands.stop) {
      runner?.dispose();
      runner = null;
    }
  });
}

/// Mobile FGS entry — owns engine, audio, notification.
@pragma('vm:entry-point')
Future<bool> matchTimerIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void matchTimerServiceMain(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final cuePlayer = MatchTimerCuePlayer();
  Match? match;

  late final MatchTimerRunner runner;
  runner = MatchTimerRunner(
    onState: (snapshot) {
      service.invoke(MatchTimerMessages.state, {
        'snapshot': snapshot.toJson(),
        if (match != null) 'matchName': match!.name,
      });
      if (service is AndroidServiceInstance && match != null) {
        final l10n = matchTimerLookupL10n();
        unawaited(
          service.setForegroundNotificationInfo(
            title: match!.name,
            content: matchTimerNotificationContent(l10n, snapshot),
          ),
        );
      }
    },
    onCue: (cue, currentMatch) async {
      match = currentMatch;
      if (cue.kind == MatchCueKind.stopped ||
          cue.kind == MatchCueKind.finished) {
        cuePlayer.cancelRoundStart();
      }
      await cuePlayer.play(cue, currentMatch);
    },
    onSessionEnded: () {
      unawaited(() async {
        await cuePlayer.dispose();
        service.stopSelf();
      }());
    },
  );

  service.on(MatchTimerCommands.start).listen((event) {
    final payload = event == null ? null : Map<String, dynamic>.from(event);
    if (payload != null) {
      final matchJson = payload['match'];
      if (matchJson is Map) {
        match = Match.fromJson(Map<String, dynamic>.from(matchJson));
      }
    }
    runner.handleCommand(MatchTimerCommands.start, payload);
  });
  service.on(MatchTimerCommands.pause).listen((event) {
    cuePlayer.cancelRoundStart();
    runner.handleCommand(MatchTimerCommands.pause);
  });
  service.on(MatchTimerCommands.resume).listen((event) {
    runner.handleCommand(MatchTimerCommands.resume);
  });
  service.on(MatchTimerCommands.stop).listen((event) async {
    cuePlayer.cancelRoundStart();
    runner.handleCommand(MatchTimerCommands.stop);
    runner.dispose();
    await cuePlayer.dispose();
    service.stopSelf();
  });
  service.on(MatchTimerCommands.forceRest).listen((event) {
    cuePlayer.cancelRoundStart();
    runner.handleCommand(MatchTimerCommands.forceRest);
  });
  service.on(MatchTimerCommands.forceNextRound).listen((event) {
    cuePlayer.cancelRoundStart();
    runner.handleCommand(MatchTimerCommands.forceNextRound);
  });
}
