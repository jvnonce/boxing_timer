part of 'run_bloc.dart';

enum RunPhase { delay, work, rest }

@immutable
sealed class RunState {
  const RunState();
}

final class RunIdleState extends RunState {
  final int previewSeconds;
  final int roundsCount;

  const RunIdleState({required this.previewSeconds, required this.roundsCount});
}

final class RunRunningState extends RunState {
  final int roundIndex;
  final RunPhase phase;
  final int remainingSeconds;
  final int roundsCount;
  final bool isWarning;

  const RunRunningState({
    required this.roundIndex,
    required this.phase,
    required this.remainingSeconds,
    required this.roundsCount,
    required this.isWarning,
  });
}

final class RunPausedState extends RunState {
  final int roundIndex;
  final RunPhase phase;
  final int remainingSeconds;
  final int roundsCount;
  final bool isWarning;

  const RunPausedState({
    required this.roundIndex,
    required this.phase,
    required this.remainingSeconds,
    required this.roundsCount,
    required this.isWarning,
  });
}

final class RunFinishedState extends RunState {
  const RunFinishedState();
}

final class RunStoppedState extends RunState {
  const RunStoppedState();
}
