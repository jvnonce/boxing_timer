import 'dart:async';
import 'dart:math';

import 'package:boxing_timer/blocs/run/run_bloc.dart';
import 'package:boxing_timer/l10n/l10n.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/platform.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class RunPage extends StatelessWidget {
  const RunPage({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RunBloc(match: match),
      child: _RunView(match: match),
    );
  }
}

class _RunView extends StatefulWidget {
  const _RunView({required this.match});

  final Match match;

  @override
  State<_RunView> createState() => _RunViewState();
}

class _RunViewState extends State<_RunView> {
  bool get _wakelockSupported => isMobileNative;

  @override
  void dispose() {
    _setWakelock(enabled: false);
    super.dispose();
  }

  void _setWakelock({required bool enabled}) {
    if (!_wakelockSupported || !widget.match.keepScreenOn) {
      return;
    }

    if (enabled) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  void _syncWakelock(RunState state) {
    final keepAwake = state is RunRunningState || state is RunPausedState;
    _setWakelock(enabled: keepAwake);
  }

  Color _backgroundFor(RunState state) {
    if (state is RunIdleState) {
      return Colors.blue;
    }

    final (:phase, :isPaused, :isWarning) = switch (state) {
      RunRunningState(:final phase, :final isWarning) => (
        phase: phase,
        isPaused: false,
        isWarning: isWarning,
      ),
      RunPausedState(:final phase, :final isWarning) => (
        phase: phase,
        isPaused: true,
        isWarning: isWarning,
      ),
      _ => (phase: null as RunPhase?, isPaused: false, isWarning: false),
    };

    if (phase == null) {
      return Colors.blueAccent;
    }

    if (phase == RunPhase.delay) {
      return Colors.blueAccent;
    }

    if (isPaused) {
      return switch (phase) {
        RunPhase.work => Colors.green.shade900,
        RunPhase.rest => Colors.red.shade900,
        RunPhase.delay => Colors.blueAccent,
      };
    }

    return switch (phase) {
      RunPhase.work =>
        isWarning ? Colors.green.shade900 : Colors.green.shade800,
      RunPhase.rest => isWarning ? Colors.red.shade900 : Colors.red.shade800,
      RunPhase.delay => Colors.blueAccent,
    };
  }

  String _timeLabel(BuildContext context, RunPhase phase, int seconds) {
    final time = seconds.timeMinSecs;
    return switch (phase) {
      RunPhase.delay => time,
      RunPhase.work => context.l10n.workTime(time),
      RunPhase.rest => context.l10n.restTime(time),
    };
  }

  void _leave(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RunBloc, RunState>(
      listenWhen: (previous, current) =>
          current is RunStoppedState ||
          current is RunFinishedState ||
          current is RunRunningState ||
          current is RunPausedState ||
          current is RunIdleState,
      listener: (context, state) {
        _syncWakelock(state);
        if (state is RunStoppedState || state is RunFinishedState) {
          _leave(context);
        }
      },
      builder: (context, state) {
        final canLeaveFreely = state is RunIdleState;
        final background = _backgroundFor(state);
        final textColor = background.contrastingXor;

        return PopScope(
          canPop: canLeaveFreely,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              context.read<RunBloc>().add(const RunStopEvent());
            }
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget.match.name),
              actions: const [SizedBox(width: kToolbarHeight)],
            ),
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(color: background),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = min(
                      constraints.maxHeight,
                      constraints.maxWidth,
                    );
                    return SizedBox.square(
                      dimension: size,
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          _Controls(state: state, size: size),
                          const SizedBox(height: 16),
                          _TimerLabel(
                            state: state,
                            timeLabel: _timeLabel,
                            textColor: textColor,
                          ),
                          const SizedBox(height: 12),
                          _PhaseSkipControls(
                            state: state,
                            backgroundColor: textColor,
                            foregroundColor: _backgroundFor(state),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.size});

  final RunState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconSize = size / 3;

    return switch (state) {
      RunIdleState() => Row(
        mainAxisAlignment: .center,
        children: [
          IconButton(
            icon: Icon(Icons.play_circle, size: size / 2),
            tooltip: context.l10n.start,
            onPressed: () => context.read<RunBloc>().add(const RunStartEvent()),
          ),
        ],
      ),
      RunRunningState() => Row(
        mainAxisAlignment: .center,
        children: [
          IconButton(
            icon: Icon(Icons.pause_circle, size: iconSize),
            tooltip: context.l10n.pause,
            onPressed: () => context.read<RunBloc>().add(const RunPauseEvent()),
          ),
        ],
      ),
      RunPausedState() => Row(
        mainAxisAlignment: .center,
        children: [
          IconButton(
            icon: Icon(Icons.play_circle, size: iconSize),
            tooltip: context.l10n.start,
            onPressed: () =>
                context.read<RunBloc>().add(const RunResumeEvent()),
          ),
          IconButton(
            icon: Icon(Icons.stop_circle, size: iconSize),
            tooltip: context.l10n.stop,
            onPressed: () => context.read<RunBloc>().add(const RunStopEvent()),
          ),
        ],
      ),
      RunFinishedState() || RunStoppedState() => const SizedBox.shrink(),
    };
  }
}

class _TimerLabel extends StatelessWidget {
  const _TimerLabel({
    required this.state,
    required this.timeLabel,
    required this.textColor,
  });

  final RunState state;
  final String Function(BuildContext, RunPhase, int) timeLabel;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 48, color: textColor);

    return switch (state) {
      RunIdleState(:final previewSeconds) => Text(
        previewSeconds.timeMinSecs,
        style: style,
      ),
      RunRunningState(
        :final phase,
        :final remainingSeconds,
        :final roundIndex,
        :final roundsCount,
      ) ||
      RunPausedState(
        :final phase,
        :final remainingSeconds,
        :final roundIndex,
        :final roundsCount,
      ) => Column(
        children: [
          if (phase != RunPhase.delay)
            Text(
              context.l10n.round(roundIndex + 1, roundsCount),
              style: style.copyWith(fontSize: 24),
            ),
          Text(timeLabel(context, phase, remainingSeconds), style: style),
        ],
      ),
      RunFinishedState() || RunStoppedState() => const SizedBox.shrink(),
    };
  }
}

class _PhaseSkipControls extends StatelessWidget {
  const _PhaseSkipControls({
    required this.state,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final RunState state;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final phase = switch (state) {
      RunRunningState(:final phase) => phase,
      RunPausedState(:final phase) => phase,
      _ => null,
    };

    if (phase == null || phase == RunPhase.delay) {
      return const SizedBox.shrink();
    }

    final bloc = context.read<RunBloc>();

    final style = ButtonStyle(
      backgroundColor: WidgetStateColor.resolveWith(
        (states) => backgroundColor,
      ),
      foregroundColor: WidgetStateColor.resolveWith(
        (states) => foregroundColor,
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (phase == RunPhase.work)
          TextButton.icon(
            onPressed: () => bloc.add(const RunForceRestEvent()),
            icon: const Icon(Icons.navigate_next),
            label: Text(context.l10n.skipToRest),
            style: style,
          ),
        if (phase == RunPhase.work)
          TextButton.icon(
            onPressed: () => bloc.add(const RunForceNextRoundEvent()),
            icon: const Icon(Icons.skip_next),
            label: Text(context.l10n.skipToNextRound),
            style: style,
          ),
        if (phase == RunPhase.rest)
          TextButton.icon(
            onPressed: () => bloc.add(const RunForceNextRoundEvent()),
            icon: const Icon(Icons.skip_next),
            label: Text(context.l10n.skipToNextRound),
            style: style,
          ),
      ],
    );
  }
}
