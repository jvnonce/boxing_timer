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

  Future<void> _confirmDeleteMatch(
    BuildContext context,
    List<Match> matches,
    int index,
    Match match,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMatch),
        content: Text(l10n.deleteMatchConfirm(match.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final updated = [...matches]..removeAt(index);
    context.read<MatchesBloc>().add(MatchesUpdateEvent(matches: updated));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchesLoadingState) {
          return Center(
            child: SizedBox.square(
              dimension: 200,
              child: CircularProgressIndicator(),
            ),
          );
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
                    border: BoxBorder.all(
                      color: Theme.of(context).highlightColor,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10.0),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                RunPage(match: match),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox.square(
                              dimension: 50,
                              child: SvgPicture.asset(
                                match.imageAsset,
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    match.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    context.l10n.workTime(
                                      match.defaultWork.timeMinSecs,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).secondaryHeaderColor,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.restTime(
                                      match.defaultRest.timeMinSecs,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).secondaryHeaderColor,
                                    ),
                                  ),
                                  Text(
                                    context.l10n.roundsCount(match.roundsCount),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).secondaryHeaderColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  icon: const Icon(Icons.settings),
                                  tooltip: context.l10n.editMatch,
                                  onPressed: () async {
                                    final updatedMatch = await _openEditor(
                                      context,
                                      initialMatch: match,
                                    );
                                    if (!context.mounted ||
                                        updatedMatch == null) {
                                      return;
                                    }
                                    _saveEditedMatch(
                                      context,
                                      matches,
                                      index,
                                      updatedMatch,
                                    );
                                  },
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: context.l10n.delete,
                                  onPressed: () => _confirmDeleteMatch(
                                    context,
                                    matches,
                                    index,
                                    match,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      color: Theme.of(context).highlightColor,
                    ),
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
