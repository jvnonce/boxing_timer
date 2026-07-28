import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MatchAudioService {
  final AudioPlayer _roundStartPlayer = AudioPlayer();
  final AudioPlayer _roundEndPlayer = AudioPlayer();
  final AudioPlayer _warningPlayer = AudioPlayer();

  Future<void> playRoundStart(String assetPath) {
    return _play(_roundStartPlayer, assetPath);
  }

  Future<void> playRoundEnd(String assetPath) {
    return _play(_roundEndPlayer, assetPath);
  }

  Future<void> playWarning(String assetPath) {
    return _play(_warningPlayer, assetPath);
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

  Future<void> _play(AudioPlayer player, String assetPath) async {
    try {
      await player.stop();
      if (kIsWeb) {
        await player.play(AssetSource(_assetSourcePath(assetPath)));
        return;
      }

      final audioData = await rootBundle.load(assetPath);
      await player.play(BytesSource(audioData.buffer.asUint8List()));
    } catch (error) {
      debugPrint('Unable to play asset "$assetPath": $error');
    }
  }
}
