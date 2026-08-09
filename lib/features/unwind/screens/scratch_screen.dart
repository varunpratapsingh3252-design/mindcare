import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../services/progress_service.dart';

class ScratchScreen extends StatefulWidget {
  const ScratchScreen({super.key});

  @override
  State<ScratchScreen> createState() => _ScratchScreenState();
}

class _ScratchScreenState extends State<ScratchScreen> {
  late final ValueNotifier<int> _repaint;
  late final ScratchPainter _painter;

  bool _soundPlaying = false;
  bool _hasScratched = false;
  bool _progressRecorded = false;

  Timer? _soundStopTimer;

  @override
  void initState() {
    super.initState();

    _repaint = ValueNotifier<int>(0);

    _painter = ScratchPainter(
      repaintNotifier: _repaint,
    );
  }

  // ============================================================
  // TOUCH START
  // ============================================================

  void _startScratch(Offset position) {
    _soundStopTimer?.cancel();

    _painter.startGesture(position);

    // IMPORTANT:
    // Touching alone does NOT start audio.
  }

  // ============================================================
  // FINGER MOVEMENT
  // ============================================================

  void _moveScratch(Offset position) {
    final didScratchNewArea =
        _painter.addPoint(position);

    // ----------------------------------------------------------
    // Nothing new was scratched.
    //
    // IMPORTANT:
    // DO NOT immediately stop the sound.
    //
    // This prevents the audio from becoming choppy when the
    // finger crosses a previously scratched area.
    // ----------------------------------------------------------

    if (!didScratchNewArea) {
      return;
    }

    _hasScratched = true;

    // New material has been scratched.
    _soundStopTimer?.cancel();

    // ----------------------------------------------------------
    // START SOUND ONLY ONCE
    // ----------------------------------------------------------

    if (!_soundPlaying) {
      _soundPlaying = true;

      AudioManager.instance.startScratch();
    }

    // ----------------------------------------------------------
    // WAIT FOR REAL SCRATCHING TO STOP
    // ----------------------------------------------------------

    _soundStopTimer = Timer(
      const Duration(milliseconds: 250),
      _stopScratchSound,
    );
  }

  // ============================================================
  // STOP SOUND
  // ============================================================

  void _stopScratchSound() {
    _soundStopTimer?.cancel();
    _soundStopTimer = null;

    if (!_soundPlaying) {
      return;
    }

    _soundPlaying = false;

    AudioManager.instance.stopScratch();
  }

  // ============================================================
  // FINGER RELEASE
  // ============================================================

  void _stopScratch() {
    _soundStopTimer?.cancel();
    _soundStopTimer = null;

    _stopScratchSound();

    _painter.endGesture();
  }

  // ============================================================
  // RESET
  // ============================================================

  void _reset() {
    _stopScratch();

    _painter.clear();
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Future<void> _close() async {
    _stopScratch();

    if (_hasScratched && !_progressRecorded) {
      _progressRecorded = true;
      await ProgressService.completeUnwind();
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _soundStopTimer?.cancel();

    AudioManager.instance.stopScratch();

    _repaint.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ======================================================
          // IMAGE UNDER SCRATCH
          // ======================================================

          const Positioned.fill(
            child: Image(
              image: AssetImage(
                'assets/images/scratch_reveal.png',
              ),
              fit: BoxFit.cover,
            ),
          ),

          // ======================================================
          // SCRATCH SURFACE
          // ======================================================

          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,

              // Finger touches.
              onPanDown: (details) {
                _startScratch(
                  details.localPosition,
                );
              },

              // Finger moves.
              onPanUpdate: (details) {
                _moveScratch(
                  details.localPosition,
                );
              },

              // Finger released.
              onPanEnd: (_) {
                _stopScratch();
              },

              // Gesture cancelled.
              onPanCancel: () {
                _stopScratch();
              },

              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _painter,
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // ======================================================
          // CLOSE BUTTON - TOP LEFT
          // ======================================================

          Positioned(
            top: 45,
            left: 28,
            child: SafeArea(
              child: GestureDetector(
                onTap: _close,
                child: const SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // RESET BUTTON - BOTTOM CENTER
          // ======================================================

          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: GestureDetector(
                  onTap: _reset,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(
                        alpha: 0.35,
                      ),
                      border: Border.all(
                        color: Colors.white54,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SCRATCH PAINTER
// =================================================================

class ScratchPainter extends CustomPainter {
  final ValueNotifier<int> repaintNotifier;

  final Path _path = Path();

  Offset? _lastPoint;

  // ============================================================
  // SCRATCHED AREA GRID
  //
  // Instead of storing thousands of points and checking every
  // point, we divide the screen into small cells.
  //
  // This is much faster.
  // ============================================================

  final Set<String> _scratchedCells = <String>{};

  // Smaller = more accurate.
  // Larger = faster.
  static const double _cellSize = 18.0;

  // Scratch width.
  static const double _scratchWidth = 28.0;

  ScratchPainter({
    required this.repaintNotifier,
  }) : super(
          repaint: repaintNotifier,
        );

  // ============================================================
  // CELL KEY
  // ============================================================

  
  // ============================================================
  // CHECK / MARK SCRATCH AREA
  // ============================================================

  bool _markScratchArea(
    Offset point,
  ) {
    final radius =
        _scratchWidth / 2;

    final minX =
        point.dx - radius;

    final maxX =
        point.dx + radius;

    final minY =
        point.dy - radius;

    final maxY =
        point.dy + radius;

    final minCellX =
        (minX / _cellSize).floor();

    final maxCellX =
        (maxX / _cellSize).floor();

    final minCellY =
        (minY / _cellSize).floor();

    final maxCellY =
        (maxY / _cellSize).floor();

    bool newArea = false;

    for (
      int x = minCellX;
      x <= maxCellX;
      x++
    ) {
      for (
        int y = minCellY;
        y <= maxCellY;
        y++
      ) {
        final key = '$x:$y';

        if (!_scratchedCells.contains(key)) {
          _scratchedCells.add(key);

          newArea = true;
        }
      }
    }

    return newArea;
  }

  // ============================================================
  // START NEW GESTURE
  // ============================================================

  void startGesture(
    Offset point,
  ) {
    _lastPoint = point;

    _path.moveTo(
      point.dx,
      point.dy,
    );

    repaintNotifier.value++;
  }

  // ============================================================
  // ADD SCRATCH
  // ============================================================

  bool addPoint(
    Offset point,
  ) {
    if (_lastPoint == null) {
      return false;
    }

    final distance =
        (point - _lastPoint!).distance;

    // Ignore extremely tiny movements.
    if (distance < 4) {
      return false;
    }

    // ----------------------------------------------------------
    // SMOOTH SCRATCH PATH
    // ----------------------------------------------------------

    final middle = Offset(
      (_lastPoint!.dx + point.dx) / 2,
      (_lastPoint!.dy + point.dy) / 2,
    );

    _path.quadraticBezierTo(
      _lastPoint!.dx,
      _lastPoint!.dy,
      middle.dx,
      middle.dy,
    );

    // ----------------------------------------------------------
    // CHECK NEW MATERIAL
    //
    // Check both the current point and the middle of the
    // movement so fast finger movements don't leave gaps.
    // ----------------------------------------------------------

    final newAtCurrent =
        _markScratchArea(point);

    final newAtMiddle =
        _markScratchArea(middle);

    _lastPoint = point;

    repaintNotifier.value++;

    return newAtCurrent || newAtMiddle;
  }

  // ============================================================
  // END GESTURE
  // ============================================================

  void endGesture() {
    _lastPoint = null;
  }

  // ============================================================
  // RESET
  // ============================================================

  void clear() {
    _path.reset();

    _lastPoint = null;

    _scratchedCells.clear();

    repaintNotifier.value++;
  }

  // ============================================================
  // PAINT
  // ============================================================

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint(),
    );

    // ----------------------------------------------------------
    // SCRATCH COATING
    // ----------------------------------------------------------

    final coating = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF777777),
          Color(0xFFA0A0A0),
          Color(0xFF858585),
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      coating,
    );

    // ----------------------------------------------------------
    // SURFACE TEXTURE
    // ----------------------------------------------------------

    final texture = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.045,
      )
      ..strokeWidth = 1.5;

    for (
      double y = 0;
      y < size.height;
      y += 11
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        texture,
      );
    }

    // ----------------------------------------------------------
    // ERASE
    // ----------------------------------------------------------

    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = _scratchWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      _path,
      erasePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(
    covariant ScratchPainter oldDelegate,
  ) {
    return false;
  }
}