import 'package:boxing_timer/models/match.dart';

enum MatchRunPhase { delay, work, rest }

enum MatchCueKind {
  roundStart,
  roundEnd,
  warning,
  finished,
  stopped,
}

class MatchCue {
  const MatchCue({
    required this.kind,
    this.roundIndex,
    this.isLast = false,
  });

  final MatchCueKind kind;
  final int? roundIndex;
  final bool isLast;

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'roundIndex': roundIndex,
      'isLast': isLast,
    };
  }

  static MatchCue fromJson(Map<String, dynamic> json) {
    return MatchCue(
      kind: MatchCueKind.values.byName(json['kind'] as String),
      roundIndex: json['roundIndex'] as int?,
      isLast: json['isLast'] as bool? ?? false,
    );
  }
}

class MatchRunSnapshot {
  const MatchRunSnapshot({
    required this.roundIndex,
    required this.phase,
    required this.remainingSeconds,
    required this.roundsCount,
    required this.isPaused,
    required this.isWarning,
    required this.isFinished,
    required this.isStopped,
  });

  final int roundIndex;
  final MatchRunPhase phase;
  final int remainingSeconds;
  final int roundsCount;
  final bool isPaused;
  final bool isWarning;
  final bool isFinished;
  final bool isStopped;

  String get phaseLabel => switch (phase) {
    MatchRunPhase.delay => 'prepare',
    MatchRunPhase.work => 'work',
    MatchRunPhase.rest => 'rest',
  };

  Map<String, dynamic> toJson() {
    return {
      'roundIndex': roundIndex,
      'phase': phase.name,
      'remainingSeconds': remainingSeconds,
      'roundsCount': roundsCount,
      'isPaused': isPaused,
      'isWarning': isWarning,
      'isFinished': isFinished,
      'isStopped': isStopped,
    };
  }

  static MatchRunSnapshot fromJson(Map<String, dynamic> json) {
    return MatchRunSnapshot(
      roundIndex: json['roundIndex'] as int? ?? 0,
      phase: MatchRunPhase.values.byName(json['phase'] as String? ?? 'work'),
      remainingSeconds: json['remainingSeconds'] as int? ?? 0,
      roundsCount: json['roundsCount'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? false,
      isWarning: json['isWarning'] as bool? ?? false,
      isFinished: json['isFinished'] as bool? ?? false,
      isStopped: json['isStopped'] as bool? ?? false,
    );
  }
}

class MatchRunStep {
  const MatchRunStep({required this.snapshot, this.cues = const <MatchCue>[]});

  final MatchRunSnapshot snapshot;
  final List<MatchCue> cues;
}

/// Pure wall-clock match phase engine (no Flutter plugins).
class MatchRunEngine {
  MatchRunEngine(this.match);

  final Match match;

  int _roundIndex = 0;
  MatchRunPhase _phase = MatchRunPhase.delay;
  DateTime? _phaseEndsAt;
  int? _pausedRemaining;
  bool _isPaused = false;
  bool _isFinished = false;
  bool _isStopped = false;
  bool _started = false;
  String? _warningCueKey;

  bool get isActive => _started && !_isFinished && !_isStopped;

  MatchRunSnapshot snapshot([DateTime? now]) {
    final clock = now ?? DateTime.now();
    return MatchRunSnapshot(
      roundIndex: _roundIndex,
      phase: _phase,
      remainingSeconds: _remainingSeconds(clock),
      roundsCount: match.roundsCount,
      isPaused: _isPaused,
      isWarning: _isWarning(_remainingSeconds(clock)),
      isFinished: _isFinished,
      isStopped: _isStopped,
    );
  }

  MatchRunStep start(DateTime now) {
    if (_started && isActive) {
      return MatchRunStep(snapshot: snapshot(now));
    }

    _started = true;
    _isFinished = false;
    _isStopped = false;
    _isPaused = false;
    _pausedRemaining = null;
    _warningCueKey = null;

    final cues = <MatchCue>[];
    if (match.delay > 0) {
      _enterPhase(
        MatchRunPhase.delay,
        roundIndex: 0,
        durationSeconds: match.delay,
        startAt: now,
      );
    } else {
      _enterPhase(
        MatchRunPhase.work,
        roundIndex: 0,
        durationSeconds: match.rounds.first.work,
        startAt: now,
      );
      cues.addAll(_roundStartCues(0));
    }

    return MatchRunStep(snapshot: snapshot(now), cues: cues);
  }

  MatchRunStep pause(DateTime now) {
    if (!isActive || _isPaused) {
      return MatchRunStep(snapshot: snapshot(now));
    }

    _pausedRemaining = _remainingSeconds(now);
    _phaseEndsAt = null;
    _isPaused = true;
    return MatchRunStep(snapshot: snapshot(now));
  }

  MatchRunStep resume(DateTime now) {
    if (!isActive || !_isPaused) {
      return MatchRunStep(snapshot: snapshot(now));
    }

    final remaining = _pausedRemaining ?? 0;
    _pausedRemaining = null;
    _isPaused = false;
    _phaseEndsAt = now.add(Duration(seconds: remaining));
    return MatchRunStep(snapshot: snapshot(now));
  }

  MatchRunStep stop(DateTime now) {
    _isStopped = true;
    _isPaused = false;
    _phaseEndsAt = null;
    _pausedRemaining = null;
    return MatchRunStep(
      snapshot: snapshot(now),
      cues: const [MatchCue(kind: MatchCueKind.stopped)],
    );
  }

  MatchRunStep forceRest(DateTime now) {
    if (!isActive || _phase != MatchRunPhase.work) {
      return MatchRunStep(snapshot: snapshot(now));
    }
    return _completeWorkPhase(now, stayPaused: _isPaused);
  }

  MatchRunStep forceNextRound(DateTime now) {
    if (!isActive) {
      return MatchRunStep(snapshot: snapshot(now));
    }
    if (_phase != MatchRunPhase.work && _phase != MatchRunPhase.rest) {
      return MatchRunStep(snapshot: snapshot(now));
    }

    final cues = <MatchCue>[];
    if (_phase == MatchRunPhase.work) {
      cues.add(const MatchCue(kind: MatchCueKind.roundEnd));
    }
    final step = _startNextRoundWork(now, stayPaused: _isPaused);
    return MatchRunStep(
      snapshot: step.snapshot,
      cues: [...cues, ...step.cues],
    );
  }

  MatchRunStep tick(DateTime now) {
    if (!isActive || _isPaused) {
      return MatchRunStep(snapshot: snapshot(now));
    }

    final cues = <MatchCue>[];

    while (_phaseEndsAt != null && !now.isBefore(_phaseEndsAt!)) {
      final endedAt = _phaseEndsAt!;
      final advance = _advancePhaseAt(endedAt);
      cues.addAll(advance.cues);
      if (_isFinished || _isStopped) {
        return MatchRunStep(snapshot: snapshot(now), cues: cues);
      }
    }

    final current = snapshot(now);
    if (current.isWarning) {
      final key = '$_roundIndex:${_phase.name}';
      if (_warningCueKey != key) {
        _warningCueKey = key;
        cues.add(const MatchCue(kind: MatchCueKind.warning));
      }
    }

    return MatchRunStep(snapshot: current, cues: cues);
  }

  int _remainingSeconds(DateTime now) {
    if (_isFinished || _isStopped) {
      return 0;
    }
    if (_isPaused) {
      return _pausedRemaining ?? 0;
    }
    final endsAt = _phaseEndsAt;
    if (endsAt == null) {
      return 0;
    }
    final seconds = endsAt.difference(now).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  bool _isWarning(int remainingSeconds) {
    return switch (_phase) {
      MatchRunPhase.work =>
        match.warnWork != null && remainingSeconds <= match.warnWork!,
      MatchRunPhase.rest =>
        match.warnRest != null && remainingSeconds <= match.warnRest!,
      MatchRunPhase.delay => false,
    };
  }

  void _enterPhase(
    MatchRunPhase phase, {
    required int roundIndex,
    required int durationSeconds,
    required DateTime startAt,
  }) {
    _phase = phase;
    _roundIndex = roundIndex;
    _warningCueKey = null;
    final safeDuration = durationSeconds < 0 ? 0 : durationSeconds;
    _phaseEndsAt = startAt.add(Duration(seconds: safeDuration));
    if (_isPaused) {
      _pausedRemaining = safeDuration;
      _phaseEndsAt = null;
    }
  }

  List<MatchCue> _roundStartCues(int roundIndex) {
    return [
      MatchCue(
        kind: MatchCueKind.roundStart,
        roundIndex: roundIndex,
        isLast: roundIndex >= match.roundsCount - 1,
      ),
    ];
  }

  MatchRunStep _advancePhaseAt(DateTime endedAt) {
    switch (_phase) {
      case MatchRunPhase.delay:
        final cues = <MatchCue>[];
        _enterPhase(
          MatchRunPhase.work,
          roundIndex: 0,
          durationSeconds: match.rounds.first.work,
          startAt: endedAt,
        );
        cues.addAll(_roundStartCues(0));
        return MatchRunStep(snapshot: snapshot(endedAt), cues: cues);
      case MatchRunPhase.work:
        return _completeWorkPhase(endedAt, stayPaused: false);
      case MatchRunPhase.rest:
        return _startNextRoundWork(endedAt, stayPaused: false);
    }
  }

  MatchRunStep _completeWorkPhase(DateTime at, {required bool stayPaused}) {
    final cues = <MatchCue>[const MatchCue(kind: MatchCueKind.roundEnd)];
    _warningCueKey = null;

    final isLastRound = _roundIndex >= match.roundsCount - 1;
    if (isLastRound) {
      _isFinished = true;
      _phaseEndsAt = null;
      _pausedRemaining = null;
      _isPaused = false;
      cues.add(const MatchCue(kind: MatchCueKind.finished));
      return MatchRunStep(snapshot: snapshot(at), cues: cues);
    }

    final rest = match.rounds[_roundIndex].rest;
    _isPaused = stayPaused;
    if (rest <= 0) {
      final next = _startNextRoundWork(at, stayPaused: stayPaused);
      return MatchRunStep(
        snapshot: next.snapshot,
        cues: [...cues, ...next.cues],
      );
    }

    _enterPhase(
      MatchRunPhase.rest,
      roundIndex: _roundIndex,
      durationSeconds: rest,
      startAt: at,
    );
    return MatchRunStep(snapshot: snapshot(at), cues: cues);
  }

  MatchRunStep _startNextRoundWork(DateTime at, {required bool stayPaused}) {
    _warningCueKey = null;
    final isLastRound = _roundIndex >= match.roundsCount - 1;
    if (isLastRound) {
      _isFinished = true;
      _phaseEndsAt = null;
      _pausedRemaining = null;
      _isPaused = false;
      return MatchRunStep(
        snapshot: snapshot(at),
        cues: const [MatchCue(kind: MatchCueKind.finished)],
      );
    }

    final nextRound = _roundIndex + 1;
    _isPaused = stayPaused;
    _enterPhase(
      MatchRunPhase.work,
      roundIndex: nextRound,
      durationSeconds: match.rounds[nextRound].work,
      startAt: at,
    );
    return MatchRunStep(
      snapshot: snapshot(at),
      cues: _roundStartCues(nextRound),
    );
  }
}
