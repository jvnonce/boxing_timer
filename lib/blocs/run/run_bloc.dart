import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/services/match_audio_service.dart';
import 'package:boxing_timer/services/match_background_service.dart';
import 'package:flutter/foundation.dart';

part 'run_event.dart';
part 'run_state.dart';

class RunBloc extends Bloc<RunEvent, RunState> {
  RunBloc({required Match match})
    : _match = match,
      _audioService = MatchAudioService(),
      super(
        RunIdleState(
          previewSeconds: match.delay > 0
              ? match.delay
              : match.rounds.first.work,
        ),
      ) {
    on<RunStartEvent>(_onStart);
    on<RunPauseEvent>(_onPause);
    on<RunResumeEvent>(_onResume);
    on<RunStopEvent>(_onStop);
    on<RunTickEvent>(_onTick);
    on<RunForceRestEvent>(_onForceRest);
    on<RunForceNextRoundEvent>(_onForceNextRound);
  }

  final Match _match;
  final MatchAudioService _audioService;
  Timer? _ticker;
  String? _warningCueKey;

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const RunTickEvent());
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  bool _isWarning(RunPhase phase, int remainingSeconds) {
    return switch (phase) {
      RunPhase.work =>
        _match.warnWork != null && remainingSeconds <= _match.warnWork!,
      RunPhase.rest =>
        _match.warnRest != null && remainingSeconds <= _match.warnRest!,
      RunPhase.delay => false,
    };
  }

  RunRunningState _running({
    required int roundIndex,
    required RunPhase phase,
    required int remainingSeconds,
  }) {
    return RunRunningState(
      roundIndex: roundIndex,
      phase: phase,
      remainingSeconds: remainingSeconds,
      roundsCount: _match.roundsCount,
      isWarning: _isWarning(phase, remainingSeconds),
    );
  }

  String _phaseLabel(RunPhase phase) {
    return switch (phase) {
      RunPhase.delay => 'prepare',
      RunPhase.work => 'work',
      RunPhase.rest => 'rest',
    };
  }

  String _warningKey(int roundIndex, RunPhase phase) {
    return '$roundIndex:${phase.name}';
  }

  void _playRoundStartCue() {
    unawaited(_audioService.playRoundStart(_match.roundStartSoundAsset));
  }

  void _playRoundEndCue() {
    unawaited(_audioService.playRoundEnd(_match.roundEndSoundAsset));
  }

  void _playWarningCueIfNeeded(RunRunningState previous, RunRunningState next) {
    if (!next.isWarning || previous.isWarning) {
      return;
    }

    final key = _warningKey(next.roundIndex, next.phase);
    if (_warningCueKey == key) {
      return;
    }

    _warningCueKey = key;
    unawaited(_audioService.playWarning(_match.warningSoundAsset));
  }

  void _clearWarningCueForPhase(RunRunningState state) {
    final key = _warningKey(state.roundIndex, state.phase);
    if (_warningCueKey == key) {
      _warningCueKey = null;
    }
  }

  Future<void> _syncBackgroundService(
    RunState state, {
    required bool isPaused,
  }) async {
    if (state case RunRunningState(
      :final phase,
      :final remainingSeconds,
      :final roundIndex,
      :final roundsCount,
    )) {
      await MatchBackgroundService.showStatus(
        matchName: _match.name,
        phaseLabel: _phaseLabel(phase),
        remainingSeconds: remainingSeconds,
        roundIndex: roundIndex,
        roundsCount: roundsCount,
        isPaused: isPaused,
      );
      return;
    }

    if (state case RunPausedState(
      :final phase,
      :final remainingSeconds,
      :final roundIndex,
      :final roundsCount,
    )) {
      await MatchBackgroundService.showStatus(
        matchName: _match.name,
        phaseLabel: _phaseLabel(phase),
        remainingSeconds: remainingSeconds,
        roundIndex: roundIndex,
        roundsCount: roundsCount,
        isPaused: isPaused,
      );
    }
  }

  void _onStart(RunStartEvent event, Emitter<RunState> emit) {
    if (state is! RunIdleState) return;

    final delay = _match.delay;
    if (delay > 0) {
      emit(
        _running(
          roundIndex: 0,
          phase: RunPhase.delay,
          remainingSeconds: delay,
        ),
      );
    } else {
      emit(
        _running(
          roundIndex: 0,
          phase: RunPhase.work,
          remainingSeconds: _match.rounds.first.work,
        ),
      );
      _playRoundStartCue();
    }
    unawaited(_syncBackgroundService(state, isPaused: false));
    _startTicker();
  }

  void _onPause(RunPauseEvent event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunRunningState) return;

    _stopTicker();
    emit(
      RunPausedState(
        roundIndex: current.roundIndex,
        phase: current.phase,
        remainingSeconds: current.remainingSeconds,
        roundsCount: current.roundsCount,
        isWarning: current.isWarning,
      ),
    );
    unawaited(_syncBackgroundService(state, isPaused: true));
  }

  void _onResume(RunResumeEvent event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunPausedState) return;

    emit(
      _running(
        roundIndex: current.roundIndex,
        phase: current.phase,
        remainingSeconds: current.remainingSeconds,
      ),
    );
    unawaited(_syncBackgroundService(state, isPaused: false));
    _startTicker();
  }

  void _onStop(RunStopEvent event, Emitter<RunState> emit) {
    _stopTicker();
    MatchBackgroundService.stop();
    emit(const RunStoppedState());
  }

  void _onTick(RunTickEvent event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunRunningState) return;

    if (current.remainingSeconds > 1) {
      final nextState = _running(
        roundIndex: current.roundIndex,
        phase: current.phase,
        remainingSeconds: current.remainingSeconds - 1,
      );
      emit(
        nextState,
      );
      _playWarningCueIfNeeded(current, nextState);
      unawaited(_syncBackgroundService(state, isPaused: false));
      return;
    }

    _advancePhase(emit, current);
  }

  bool get _tickerActive => _ticker != null;

  RunPhase? _phaseOf(RunState state) {
    return switch (state) {
      RunRunningState(:final phase) => phase,
      RunPausedState(:final phase) => phase,
      _ => null,
    };
  }

  int? _roundIndexOf(RunState state) {
    return switch (state) {
      RunRunningState(:final roundIndex) => roundIndex,
      RunPausedState(:final roundIndex) => roundIndex,
      _ => null,
    };
  }

  void _emitRunningOrPaused(
    Emitter<RunState> emit, {
    required int roundIndex,
    required RunPhase phase,
    required int remainingSeconds,
    required bool stayPaused,
  }) {
    final running = _running(
      roundIndex: roundIndex,
      phase: phase,
      remainingSeconds: remainingSeconds,
    );
    if (stayPaused) {
      emit(
        RunPausedState(
          roundIndex: running.roundIndex,
          phase: running.phase,
          remainingSeconds: running.remainingSeconds,
          roundsCount: running.roundsCount,
          isWarning: running.isWarning,
        ),
      );
    } else {
      emit(running);
    }
  }

  void _completeWorkPhase(Emitter<RunState> emit, {required bool stayPaused}) {
    final roundIndex = _roundIndexOf(state);
    if (roundIndex == null) {
      return;
    }

    _warningCueKey = null;
    _playRoundEndCue();

    final isLastRound = roundIndex >= _match.roundsCount - 1;
    if (isLastRound) {
      _stopTicker();
      MatchBackgroundService.stop();
      emit(const RunFinishedState());
      return;
    }

    final rest = _match.rounds[roundIndex].rest;
    if (rest <= 0) {
      final nextRound = roundIndex + 1;
      _emitRunningOrPaused(
        emit,
        roundIndex: nextRound,
        phase: RunPhase.work,
        remainingSeconds: _match.rounds[nextRound].work,
        stayPaused: stayPaused,
      );
      _playRoundStartCue();
    } else {
      _emitRunningOrPaused(
        emit,
        roundIndex: roundIndex,
        phase: RunPhase.rest,
        remainingSeconds: rest,
        stayPaused: stayPaused,
      );
    }
    unawaited(_syncBackgroundService(state, isPaused: stayPaused));
    if (!stayPaused && !_tickerActive) {
      _startTicker();
    }
  }

  void _startNextRoundWork(Emitter<RunState> emit, {required bool stayPaused}) {
    final roundIndex = _roundIndexOf(state);
    if (roundIndex == null) {
      return;
    }

    _warningCueKey = null;

    final isLastRound = roundIndex >= _match.roundsCount - 1;
    if (isLastRound) {
      _stopTicker();
      MatchBackgroundService.stop();
      emit(const RunFinishedState());
      return;
    }

    final nextRound = roundIndex + 1;
    _emitRunningOrPaused(
      emit,
      roundIndex: nextRound,
      phase: RunPhase.work,
      remainingSeconds: _match.rounds[nextRound].work,
      stayPaused: stayPaused,
    );
    _playRoundStartCue();
    unawaited(_syncBackgroundService(state, isPaused: stayPaused));
    if (!stayPaused && !_tickerActive) {
      _startTicker();
    }
  }

  void _onForceRest(RunForceRestEvent event, Emitter<RunState> emit) {
    if (_phaseOf(state) != RunPhase.work) {
      return;
    }

    final stayPaused = state is RunPausedState;
    if (!stayPaused) {
      _stopTicker();
    }
    _completeWorkPhase(emit, stayPaused: stayPaused);
  }

  void _onForceNextRound(RunForceNextRoundEvent event, Emitter<RunState> emit) {
    final phase = _phaseOf(state);
    if (phase != RunPhase.work && phase != RunPhase.rest) {
      return;
    }

    final stayPaused = state is RunPausedState;
    if (!stayPaused) {
      _stopTicker();
    }

    if (phase == RunPhase.work) {
      _playRoundEndCue();
      _startNextRoundWork(emit, stayPaused: stayPaused);
      return;
    }

    _startNextRoundWork(emit, stayPaused: stayPaused);
  }

  void _advancePhase(Emitter<RunState> emit, RunRunningState current) {
    switch (current.phase) {
      case RunPhase.delay:
        _warningCueKey = null;
        emit(
          _running(
            roundIndex: 0,
            phase: RunPhase.work,
            remainingSeconds: _match.rounds.first.work,
          ),
        );
        _playRoundStartCue();
        unawaited(_syncBackgroundService(state, isPaused: false));
      case RunPhase.work:
        _clearWarningCueForPhase(current);
        _completeWorkPhase(emit, stayPaused: false);
      case RunPhase.rest:
        _clearWarningCueForPhase(current);
        _startNextRoundWork(emit, stayPaused: false);
    }
  }

  @override
  Future<void> close() async {
    _stopTicker();
    MatchBackgroundService.stop();
    await _audioService.dispose();
    return super.close();
  }
}
