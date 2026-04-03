import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound-effect player. Fails silently so audio issues
/// never crash the app.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;

  Future<void> playThrow() => _play('throw.mp3');

  Future<void> playStick() => _play('stick.mp3');

  Future<void> playHit() => _play('hit.mp3');

  Future<void> playLevelComplete() => _play('level_complete.mp3');

  Future<void> playGameOver() => _play('game_over.mp3');

  Future<void> playBossAppear() => _play('boss_appear.mp3');

  Future<void> _play(String file) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/$file'));
    } catch (_) {
      // Swallow errors -- sound must never break the app.
    }
  }

  void dispose() {
    _player.dispose();
  }
}
