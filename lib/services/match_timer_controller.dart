import 'dart:async';
import 'dart:isolate';

import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/services/match_background_service.dart';
import 'package:boxing_timer/services/match_run_engine.dart';
import 'package:boxing_timer/services/match_timer_runner.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

enum MatchTimerHostKind { foregroundService, isolate, main }

/// UI-side facade: starts the runner host and relays commands / state / cues.
class MatchTimerController {
  MatchTimerController();

  final _stateController = StreamController<MatchRunSnapshot>.broadcast();
  final _cueController =
      StreamController<({MatchCue cue, Match match})>.broadcast();

  Stream<MatchRunSnapshot> get states => _stateController.stream;
  Stream<({MatchCue cue, Match match})> get cues => _cueController.stream;

  MatchTimerHostKind? _kind;
  MatchTimerRunner? _mainRunner;
  MatchTimerCuePlayer? _mainCuePlayer;
  Isolate? _isolate;
  ReceivePort? _isolateReceivePort;
  SendPort? _isolateCommandPort;
  StreamSubscription<Map<String, dynamic>?>? _serviceStateSub;
  bool _started = false;

  MatchTimerHostKind? get hostKind => _kind;
  bool get isStarted => _started;

  Future<void> start(Match match) async {
    await stop();
    _started = true;

    if (isMobileNative && await MatchBackgroundService.ensureReadyForMatch()) {
      _kind = MatchTimerHostKind.foregroundService;
      await _startForegroundService(match);
      return;
    }

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      _kind = MatchTimerHostKind.isolate;
      await _startIsolate(match);
      return;
    }

    _kind = MatchTimerHostKind.main;
    _startMain(match);
  }

  Future<void> pause() async {
    _mainCuePlayer?.cancelRoundStart();
    await _command(MatchTimerCommands.pause);
  }

  Future<void> resume() => _command(MatchTimerCommands.resume);

  Future<void> forceRest() async {
    _mainCuePlayer?.cancelRoundStart();
    await _command(MatchTimerCommands.forceRest);
  }

  Future<void> forceNextRound() async {
    _mainCuePlayer?.cancelRoundStart();
    await _command(MatchTimerCommands.forceNextRound);
  }

  Future<void> stop() async {
    if (!_started && _kind == null) {
      return;
    }

    _mainCuePlayer?.cancelRoundStart();
    try {
      await _command(MatchTimerCommands.stop);
    } catch (_) {}

    await _tearDownHost();
    _started = false;
  }

  Future<void> dispose() async {
    await stop();
    await _stateController.close();
    await _cueController.close();
  }

  Future<void> _command(
    String command, [
    Map<String, dynamic>? payload,
  ]) async {
    switch (_kind) {
      case MatchTimerHostKind.foregroundService:
        final service = FlutterBackgroundService();
        service.invoke(command, payload);
      case MatchTimerHostKind.isolate:
        _isolateCommandPort?.send({
          'command': command,
          'payload': ?payload,
        });
      case MatchTimerHostKind.main:
        if (command == MatchTimerCommands.pause ||
            command == MatchTimerCommands.forceRest ||
            command == MatchTimerCommands.forceNextRound ||
            command == MatchTimerCommands.stop) {
          _mainCuePlayer?.cancelRoundStart();
        }
        _mainRunner?.handleCommand(command, payload);
      case null:
        break;
    }
  }

  void _startMain(Match match) {
    _mainCuePlayer = MatchTimerCuePlayer();
    _mainRunner = MatchTimerRunner(
      onState: _emitState,
      onCue: (cue, currentMatch) async {
        _cueController.add((cue: cue, match: currentMatch));
        await _mainCuePlayer?.play(cue, currentMatch);
      },
      onSessionEnded: () {},
    );
    _mainRunner!.handleCommand(MatchTimerCommands.start, {
      'match': match.toJson(),
    });
  }

  Future<void> _startIsolate(Match match) async {
    final receivePort = ReceivePort();
    _isolateReceivePort = receivePort;
    _isolate = await Isolate.spawn(matchTimerIsolateMain, receivePort.sendPort);

    final ready = Completer<SendPort>();
    _isolateReceivePort!.listen((message) {
      if (message is! Map) {
        return;
      }
      final map = Map<String, dynamic>.from(message);
      switch (map['type'] as String?) {
        case MatchTimerMessages.ready:
          final port = map['port'];
          if (port is SendPort && !ready.isCompleted) {
            ready.complete(port);
          }
        case MatchTimerMessages.state:
          final snapshotJson = map['snapshot'];
          if (snapshotJson is Map) {
            _emitState(
              MatchRunSnapshot.fromJson(
                Map<String, dynamic>.from(snapshotJson),
              ),
            );
          }
        case MatchTimerMessages.cue:
          final cueJson = map['cue'];
          final matchJson = map['match'];
          if (cueJson is Map && matchJson is Map) {
            final cue = MatchCue.fromJson(Map<String, dynamic>.from(cueJson));
            final cueMatch = Match.fromJson(
              Map<String, dynamic>.from(matchJson),
            );
            if (cueMatch != null) {
              _cueController.add((cue: cue, match: cueMatch));
              _mainCuePlayer ??= MatchTimerCuePlayer();
              if (cue.kind == MatchCueKind.stopped ||
                  cue.kind == MatchCueKind.finished ||
                  cue.kind == MatchCueKind.roundStart) {
                // pause/stop cancel is via command; roundStart plays below
              }
              if (cue.kind == MatchCueKind.stopped ||
                  cue.kind == MatchCueKind.finished) {
                _mainCuePlayer?.cancelRoundStart();
              }
              unawaited(_mainCuePlayer!.play(cue, cueMatch));
            }
          }
      }
    });

    _isolateCommandPort = await ready.future.timeout(
      const Duration(seconds: 5),
    );
    _mainCuePlayer = MatchTimerCuePlayer();
    _isolateCommandPort!.send({
      'command': MatchTimerCommands.start,
      'payload': {'match': match.toJson()},
    });
  }

  Future<void> _startForegroundService(Match match) async {
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      await service.startService();
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }

    _serviceStateSub = service.on(MatchTimerMessages.state).listen((event) {
      if (event == null) {
        return;
      }
      final snapshotJson = event['snapshot'];
      if (snapshotJson is Map) {
        _emitState(
          MatchRunSnapshot.fromJson(Map<String, dynamic>.from(snapshotJson)),
        );
      }
    });

    service.invoke(MatchTimerCommands.start, {'match': match.toJson()});
  }

  void _emitState(MatchRunSnapshot snapshot) {
    if (!_stateController.isClosed) {
      _stateController.add(snapshot);
    }
  }

  Future<void> _tearDownHost() async {
    await _serviceStateSub?.cancel();
    _serviceStateSub = null;

    if (_kind == MatchTimerHostKind.foregroundService) {
      MatchBackgroundService.stop();
    }

    _isolateCommandPort = null;
    _isolateReceivePort?.close();
    _isolateReceivePort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;

    _mainRunner?.dispose();
    _mainRunner = null;
    await _mainCuePlayer?.dispose();
    _mainCuePlayer = null;
    _kind = null;
  }
}
