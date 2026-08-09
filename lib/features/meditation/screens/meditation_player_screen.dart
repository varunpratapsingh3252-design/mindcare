import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/meditation_model.dart';
import '../../../services/progress_service.dart';

class MeditationPlayerScreen extends StatefulWidget {
  final MeditationModel meditation;

  const MeditationPlayerScreen({
    super.key,
    required this.meditation,
  });

  @override
  State<MeditationPlayerScreen> createState() =>
      _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState
    extends State<MeditationPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _timer;

  late int totalSeconds;
  late int remainingSeconds;

  bool isPlaying = false;
  bool isLoading = false;
  bool hasStartedAudio = false;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // LOCK SCREEN TO PORTRAIT
    // ============================================================

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    totalSeconds =
        widget.meditation.durationMinutes * 60;

    remainingSeconds = totalSeconds;

    _setupAudio();
  }

  // ============================================================
  // AUDIO SETUP
  // ============================================================

  Future<void> _setupAudio() async {
    try {
      await _audioPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      debugPrint(
        'Meditation audio setup error: $e',
      );
    }
  }

  // ============================================================
  // START / RESUME
  // ============================================================

  Future<void> startMeditation() async {
    if (isLoading) {
      return;
    }

    // ------------------------------------------------------------
    // RESUME EXISTING AUDIO
    // ------------------------------------------------------------

    if (hasStartedAudio) {
      try {
        await _audioPlayer.resume();

        if (!mounted) {
          return;
        }

        setState(() {
          isPlaying = true;
        });

        _startTimer();

        return;
      } catch (e) {
        debugPrint(
          'Meditation audio resume error: $e',
        );
      }
    }

    // ------------------------------------------------------------
    // FIRST PLAY
    // ------------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      final assetPath =
          'assets/audio/${widget.meditation.audioFile}';

      debugPrint(
        'Playing meditation: $assetPath',
      );

      // Check that the asset exists.
      await rootBundle.load(assetPath);

      // Play the meditation.
      await _audioPlayer.play(
        AssetSource(
          'audio/${widget.meditation.audioFile}',
        ),
        volume: 1.0,
      );

      hasStartedAudio = true;

      if (!mounted) {
        return;
      }

      setState(() {
        isPlaying = true;
        isLoading = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint(
        'Meditation audio error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        isPlaying = false;
        hasStartedAudio = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not play ${widget.meditation.audioFile}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            remainingSeconds = 0;
            isPlaying = false;
          });

          _finishMeditation();

          return;
        }

        setState(() {
          remainingSeconds--;
        });
      },
    );
  }

  // ============================================================
  // PAUSE
  // ============================================================

  Future<void> pauseMeditation() async {
    _timer?.cancel();

    try {
      // IMPORTANT:
      // pause() keeps the current audio position.
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint(
        'Meditation pause error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isPlaying = false;
    });
  }

  // ============================================================
  // RESET
  // ============================================================

  Future<void> resetMeditation() async {
    _timer?.cancel();

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint(
        'Meditation reset error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isPlaying = false;
      isLoading = false;
      hasStartedAudio = false;
      remainingSeconds = totalSeconds;
    });
  }

  // ============================================================
  // FINISH
  // ============================================================

  Future<void> _finishMeditation() async {
    _timer?.cancel();

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint(
        'Meditation finish audio error: $e',
      );
    }

    hasStartedAudio = false;

    // ------------------------------------------------------------
    // SAVE PROGRESS
    //
    // This happens ONLY when the timer reaches 00:00.
    //
    // Pause      -> does NOT count
    // Reset      -> does NOT count
    // Close      -> does NOT count
    // Completion -> DOES count
    // ------------------------------------------------------------

    try {
      await ProgressService.completeMeditation(
        widget.meditation.durationMinutes,
      );

      debugPrint(
        'Meditation progress saved: '
        '${widget.meditation.title}',
      );
    } catch (e) {
      debugPrint(
        'Could not save meditation progress: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isPlaying = false;
      isLoading = false;
      remainingSeconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Meditation completed! 🧘',
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT TIMER
  // ============================================================

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remaining.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CLOSE PLAYER
  // ============================================================

  Future<void> _closePlayer() async {
    _timer?.cancel();

    // Capture Navigator BEFORE the async gap.
    final navigator = Navigator.of(context);

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint(
        'Meditation close audio error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    navigator.pop();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    _audioPlayer.dispose();

    // Restore normal device orientation.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds == 0
        ? 0.0
        : 1 -
            (remainingSeconds / totalSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.meditation.title,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      48,
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // ==================================================
                // MEDITATION ICON
                // ==================================================

                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple
                        .withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 90,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(height: 35),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  widget.meditation.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  widget.meditation.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================================
                // TIMER
                // ==================================================

                Text(
                  formatTime(remainingSeconds),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PROGRESS BAR
                // ==================================================

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        Colors.deepPurple
                            .withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<
                            Color>(
                      Colors.deepPurple,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // ==================================================
                // CONTROLS
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    // RESET
                    IconButton(
                      onPressed:
                          resetMeditation,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      iconSize: 32,
                      tooltip: 'Reset',
                    ),

                    const SizedBox(width: 25),

                    // PLAY / PAUSE
                    FloatingActionButton(
                      heroTag:
                          'meditationPlayButton',
                      onPressed: isLoading
                          ? null
                          : isPlaying
                              ? pauseMeditation
                              : startMeditation,
                      backgroundColor:
                          Colors.deepPurple,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 35,
                            ),
                    ),

                    const SizedBox(width: 25),

                    // CLOSE
                    IconButton(
                      onPressed: _closePlayer,
                      icon: const Icon(
                        Icons.close,
                      ),
                      iconSize: 32,
                      tooltip: 'Close',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ==================================================
                // STATUS
                // ==================================================

                Text(
                  isPlaying
                      ? 'Take a deep breath and relax...'
                      : remainingSeconds == 0
                          ? 'Meditation completed.'
                          : 'Press play to begin your meditation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}