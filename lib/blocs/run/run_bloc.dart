import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/services/match_run_engine.dart';
import 'package:boxing_timer/services/match_timer_controller.dart';
import 'package:flutter/foundation.dart';

part 'run_event.dart';

part 'run_state.dart';

class RunBloc extends Bloc<RunEvent, RunState> {
  RunBloc({required Match match})
    : _match = match,
      _timer = MatchTimerController(),
      super(
        RunIdleState(
          previewSeconds: match.delay > 0
              ? match.delay
              : match.rounds.first.work,
          roundsCount: match.roundsCount,
        ),
      ) {
    on<RunStartEvent>(_onStart);
    on<RunPauseEvent>(_onPause);
    on<RunResumeEvent>(_onResume);
    on<RunStopEvent>(_onStop);
    on<RunForceRestEvent>(_onForceRest);
    on<RunForceNextRoundEvent>(_onForceNextRound);
    on<RunSnapshotEvent>(_onSnapshot);

    _stateSub = _timer.states.listen((snapshot) {
      add(RunSnapshotEvent(snapshot));
    });
  }

  final Match _match;
  final MatchTimerController _timer;
  StreamSubscription<MatchRunSnapshot>? _stateSub;

  Future<void> _onStart(RunStartEvent event, Emitter<RunState> emit) async {
    if (state is! RunIdleState) return;

    final delay = _match.delay;
    if (delay > 0) {
      emit(
        RunRunningState(
          roundIndex: 0,
          phase: RunPhase.delay,
          remainingSeconds: delay,
          roundsCount: _match.roundsCount,
          isWarning: false,
        ),
      );
    } else {
      emit(
        RunRunningState(
          roundIndex: 0,
          phase: RunPhase.work,
          remainingSeconds: _match.rounds.first.work,
          roundsCount: _match.roundsCount,
          isWarning: false,
        ),
      );
    }

    await _timer.start(_match);
  }

  Future<void> _onPause(RunPauseEvent event, Emitter<RunState> emit) async {
    if (state is! RunRunningState) return;
    await _timer.pause();
  }

  Future<void> _onResume(RunResumeEvent event, Emitter<RunState> emit) async {
    if (state is! RunPausedState) return;
    await _timer.resume();
  }

  Future<void> _onStop(RunStopEvent event, Emitter<RunState> emit) async {
    await _timer.stop();
    emit(const RunStoppedState());
  }

  Future<void> _onForceRest(
    RunForceRestEvent event,
    Emitter<RunState> emit,
  ) async {
    final phase = _phaseOf(state);
    if (phase != RunPhase.work) return;
    await _timer.forceRest();
  }

  Future<void> _onForceNextRound(
    RunForceNextRoundEvent event,
    Emitter<RunState> emit,
  ) async {
    final phase = _phaseOf(state);
    if (phase != RunPhase.work && phase != RunPhase.rest) return;
    await _timer.forceNextRound();
  }

  void _onSnapshot(RunSnapshotEvent event, Emitter<RunState> emit) {
    final snapshot = event.snapshot;

    if (snapshot.isStopped) {
      emit(const RunStoppedState());
      return;
    }
    if (snapshot.isFinished) {
      emit(const RunFinishedState());
      return;
    }

    final phase = _toRunPhase(snapshot.phase);
    if (snapshot.isPaused) {
      emit(
        RunPausedState(
          roundIndex: snapshot.roundIndex,
          phase: phase,
          remainingSeconds: snapshot.remainingSeconds,
          roundsCount: snapshot.roundsCount,
          isWarning: snapshot.isWarning,
        ),
      );
      return;
    }

    emit(
      RunRunningState(
        roundIndex: snapshot.roundIndex,
        phase: phase,
        remainingSeconds: snapshot.remainingSeconds,
        roundsCount: snapshot.roundsCount,
        isWarning: snapshot.isWarning,
      ),
    );
  }

  RunPhase _toRunPhase(MatchRunPhase phase) {
    return switch (phase) {
      MatchRunPhase.delay => RunPhase.delay,
      MatchRunPhase.work => RunPhase.work,
      MatchRunPhase.rest => RunPhase.rest,
    };
  }

  RunPhase? _phaseOf(RunState state) {
    return switch (state) {
      RunRunningState(:final phase) => phase,
      RunPausedState(:final phase) => phase,
      _ => null,
    };
  }

  @override
  Future<void> close() async {
    await _stateSub?.cancel();
    await _timer.dispose();
    return super.close();
  }
}
