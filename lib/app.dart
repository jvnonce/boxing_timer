import 'dart:async';

import 'package:boxing_timer/l10n/l10n.dart';
import 'package:boxing_timer/pages/home.dart';
import 'package:boxing_timer/services/match_background_service.dart';
import 'package:boxing_timer/theme/theme.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startupServices());
    });
  }

  Future<void> _startupServices() async {
    try {
      await MatchBackgroundService.preparePermissions();
    } catch (e, st) {
      debugPrint('MatchBackgroundService.preparePermissions failed: $e\n$st');
    }
    // Configures only if notification permission was granted; otherwise UI-only.
    try {
      await MatchBackgroundService.initialize();
    } catch (e, st) {
      debugPrint('MatchBackgroundService.initialize failed: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MaterialTheme(TextTheme()).light(),
      darkTheme: MaterialTheme(TextTheme()).dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
