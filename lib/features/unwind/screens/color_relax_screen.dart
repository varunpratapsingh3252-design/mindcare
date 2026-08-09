import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../services/progress_service.dart';

class ColorRelaxScreen extends StatefulWidget {
  const ColorRelaxScreen({super.key});

  @override
  State<ColorRelaxScreen> createState() => _ColorRelaxScreenState();
}

class _ColorRelaxScreenState extends State<ColorRelaxScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  final AudioPlayer _audioPlayer = AudioPlayer();

  late final AnimationController _animationController;

  final List<_Particle> particles = [];

  Offset? lastPosition;
  Offset fingerVelocity = Offset.zero;

  Color currentColor = const Color(0xFFFFEA00);

  double colorTimer = 0;
  bool _hasInteracted = false;
  bool _progressRecorded = false;

  static const int maxParticles = 450;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Do not call setState every frame.
    // CustomPainter repaints directly from the controller.
    _animationController.addListener(_updateParticles);

    _startAudio();
  }

  // ============================================================
  // AUDIO
  // ============================================================

  Future<void> _startAudio() async {
    try {
      await _audioPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _audioPlayer.setVolume(0.80);

      await _audioPlayer.play(
        AssetSource('audio/color_relax.ogg'),
      );
    } catch (_) {}
  }

  // ============================================================
  // PARTICLE UPDATE
  // ============================================================

  void _updateParticles() {
    for (int i = particles.length - 1; i >= 0; i--) {
      final particle = particles[i];

      particle.life -= 0.010;

      if (particle.life <= 0) {
        particles.removeAt(i);
        continue;
      }

      // Move
      particle.position += particle.velocity;

      // Fluid drag
      particle.velocity *= 0.985;

      // Very small natural movement
      particle.velocity += Offset(
        sin(
              particle.position.dy * 0.008 +
                  particle.phase,
            ) *
            0.018,
        cos(
              particle.position.dx * 0.008 +
                  particle.phase,
            ) *
            0.018,
      );

      // Slowly expand
      particle.radius += 0.045;
    }
  }

  // ============================================================
  // TOUCH START
  // ============================================================

  void _onPanStart(DragStartDetails details) {
    _hasInteracted = true;
    lastPosition = details.localPosition;

    fingerVelocity = Offset.zero;

    _changeColor();

    _emitParticles(
      details.localPosition,
      Offset.zero,
      amount: 22,
    );
  }

  // ============================================================
  // TOUCH MOVE
  // ============================================================

  void _onPanUpdate(DragUpdateDetails details) {
    if (lastPosition == null) {
      lastPosition = details.localPosition;
      return;
    }

    final current = details.localPosition;

    final velocity = current - lastPosition!;

    fingerVelocity = velocity;

    lastPosition = current;

    final speed = velocity.distance;

    // Fewer particles = smoother animation.
    final amount = min(
      22,
      6 + (speed * 0.8).round(),
    );

    _emitParticles(
      current,
      velocity,
      amount: amount,
    );

    // Change color occasionally.
    colorTimer += 0.025;

    if (colorTimer >= 1.0) {
      colorTimer = 0;
      _changeColor();
    }
  }

  // ============================================================
  // TOUCH END
  // ============================================================

  void _onPanEnd(DragEndDetails details) {
    if (lastPosition != null) {
      _emitParticles(
        lastPosition!,
        fingerVelocity,
        amount: 25,
      );
    }

    lastPosition = null;
  }

  // ============================================================
  // COLOR
  // ============================================================

  void _changeColor() {
    const colors = [
      Color(0xFFFFEA00),
      Color(0xFFFF1744),
      Color(0xFFFF6D00),
      Color(0xFFE040FB),
      Color(0xFF7C4DFF),
      Color(0xFF00E5FF),
      Color(0xFF00E676),
    ];

    currentColor =
        colors[random.nextInt(colors.length)];
  }

  // ============================================================
  // CREATE PARTICLES
  // ============================================================

  void _emitParticles(
    Offset position,
    Offset direction, {
    required int amount,
  }) {
    final speed = direction.distance;

    for (int i = 0; i < amount; i++) {
      final angle =
          random.nextDouble() * pi * 2;

      final spread =
          0.15 +
          random.nextDouble() * 0.8;

      Offset velocity;

      if (speed > 0.1) {
        velocity =
            direction *
            (0.25 +
                random.nextDouble() * 0.65);

        velocity += Offset(
          cos(angle) * spread,
          sin(angle) * spread,
        );
      } else {
        velocity = Offset(
          cos(angle) * spread,
          sin(angle) * spread,
        );
      }

      final offset = Offset(
        (random.nextDouble() - 0.5) * 8,
        (random.nextDouble() - 0.5) * 8,
      );

      particles.add(
        _Particle(
          position: position + offset,
          velocity: velocity,
          color: _varyColor(currentColor),
          radius:
              7 +
              random.nextDouble() * 15,
          life:
              0.65 +
              random.nextDouble() * 0.7,
          phase:
              random.nextDouble() * pi * 2,
        ),
      );
    }

    // Hard particle limit.
    if (particles.length > maxParticles) {
      particles.removeRange(
        0,
        particles.length - maxParticles,
      );
    }
  }

  // ============================================================
  // COLOR VARIATION
  // ============================================================

  Color _varyColor(Color color) {
    final variation =
        random.nextInt(25) - 12;

    final red =
        ((color.r * 255.0).round() + variation)
            .clamp(0, 255);

    final green =
        ((color.g * 255.0).round() + variation)
            .clamp(0, 255);

    final blue =
        ((color.b * 255.0).round() + variation)
            .clamp(0, 255);

    return Color.fromARGB(
      255,
      red,
      green,
      blue,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clear() {
    particles.clear();

    _changeColor();
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Future<void> _close() async {
    await _audioPlayer.stop();

    if (_hasInteracted && !_progressRecorded) {
      _progressRecorded = true;
      await ProgressService.completeUnwind();
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF08090C),
      body: SafeArea(
        child: Stack(
          children: [
            // ====================================================
            // FLUID
            // ====================================================

            Positioned.fill(
              child: GestureDetector(
                behavior:
                    HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _FluidPainter(
                      particles: particles,
                      repaint:
                          _animationController,
                    ),
                    child:
                        const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ====================================================
            // CLOSE
            // ====================================================

            Positioned(
              top: 12,
              left: 15,
              child: _CircleButton(
                icon: Icons.close,
                onTap: _close,
              ),
            ),

            // ====================================================
            // CLEAR
            // ====================================================

            Positioned(
              top: 12,
              right: 15,
              child: _CircleButton(
                icon: Icons.refresh,
                onTap: _clear,
              ),
            ),

            // ====================================================
            // TITLE
            // ====================================================

            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Column(
                  children: [
                    Text(
                      'Color Relax',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.9),
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Move your finger slowly',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// PARTICLE
// ==================================================================

class _Particle {
  Offset position;
  Offset velocity;

  final Color color;

  double radius;
  double life;

  final double phase;

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    required this.life,
    required this.phase,
  });
}

// ==================================================================
// FLUID PAINTER
// ==================================================================

class _FluidPainter extends CustomPainter {
  final List<_Particle> particles;

  _FluidPainter({
    required this.particles,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Paint glowPaint = Paint();
  final Paint fluidPaint = Paint();
  final Paint corePaint = Paint();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ==========================================================
    // BACKGROUND
    // ==========================================================

    final backgroundPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: [
          Color(0xFF171914),
          Color(0xFF0C0E0D),
          Color(0xFF050608),
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    // ==========================================================
    // PARTICLES
    // ==========================================================

    for (final particle in particles) {
      _drawParticle(
        canvas,
        particle,
      );
    }

    // ==========================================================
    // VIGNETTE
    // ==========================================================

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withValues(
            alpha: 0.40,
          ),
        ],
        stops: const [
          0.55,
          1.0,
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawRect(
      Offset.zero & size,
      vignettePaint,
    );
  }

  // ============================================================
  // PARTICLE DRAW
  // ============================================================

  void _drawParticle(
    Canvas canvas,
    _Particle particle,
  ) {
    final alpha =
        particle.life.clamp(0.0, 1.0);

    final speed =
        particle.velocity.distance;

    final angle = atan2(
      particle.velocity.dy,
      particle.velocity.dx,
    );

    // Stretch based on velocity.
    final stretch = min(
      1.0 + speed * 0.28,
      2.8,
    );

    // ==========================================================
    // SMALL GLOW
    // ==========================================================

    glowPaint
      ..style = PaintingStyle.fill
      ..color = particle.color.withValues(
        alpha: alpha * 0.10,
      )
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        particle.radius * 0.7,
      );

    canvas.drawCircle(
      particle.position,
      particle.radius * 1.35,
      glowPaint,
    );

    // ==========================================================
    // FLUID BODY
    // ==========================================================

    canvas.save();

    canvas.translate(
      particle.position.dx,
      particle.position.dy,
    );

    canvas.rotate(angle);

    fluidPaint
      ..style = PaintingStyle.fill
      ..color = particle.color.withValues(
        alpha: alpha * 0.48,
      )
      ..maskFilter = null;

    canvas.scale(
      stretch,
      1.0,
    );

    canvas.drawCircle(
      Offset.zero,
      particle.radius,
      fluidPaint,
    );

    canvas.restore();

    // ==========================================================
    // BRIGHT CORE
    // ==========================================================

    corePaint
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(
        alpha: alpha * 0.10,
      );

    canvas.drawCircle(
      particle.position,
      particle.radius * 0.25,
      corePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _FluidPainter oldDelegate,
  ) {
    return false;
  }
}

// ==================================================================
// CIRCLE BUTTON
// ==================================================================

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.35,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}