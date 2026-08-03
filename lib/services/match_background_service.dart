import 'dart:async';

import 'package:boxing_timer/services/match_timer_runner.dart';
import 'package:boxing_timer/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Configures and gates the Android/iOS foreground service host for the timer.
class MatchBackgroundService {
  static const String notificationChannelId = 'boxer_timer_match';
  static const int notificationId = 12001;
  static const String iosTaskIdentifier =
      'com.github.jvnonce.boxing_timer.background.refresh';

  static bool get _isSupportedPlatform => isMobileNative;

  static bool _configured = false;

  static Future<bool> _notificationsAllowed() async {
    if (!_isSupportedPlatform) {
      return false;
    }
    return (await Permission.notification.status).isGranted;
  }

  /// Whether the match timer may run inside the FGS isolate.
  static Future<bool> ensureReadyForMatch() async {
    if (!_isSupportedPlatform) {
      return false;
    }

    await preparePermissions();
    if (!await _notificationsAllowed()) {
      return false;
    }

    if (!_configured) {
      await initialize();
    }
    return _configured;
  }

  static Future<void> initialize() async {
    if (!_isSupportedPlatform || _configured) {
      return;
    }

    if (!await _notificationsAllowed()) {
      return;
    }

    if (isAndroidNative) {
      await _ensureAndroidNotificationChannel();
    }

    final l10n = matchTimerLookupL10n();
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: matchTimerServiceMain,
        onBackground: matchTimerIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: matchTimerServiceMain,
        isForegroundMode: true,
        autoStartOnBoot: false,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: l10n.notificationInitialTitle,
        initialNotificationContent: l10n.notificationInitialContent,
        foregroundServiceNotificationId: notificationId,
      ),
    );
    _configured = true;
  }

  static Future<void> _ensureAndroidNotificationChannel() async {
    final l10n = matchTimerLookupL10n();
    final channel = AndroidNotificationChannel(
      notificationChannelId,
      l10n.notificationChannelName,
      description: l10n.notificationChannelDescription,
      importance: Importance.low,
    );

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Notification + battery optimization prompts (Android/iOS).
  static Future<void> preparePermissions() async {
    if (!_isSupportedPlatform) {
      return;
    }

    await _requestNotificationPermission();
    if (isAndroidNative) {
      await _requestIgnoreBatteryOptimizations();
    }
  }

  static Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted || !status.isDenied) {
      return;
    }

    try {
      await Permission.notification.request();
    } on PlatformException {
      // Dialog already open or request in progress.
    }
  }

  static Future<void> _requestIgnoreBatteryOptimizations() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted || status.isPermanentlyDenied) {
      return;
    }

    try {
      await Permission.ignoreBatteryOptimizations.request();
    } on PlatformException {
      // OEM may block the prompt.
    }
  }

  static void stop() {
    if (!_isSupportedPlatform) {
      return;
    }
    unawaited(_stopIfRunning());
  }

  static Future<void> _stopIfRunning() async {
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      return;
    }
    service.invoke(MatchTimerCommands.stop);
  }
}
