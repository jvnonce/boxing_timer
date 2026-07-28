import 'dart:convert';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:boxing_timer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:boxing_timer/models/match.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'matches_event.dart';

part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  MatchesBloc() : super(MatchesLoadingState()) {
    on<MatchesLoadingEvent>((event, emit) async {
      emit(MatchesLoadingState());

      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool isFirstRun = preferences.getBool('isFirstRun') ?? true;
      final l10n = _lookupL10n();

      List<Match> list;
      if (isFirstRun) {
        list = Match.defaultPresets(l10n);
      } else {
        try {
          final source = preferences.getString('items');
          if (source == null) {
            throw Exception();
          }
          final decoded = jsonDecode(source);
          if (decoded is! List) {
            throw Exception();
          }

          list = decoded
              .map(
                (e) => Match.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                ),
              )
              .nonNulls
              .toList();
          if (list.isEmpty) {
            throw Exception();
          }
        } catch (_) {
          list = Match.defaultPresets(l10n);
        }
      }

      if (isFirstRun) {
        await preferences.setBool('isFirstRun', false);
        await _saveMatches(list);
      }

      emit(MatchesReadyState(matches: list));
    });

    on<MatchesReadyEvent>((event, emit) {
      emit(MatchesReadyState(matches: event.matches));
    });

    on<MatchesUpdateEvent>((event, emit) async {
      await _saveMatches(event.matches);
      emit(MatchesReadyState(matches: event.matches));
    });
  }

  Future<void> _saveMatches(List<Match> matches) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'items',
      jsonEncode(matches.map((match) => match.toJson()).toList()),
    );
  }

  static AppLocalizations _lookupL10n() {
    try {
      return lookupAppLocalizations(PlatformDispatcher.instance.locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }
}
