import 'dart:async';
import 'dart:ui';

import 'package:boxing_timer/l10n/app_localizations.dart';
import 'package:boxing_timer/platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<bool> _matchBackgroundOnIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void _matchBackgroundOnStart(ServiceInstance service) {
  StreamSubscription<Object?>? updateSubscription;
  StreamSubscription<Object?>? stopSubscription;

  updateSubscription = service.on(MatchBackgroundService._updateAction).listen((event) {
    final l10n = _matchBackgroundLookupL10n();
    final matchName = event?['matchName'] as String? ?? l10n.defaultMatchName;
    final phaseLabel = event?['phaseLabel'] as String? ?? 'work';
    final remainingSeconds = event?['remainingSeconds'] as int? ?? 0;
    final roundIndex = event?['roundIndex'] as int? ?? 0;
    final roundsCount = event?['roundsCount'] as int? ?? 0;
    final isPaused = event?['isPaused'] as bool? ?? false;

    final roundLabel = roundsCount > 0
        ? l10n.round(roundIndex + 1, roundsCount)
        : l10n.run;
    final time = _matchBackgroundFormatTime(remainingSeconds);
    final phaseTimeLabel = switch (phaseLabel) {
      'prepare' => l10n.prepareTime(time),
      'rest' => l10n.restTime(time),
      _ => l10n.workTime(time),
    };
    final pausedLabel = isPaused ? ' | ${l10n.pause}' : '';
    final content = '$roundLabel | $phaseTimeLabel$pausedLabel';

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: matchName,
        content: content,
      );
    }
  });

  stopSubscription = service.on(MatchBackgroundService._stopAction).listen((event) async {
    await updateSubscription?.cancel();
    await stopSubscription?.cancel();
    service.stopSelf();
  });
}

AppLocalizations _matchBackgroundLookupL10n() {
  final locale = PlatformDispatcher.instance.locale;

  try {
    return lookupAppLocalizations(locale);
  } catch (_) {
    return lookupAppLocalizations(const Locale('en'));
  }
}

String _matchBackgroundFormatTime(int totalSeconds) {
  if (totalSeconds < 60) {
    return totalSeconds.toString();
  }

  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class MatchBackgroundService {
  static const String notificationChannelId = 'boxer_timer_match';
  static const int notificationId = 12001;
  static const String iosTaskIdentifier =
      'com.github.jvnonce.boxing_timer.background.refresh';

  static const String _updateAction = 'update_match_status';
  static const String _stopAction = 'stop_match_status';

  static bool get _isSupportedPlatform => isMobileNative;

  static bool _configured = false;

  /// Whether the foreground/background status service may run.
  /// Without notification permission the timer stays UI-only.
  static Future<bool> _canUseService() async {
    if (!_isSupportedPlatform) {
      return false;
    }

    return (await Permission.notification.status).isGranted;
  }

  static Future<void> initialize() async {
    if (!_isSupportedPlatform || _configured) {
      return;
    }

    // Configure only when notifications are allowed; otherwise stay widget-only.
    if (!await _canUseService()) {
      return;
    }

    if (isAndroidNative) {
      await _ensureAndroidNotificationChannel();
    }

    final l10n = _matchBackgroundLookupL10n();
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _matchBackgroundOnStart,
        onBackground: _matchBackgroundOnIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: _matchBackgroundOnStart,
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
    final l10n = _matchBackgroundLookupL10n();
    final channel = AndroidNotificationChannel(
      notificationChannelId,
      l10n.notificationChannelName,
      description: l10n.notificationChannelDescription,
      importance: Importance.low,
    );

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permission once after the first frame (Android/iOS).
  static Future<void> preparePermissions() async {
    if (!_isSupportedPlatform) {
      return;
    }

    var status = await Permission.notification.status;
    if (status.isGranted || !status.isDenied) {
      return;
    }

    try {
      await Permission.notification.request();
    } on PlatformException {
      // Dialog already open or request in progress — [showStatus] re-checks.
    }
  }

  static Future<void> showStatus({
    required String matchName,
    required String phaseLabel,
    required int remainingSeconds,
    required int roundIndex,
    required int roundsCount,
    required bool isPaused,
  }) async {
    if (!_isSupportedPlatform) {
      return;
    }

    // No permission → do not start the service; timer continues in the widget.
    if (!await _canUseService()) {
      return;
    }

    // Permission may have been granted after startup — configure lazily.
    if (!_configured) {
      await initialize();
      if (!_configured) {
        return;
      }
    }

    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      await service.startService();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    service.invoke(_updateAction, {
      'matchName': matchName,
      'phaseLabel': phaseLabel,
      'remainingSeconds': remainingSeconds,
      'roundIndex': roundIndex,
      'roundsCount': roundsCount,
      'isPaused': isPaused,
    });
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

    service.invoke(_stopAction);
  }
}
