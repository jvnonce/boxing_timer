import 'package:boxing_timer/blocs/matches/matches_bloc.dart';
import 'package:boxing_timer/l10n/l10n.dart';
import 'package:boxing_timer/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(context.l10n.timers),
      ),
      body: BlocProvider(
        create: (context) => MatchesBloc()..add(MatchesLoadingEvent()),
        child: const HomeView(),
      ),
    );
  }
}
