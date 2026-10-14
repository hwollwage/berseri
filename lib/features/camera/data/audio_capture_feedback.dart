import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:berseri/features/camera/domain/capture_feedback.dart';

class AudioCaptureFeedback implements CaptureFeedback {
  AudioCaptureFeedback() {
    // Muat di awal supaya tidak ada jeda saat pertama kali ditekan.
    _player
        .setSource(AssetSource('sounds/shutter.mp3'))
        .catchError((Object e) => debugPrint('shutter preload failed: $e'));
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> shutter() async {
    HapticFeedback.mediumImpact();
    try {
      await _player.stop();
      await _player.resume();
    } catch (e) {
      debugPrint('shutter sound failed: $e');
      try {
        await _player.play(AssetSource('sounds/shutter.mp3'));
      } catch (e2) {
        debugPrint('shutter sound failed again: $e2');
        SystemSound.play(SystemSoundType.click);
      }
    }
  }

  Future<void> dispose() => _player.dispose();
}