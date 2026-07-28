import 'package:boxing_timer/blocs/matches/matches_bloc.dart';
import 'package:boxing_timer/l10n/l10n.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:boxing_timer/pages/match_editor.dart';
import 'package:boxing_timer/pages/run.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<Match?> _openEditor(BuildContext context, {Match? initialMatch}) {
    return Navigator.of(context).push<Match>(
      MaterialPageRoute<Match>(
        builder: (context) => MatchEditorPage(initialMatch: initialMatch),
      ),
    );
  }

  void _saveAddedMatch(BuildContext context, List<Match> matches, Match match) {
    context.read<MatchesBloc>().add(
      MatchesUpdateEvent(matches: [...matches, match]),
    );
  }

  void _saveEditedMatch(
    BuildContext context,
    List<Match> matches,
    int index,
    Match match,
  ) {
    final updatedMatches = [...matches];
    updatedMatches[index] = match;
    context.read<MatchesBloc>().add(
      MatchesUpdateEvent(matches: updatedMatches),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoadingState) {
          return Center(child: SizedBox.square(dimension: 200, child: CircularProgressIndicator()));
        }

        final matches = (state as MatchesReadyState).matches;

        return ListView.builder(
          itemCount: matches.length + 1,
          itemBuilder: (context, index) {
            if (index <= matches.length - 1) {
              final match = matches[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Theme.of(context).highlightColor),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    leading: SizedBox.square(
                      dimension: 50,
                      child: SvgPicture.asset(
                        match.imageAsset,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    title: Center(child: Text(match.name, style: TextStyle(fontSize: 24))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.workTime(match.defaultWork.timeMinSecs),
                          style: TextStyle(fontSize: 16, color: Theme.of(context).secondaryHeaderColor),
                        ),
                        Text(
                          context.l10n.restTime(match.defaultRest.timeMinSecs),
                          style: TextStyle(fontSize: 16, color: Theme.of(context).secondaryHeaderColor),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () async {
                        final updatedMatch = await _openEditor(
                          context,
                          initialMatch: match,
                        );
                        if (!context.mounted || updatedMatch == null) {
                          return;
                        }
                        _saveEditedMatch(context, matches, index, updatedMatch);
                      },
                    ),
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (BuildContext context) => RunPage(match: match)));
                    },
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Theme.of(context).highlightColor),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: ListTile(
                    title: Icon(Icons.add, size: 50),
                    onTap: () async {
                      final newMatch = await _openEditor(context);
                      if (!context.mounted || newMatch == null) {
                        return;
                      }
                      _saveAddedMatch(context, matches, newMatch);
                    },
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
