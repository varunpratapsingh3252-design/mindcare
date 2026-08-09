import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  AudioPlayer? _backgroundPlayer;
  AudioPlayer? _bubblePlayer;
  AudioPlayer? _scratchPlayer;

  bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    // ----------------------------------------------------------
    // BACKGROUND PLAYER
    // ----------------------------------------------------------

    _backgroundPlayer = AudioPlayer();

    await _backgroundPlayer!.setReleaseMode(
      ReleaseMode.loop,
    );

    await _backgroundPlayer!.setVolume(1.0);

    // ----------------------------------------------------------
    // BUBBLE PLAYER
    // ----------------------------------------------------------

    _bubblePlayer = AudioPlayer();

    await _bubblePlayer!.setPlayerMode(
      PlayerMode.lowLatency,
    );

    await _bubblePlayer!.setVolume(1.0);

    // ----------------------------------------------------------
    // SCRATCH PLAYER
    // ----------------------------------------------------------

    _scratchPlayer = AudioPlayer();

    await _scratchPlayer!.setVolume(1.0);

    await _scratchPlayer!.setReleaseMode(
      ReleaseMode.loop,
    );

    // Load scratch audio once.
    //
    // KEEPING YOUR CURRENT SOUND:
    // assets/audio/scratch.ogg
    await _scratchPlayer!.setSource(
      AssetSource('audio/scratch.ogg'),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Future<void> playBackground(
    String fileName,
  ) async {
    try {
      await initialize();

      await _backgroundPlayer!.stop();

      await _backgroundPlayer!.play(
        AssetSource('audio/$fileName'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint(
        'Background audio error: $e',
      );
    }
  }

  // ============================================================
  // STOP BACKGROUND
  // ============================================================

  Future<void> stopBackground() async {
    try {
      await _backgroundPlayer?.stop();
    } catch (e) {
      debugPrint(
        'Background stop error: $e',
      );
    }
  }

  // ============================================================
  // BUBBLE POP
  // ============================================================

  Future<void> playBubblePop() async {
    try {
      await initialize();

      await _bubblePlayer!.play(
        AssetSource('audio/bubble_pop.wav'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint(
        'Bubble audio error: $e',
      );
    }
  }

  // ============================================================
  // SCRATCH START
  // ============================================================

  Future<void> startScratch() async {
    try {
      await initialize();

      final player = _scratchPlayer;

      if (player == null) {
        return;
      }

      // Already playing.
      //
      // IMPORTANT:
      // Do not restart the audio while the user is scratching.
      if (player.state == PlayerState.playing) {
        return;
      }

      // If the sound reached the end,
      // start again from the beginning.
      if (player.state == PlayerState.completed) {
        await player.seek(
          Duration.zero,
        );
      }

      // Resume instead of stop/play.
      //
      // This avoids the delay when scratching again.
      await player.resume();
    } catch (e) {
      debugPrint(
        'Scratch start error: $e',
      );
    }
  }

  // ============================================================
  // SCRATCH STOP
  // ============================================================

  Future<void> stopScratch() async {
    try {
      final player = _scratchPlayer;

      if (player == null) {
        return;
      }

      // IMPORTANT:
      // Pause instead of stop.
      //
      // The next scratch can resume immediately.
      if (player.state == PlayerState.playing) {
        await player.pause();
      }
    } catch (e) {
      debugPrint(
        'Scratch stop error: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    try {
      await _backgroundPlayer?.dispose();
      await _bubblePlayer?.dispose();
      await _scratchPlayer?.dispose();
    } catch (e) {
      debugPrint(
        'Audio dispose error: $e',
      );
    }

    _backgroundPlayer = null;
    _bubblePlayer = null;
    _scratchPlayer = null;

    _initialized = false;
  }
}