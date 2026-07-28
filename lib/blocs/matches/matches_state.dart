part of 'matches_bloc.dart';

@immutable
sealed class MatchesState {}

final class MatchesLoadingState extends MatchesState {}

final class MatchesReadyState extends MatchesState {
  final List<Match> matches;

  MatchesReadyState({required this.matches});
}
