part of 'matches_bloc.dart';

@immutable
sealed class MatchesEvent {}

final class MatchesLoadingEvent extends MatchesEvent {}

final class MatchesReadyEvent extends MatchesEvent {
  final List<Match> matches;

  MatchesReadyEvent({required this.matches});
}

final class MatchesUpdateEvent extends MatchesEvent {
  final List<Match> matches;

  MatchesUpdateEvent({required this.matches});
}
