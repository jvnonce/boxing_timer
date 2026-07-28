import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MatchAudioService {
  final AudioPlayer _roundStartPlayer = AudioPlayer();
  final AudioPlayer _roundEndPlayer = AudioPlayer();
  final AudioPlayer _warningPlayer = AudioPlayer();

  Future<void> playRoundStart(String assetPath, {bool waitForCompletion = false}) {
    return _play(
      _roundStartPlayer,
      assetPath,
      waitForCompletion: waitForCompletion,
    );
  }

  Future<void> playRoundEnd(String assetPath) {
    return _play(_roundEndPlayer, assetPath);
  }

  Future<void> playWarning(String assetPath) {
    return _play(_warningPlayer, assetPath);
  }

  Future<void> stopRoundStart() {
    return _roundStartPlayer.stop();
  }

  Future<void> dispose() async {
    await _roundStartPlayer.dispose();
    await _roundEndPlayer.dispose();
    await _warningPlayer.dispose();
  }

  static String _assetSourcePath(String assetPath) {
    const prefix = 'assets/';
    if (assetPath.startsWith(prefix)) {
      return assetPath.substring(prefix.length);
    }
    return assetPath;
  }

  Future<void> _play(
    AudioPlayer player,
    String assetPath, {
    bool waitForCompletion = false,
  }) async {
    try {
      await player.stop();
      final completion = waitForCompletion
          ? player.onPlayerComplete.first
          : null;

      if (kIsWeb) {
        await player.play(AssetSource(_assetSourcePath(assetPath)));
      } else {
        final audioData = await rootBundle.load(assetPath);
        await player.play(BytesSource(audioData.buffer.asUint8List()));
      }

      if (completion == null) {
        return;
      }

      await completion.timeout(
        const Duration(seconds: 5),
        onTimeout: () {},
      );
    } catch (error) {
      debugPrint('Unable to play asset "$assetPath": $error');
    }
  }
}
