part of 'run_bloc.dart';

@immutable
sealed class RunEvent {
  const RunEvent();
}

final class RunStartEvent extends RunEvent {
  const RunStartEvent();
}

final class RunPauseEvent extends RunEvent {
  const RunPauseEvent();
}

final class RunResumeEvent extends RunEvent {
  const RunResumeEvent();
}

final class RunStopEvent extends RunEvent {
  const RunStopEvent();
}

final class RunTickEvent extends RunEvent {
  const RunTickEvent();
}

final class RunForceRestEvent extends RunEvent {
  const RunForceRestEvent();
}

final class RunForceNextRoundEvent extends RunEvent {
  const RunForceNextRoundEvent();
}
