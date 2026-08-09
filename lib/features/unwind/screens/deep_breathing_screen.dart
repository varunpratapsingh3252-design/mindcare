import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/progress_service.dart';

class DeepBreathingScreen extends StatefulWidget {
  const DeepBreathingScreen({super.key});

  @override
  State<DeepBreathingScreen> createState() =>
      _DeepBreathingScreenState();
}

class _DeepBreathingScreenState extends State<DeepBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController breathingController;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? timer;

  bool isRunning = false;
  bool isPreparing = false;
  bool isPaused = false;
  bool _progressRecorded = false;

  int selectedMinutes = 1;
  int remainingSeconds = 60;

  String breathingText = "Get ready...";
  String instruction =
      "Follow the instructions to achieve deep relaxation.";

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Lock this screen to portrait mode.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.55,
      upperBound: 1.0,
    );
  }

  // ------------------------------------------------------------
  // AUDIO
  // ------------------------------------------------------------

  Future<void> _playRelaxingAudio() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);

    await _audioPlayer.setVolume(0.35);

    await _audioPlayer.play(
      AssetSource('audio/relaxing.mp3'),
    );
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _resumeAudio() async {
    await _audioPlayer.resume();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    timer?.cancel();

    breathingController.dispose();

    _audioPlayer.dispose();

    // Restore normal orientation when leaving this screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // ------------------------------------------------------------
  // START / RESUME
  // ------------------------------------------------------------

  Future<void> _startBreathing() async {
    // If currently running → pause
    if (isRunning) {
      await _pauseBreathing();
      return;
    }

    // If paused → resume
    if (isPaused) {
      await _resumeBreathing();
      return;
    }

    // Start new session
    await _playRelaxingAudio();

    if (!mounted) return;

    setState(() {
      isRunning = true;
      isPaused = false;
      isPreparing = true;
      breathingText = "Get ready...";
      instruction = "Focus on your breathing.";
    });

    breathingController.stop();
    breathingController.value = 0.55;

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted || !isRunning) return;

        setState(() {
          isPreparing = false;
        });

        _startBreathingCycle();
      },
    );

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || !isRunning) return;

        if (remainingSeconds <= 1) {
          _finishBreathing();
        } else {
          setState(() {
            remainingSeconds--;
          });
        }
      },
    );
  }

  // ------------------------------------------------------------
  // RESUME
  // ------------------------------------------------------------

  Future<void> _resumeBreathing() async {
    if (!mounted) return;

    await _resumeAudio();

    if (!mounted) return;

    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || !isRunning) return;

        if (remainingSeconds <= 1) {
          _finishBreathing();
        } else {
          setState(() {
            remainingSeconds--;
          });
        }
      },
    );

    _startBreathingCycle();
  }

  // ------------------------------------------------------------
  // BREATHING CYCLE
  // ------------------------------------------------------------

  void _startBreathingCycle() {
    if (!mounted || !isRunning) return;

    setState(() {
      breathingText = "Breathe in";
      instruction =
          "Slowly breathe in through your nose.";
    });

    breathingController
        .forward(from: 0.55)
        .then((_) {
      if (!mounted || !isRunning) return;

      setState(() {
        breathingText = "Hold";
        instruction = "Gently hold your breath.";
      });

      Future.delayed(
        const Duration(seconds: 2),
        () {
          if (!mounted || !isRunning) return;

          setState(() {
            breathingText = "Breathe out";
            instruction =
                "Slowly breathe out and relax.";
          });

          breathingController
              .reverse(from: 1.0)
              .then((_) {
            if (!mounted || !isRunning) return;

            Future.delayed(
              const Duration(seconds: 1),
              () {
                if (!mounted || !isRunning) return;

                _startBreathingCycle();
              },
            );
          });
        },
      );
    });
  }

  // ------------------------------------------------------------
  // PAUSE
  // ------------------------------------------------------------

  Future<void> _pauseBreathing() async {
    timer?.cancel();

    breathingController.stop();

    await _pauseAudio();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      isPaused = true;
      isPreparing = false;
      breathingText = "Paused";
      instruction = "Press play to continue.";
    });
  }

  // ------------------------------------------------------------
  // STOP
  // ------------------------------------------------------------

  Future<void> _stopBreathing() async {
    timer?.cancel();

    breathingController.stop();

    await _stopAudio();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      isPaused = false;
      isPreparing = false;

      remainingSeconds = selectedMinutes * 60;

      breathingText = "Ready";

      instruction =
          "Follow the instructions to achieve deep relaxation.";
    });

    breathingController.value = 0.55;
  }

  // ------------------------------------------------------------
  // FINISH
  // ------------------------------------------------------------

  Future<void> _finishBreathing() async {
    timer?.cancel();

    breathingController.stop();

    await _stopAudio();

    if (!_progressRecorded) {
      _progressRecorded = true;
      await ProgressService.completeUnwind();
    }

    if (!mounted) return;

    setState(() {
      isRunning = false;
      isPaused = false;
      isPreparing = false;

      remainingSeconds = 0;

      breathingText = "Well done";

      instruction =
          "Take a moment to notice how you feel.";
    });

    breathingController.value = 0.55;
  }

  // ------------------------------------------------------------
  // DURATION
  // ------------------------------------------------------------

  void _selectDuration(int minutes) {
    if (isRunning || isPaused) return;

    setState(() {
      selectedMinutes = minutes;
      remainingSeconds = minutes * 60;
    });
  }

  // ------------------------------------------------------------
  // FORMAT TIMER
  // ------------------------------------------------------------

  String _formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: SafeArea(
        child: Stack(
          children: [
            // ------------------------------------------------------
            // BACKGROUND
            // ------------------------------------------------------

            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.35, 0.45),
                    radius: 0.85,
                    colors: [
                      Color(0xFF075B91),
                      Color(0xFF101114),
                    ],
                  ),
                ),
              ),
            ),

            // ------------------------------------------------------
            // MAIN CONTENT
            // ------------------------------------------------------

            Column(
              children: [
                // ------------------------------------------------
                // TOP BAR
                // ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
  final navigator = Navigator.of(context);

  await _stopAudio();

  timer?.cancel();

  if (!mounted) return;

  navigator.pop();
},
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------

                const Text(
                  "Deep breathing",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Follow the instructions to achieve deep relaxation.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 25),

                // ------------------------------------------------
                // DURATION
                // ------------------------------------------------

                _buildDurationSelector(),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // BREATHING SPHERE
                // ------------------------------------------------

                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: breathingController,
                      builder: (context, child) {
                        final scale =
                            breathingController.value;

                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF67D7FF),
                              Color(0xFF168CE0),
                              Color(0xFF3030A8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF159FE8)
                                  .withValues(alpha: 0.35),
                              blurRadius: 70,
                              spreadRadius: 25,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            breathingText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ------------------------------------------------
                // INSTRUCTION
                // ------------------------------------------------

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 17,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ------------------------------------------------
                // TIMER
                // ------------------------------------------------

                Text(
                  _formatTime(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // CONTROLS
                // ------------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    _buildControlButton(
                      icon: isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                      onTap: _startBreathing,
                      size: 76,
                    ),

                    const SizedBox(width: 25),

                    _buildControlButton(
                      icon: Icons.stop,
                      onTap: _stopBreathing,
                      size: 58,
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DURATION SELECTOR
  // ------------------------------------------------------------

  Widget _buildDurationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _durationButton(1),
        const SizedBox(width: 8),
        _durationButton(3),
        const SizedBox(width: 8),
        _durationButton(5),
        const SizedBox(width: 8),
        _durationButton(10),
      ],
    );
  }

  Widget _durationButton(int minutes) {
    final selected = selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        _selectDuration(minutes);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4C3BCF)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "$minutes min",
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CONTROL BUTTON
  // ------------------------------------------------------------

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.42,
        ),
      ),
    );
  }
}