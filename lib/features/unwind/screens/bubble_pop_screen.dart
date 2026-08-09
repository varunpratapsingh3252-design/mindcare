import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../services/progress_service.dart';

class BubblePopScreen extends StatefulWidget {
  const BubblePopScreen({super.key});

  @override
  State<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends State<BubblePopScreen>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();

  final AudioPlayer _backgroundPlayer = AudioPlayer();

  // Multiple players allow several bubble pops to overlap naturally.
  final List<AudioPlayer> _popPlayers = List.generate(
    6,
    (_) => AudioPlayer(),
  );

  int _nextPopPlayer = 0;
  late final AnimationController _animationController;

  final List<_Bubble> _bubbles = [];
  final List<_PopParticle> _particles = [];

  int score = 0;
  int round = 1;

  Size _screenSize = Size.zero;

  bool _gameStarted = false;
  bool _progressRecorded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateGame);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  // ============================================================
  // START GAME
  // ============================================================

  Future<void> _startGame() async {
    if (!mounted) return;

    _screenSize = MediaQuery.of(context).size;

    await _backgroundPlayer.setReleaseMode(
      ReleaseMode.loop,
    );

    await _backgroundPlayer.setVolume(0.70);

    await _backgroundPlayer.play(
      AssetSource('audio/UO.ogg'),
    );

    if (!mounted) return;

    setState(() {
      _gameStarted = true;
    });

    _createNewRound();

    _animationController.repeat();
  }

  // ============================================================
  // CREATE ROUND
  // ============================================================

  void _createNewRound() {
    if (!mounted) return;

    final width = _screenSize.width;
    final height = _screenSize.height;

    if (width <= 0 || height <= 0) return;

    _bubbles.clear();

    // 5–10 PAIRS = 10–20 bubbles.
    final pairCount = 5 + _random.nextInt(6);
    final bubbleCount = pairCount * 2;

    for (int i = 0; i < bubbleCount; i++) {
      _addBubble(width, height);
    }

    setState(() {});
  }

  // ============================================================
  // CREATE BUBBLE
  // ============================================================

  void _addBubble(double width, double height) {
    final radius = 25.0 + _random.nextDouble() * 17.0;

    const topReserved = 115.0;
    const bottomReserved = 75.0;

    final position = Offset(
      radius +
          _random.nextDouble() *
              max(1, width - radius * 2),

      topReserved +
          radius +
          _random.nextDouble() *
              max(
                1,
                height -
                    topReserved -
                    bottomReserved -
                    radius * 2,
              ),
    );

    final speed =
        0.35 + _random.nextDouble() * 0.8;

    final angle =
        _random.nextDouble() * pi * 2;

    _bubbles.add(
      _Bubble(
        id: DateTime.now().microsecondsSinceEpoch +
            _random.nextInt(100000),

        position: position,

        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),

        radius: radius,

        color: _randomBubbleColor(),

        pulseOffset:
            _random.nextDouble() * pi * 2,
      ),
    );
  }

  // ============================================================
  // GAME UPDATE
  // ============================================================

  void _updateGame() {
    if (!_gameStarted || !mounted) return;

    const dt = 1.0;

    final width = _screenSize.width;
    final height = _screenSize.height;

    if (width <= 0 || height <= 0) return;

    // ----------------------------------------------------------
    // MOVE BUBBLES
    // ----------------------------------------------------------

    for (final bubble in _bubbles) {
      if (bubble.isPopping) continue;

      bubble.position +=
          bubble.velocity * dt;

      // Slight floating movement.
      final wobble =
          sin(
                DateTime.now()
                        .millisecondsSinceEpoch /
                    1000 +
                    bubble.pulseOffset,
              ) *
              0.025;

      bubble.position += Offset(
        wobble,
        wobble * 0.7,
      );

      _handleWallCollision(
        bubble,
        width,
        height,
      );
    }

    // ----------------------------------------------------------
    // BUBBLE COLLISIONS
    // ----------------------------------------------------------

    for (int i = 0; i < _bubbles.length; i++) {
      for (int j = i + 1;
          j < _bubbles.length;
          j++) {
        _handleBubbleCollision(
          _bubbles[i],
          _bubbles[j],
        );
      }
    }

    // ----------------------------------------------------------
    // POP PARTICLES
    // ----------------------------------------------------------

    for (final particle in _particles) {
      particle.position +=
          particle.velocity;

      particle.life -= 0.035;
    }

    _particles.removeWhere(
      (particle) => particle.life <= 0,
    );

    // ----------------------------------------------------------
    // POPPING BUBBLES
    // ----------------------------------------------------------

    for (final bubble in _bubbles) {
      if (!bubble.isPopping) continue;

      bubble.popProgress += 0.08;
    }

    _bubbles.removeWhere(
      (bubble) => bubble.popProgress >= 1.0,
    );

    // ----------------------------------------------------------
    // NEW ROUND
    // ----------------------------------------------------------

    if (_bubbles.isEmpty &&
        _particles.isEmpty &&
        _gameStarted) {
      // Completing one full bubble round counts as one Unwind session.
      if (!_progressRecorded) {
        _progressRecorded = true;
        unawaited(ProgressService.completeUnwind());
      }

      round++;

      Future.delayed(
        const Duration(milliseconds: 350),
        () {
          if (!mounted || !_gameStarted) return;

          _createNewRound();
        },
      );
    }

    setState(() {});
  }

  // ============================================================
  // WALL COLLISION
  // ============================================================

  void _handleWallCollision(
    _Bubble bubble,
    double width,
    double height,
  ) {
    const topReserved = 110.0;
    const bottomReserved = 65.0;

    final minX = bubble.radius;
    final maxX = width - bubble.radius;

    final minY =
        topReserved + bubble.radius;

    final maxY =
        height -
        bottomReserved -
        bubble.radius;

    if (bubble.position.dx <= minX) {
      bubble.position = Offset(
        minX,
        bubble.position.dy,
      );

      bubble.velocity = Offset(
        bubble.velocity.dx.abs(),
        bubble.velocity.dy,
      );
    }

    if (bubble.position.dx >= maxX) {
      bubble.position = Offset(
        maxX,
        bubble.position.dy,
      );

      bubble.velocity = Offset(
        -bubble.velocity.dx.abs(),
        bubble.velocity.dy,
      );
    }

    if (bubble.position.dy <= minY) {
      bubble.position = Offset(
        bubble.position.dx,
        minY,
      );

      bubble.velocity = Offset(
        bubble.velocity.dx,
        bubble.velocity.dy.abs(),
      );
    }

    if (bubble.position.dy >= maxY) {
      bubble.position = Offset(
        bubble.position.dx,
        maxY,
      );

      bubble.velocity = Offset(
        bubble.velocity.dx,
        -bubble.velocity.dy.abs(),
      );
    }
  }

  // ============================================================
  // BUBBLE COLLISION
  // ============================================================

  void _handleBubbleCollision(
    _Bubble a,
    _Bubble b,
  ) {
    if (a.isPopping || b.isPopping) return;

    final difference =
        b.position - a.position;

    final distance =
        difference.distance;

    final minimumDistance =
        a.radius + b.radius;

    if (distance <= 0 ||
        distance >= minimumDistance) {
      return;
    }

    final normal =
        difference / distance;

    final relativeVelocity =
        b.velocity - a.velocity;

    final velocityAlongNormal =
        relativeVelocity.dx * normal.dx +
        relativeVelocity.dy * normal.dy;

    // Already moving away from each other.
    if (velocityAlongNormal > 0) {
      return;
    }

    // Soft elastic collision.
    final impulse =
        -velocityAlongNormal * 0.8;

    final impulseVector =
        normal * impulse;

    a.velocity -= impulseVector;
    b.velocity += impulseVector;

    // Separate overlapping bubbles.
    final overlap =
        minimumDistance - distance;

    final separation =
        normal * (overlap / 2);

    a.position -= separation;
    b.position += separation;
  }

  // ============================================================
  // TAP BUBBLE
  // ============================================================

  void _handleTap(Offset tapPosition) {
    for (int i = _bubbles.length - 1;
        i >= 0;
        i--) {
      final bubble = _bubbles[i];

      if (bubble.isPopping) continue;

      final distance =
          (bubble.position - tapPosition)
              .distance;

      if (distance <= bubble.radius) {
        _popBubble(bubble);
        return;
      }
    }
  }

  // ============================================================
  // POP
  // ============================================================

  Future<void> _playPopSound() async {
    final player = _popPlayers[_nextPopPlayer];

    _nextPopPlayer =
        (_nextPopPlayer + 1) % _popPlayers.length;

    try {
      await player.stop();
      await player.play(
        AssetSource('audio/bubble_pop.wav'),
        volume: 0.62,
      );
    } catch (_) {
      // Keep the game working even if the optional pop sound
      // cannot be loaded.
    }
  }

  void _popBubble(_Bubble bubble) {
    if (bubble.isPopping) return;

    bubble.isPopping = true;

    score++;

    // Play a short pop effect independently of the background audio.
    unawaited(_playPopSound());

    // Create particles.
    for (int i = 0; i < 14; i++) {
      final angle =
          _random.nextDouble() * pi * 2;

      final speed =
          1.2 + _random.nextDouble() * 2.2;

      _particles.add(
        _PopParticle(
          position: bubble.position,
          velocity: Offset(
            cos(angle) * speed,
            sin(angle) * speed,
          ),
          color: bubble.color,
          size:
              2.5 + _random.nextDouble() * 4,
        ),
      );
    }
  }

  // ============================================================
  // RANDOM COLOR
  // ============================================================

  Color _randomBubbleColor() {
    const colors = [
      Color(0xFF65C7F7),
      Color(0xFF72D6C1),
      Color(0xFF8CC8FF),
      Color(0xFFB5A7F5),
      Color(0xFF83D6E8),
      Color(0xFF9ED9B6),
      Color(0xFFA8C8F0),
    ];

    return colors[
      _random.nextInt(colors.length)
    ];
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Future<void> _closeScreen() async {
    final navigator = Navigator.of(context);

    _gameStarted = false;

    _animationController.stop();

    await _backgroundPlayer.stop();

    if (!mounted) return;

    navigator.pop();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _gameStarted = false;

    _animationController.dispose();

    _backgroundPlayer.dispose();

    for (final player in _popPlayers) {
      player.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFEAF8F7),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            _screenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return GestureDetector(
              behavior:
                  HitTestBehavior.opaque,

              onTapDown: (details) {
                _handleTap(
                  details.localPosition,
                );
              },

              child: Stack(
                children: [
                  // =================================================
                  // BACKGROUND
                  // =================================================

                  Positioned.fill(
                    child: CustomPaint(
                      painter:
                          _BackgroundPainter(),
                    ),
                  ),

                  // =================================================
                  // BUBBLES
                  // =================================================

                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BubblePainter(
                        bubbles: _bubbles,
                        particles: _particles,
                      ),
                    ),
                  ),

                  // =================================================
                  // TOP BAR
                  // =================================================

                  Positioned(
                    top: 8,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        _roundButton(
                          icon: Icons.close,
                          onTap: _closeScreen,
                        ),

                        Column(
                          children: [
                            const Text(
                              "Bubble Pop",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(
                                  0xFF23404A,
                                ),
                              ),
                            ),

                            Text(
                              "Pop slowly • Relax deeply",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors
                                        .grey
                                        .shade700,
                              ),
                            ),
                          ],
                        ),

                        _scoreWidget(),
                      ],
                    ),
                  ),

                  // =================================================
                  // CENTER TEXT
                  // =================================================

                  if (_bubbles.isEmpty)
                    const Center(
                      child: Text(
                        "Preparing bubbles...",
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              Color(0xFF5C777D),
                        ),
                      ),
                    ),

                  // =================================================
                  // BOTTOM MESSAGE
                  // =================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 15,
                    child: Center(
                      child: Text(
                        "Tap a bubble whenever you feel like it 🌿",
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ROUND BUTTON
  // ============================================================

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(
        alpha: 0.78,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.close,
            color: Color(0xFF34545C),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCORE
  // ============================================================

  Widget _scoreWidget() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.78,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 17,
            color: Colors.orange,
          ),

          const SizedBox(width: 5),

          Text(
            "$score",
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BUBBLE
// ================================================================

class _Bubble {
  final int id;

  Offset position;
  Offset velocity;

  final double radius;

  final Color color;

  final double pulseOffset;

  bool isPopping = false;

  double popProgress = 0;

  _Bubble({
    required this.id,
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    required this.pulseOffset,
  });
}

// ================================================================
// POP PARTICLE
// ================================================================

class _PopParticle {
  Offset position;

  Offset velocity;

  final Color color;

  final double size;

  double life = 1.0;

  _PopParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });
}

// ================================================================
// BACKGROUND PAINTER
// ================================================================

class _BackgroundPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE8FAF8),
          Color(0xFFD6F1EF),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Offset.zero & size,
      paint,
    );

    // Soft background circles.
    final softPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.22,
      );

    canvas.drawCircle(
      Offset(
        size.width * 0.15,
        size.height * 0.28,
      ),
      90,
      softPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.85,
        size.height * 0.65,
      ),
      120,
      softPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ================================================================
// BUBBLE PAINTER
// ================================================================

class _BubblePainter
    extends CustomPainter {
  final List<_Bubble> bubbles;

  final List<_PopParticle> particles;

  _BubblePainter({
    required this.bubbles,
    required this.particles,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // ------------------------------------------------------------
    // BUBBLES
    // ------------------------------------------------------------

    for (final bubble in bubbles) {
      final progress =
          bubble.isPopping
              ? bubble.popProgress
              : 0.0;

      final scale =
          bubble.isPopping
              ? 1.0 - progress
              : 1.0;

      final radius =
          bubble.radius * scale;

      if (radius <= 0) continue;

      final center =
          bubble.position;

      // Glow.
      final glowPaint = Paint()
        ..color = bubble.color
            .withValues(
          alpha: 0.12,
        )
        ..maskFilter =
            const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        center,
        radius + 8,
        glowPaint,
      );

      // Main bubble.
      final bubblePaint = Paint()
        ..shader = RadialGradient(
          center:
              const Alignment(
            -0.35,
            -0.35,
          ),
          colors: [
            Colors.white.withValues(
              alpha: 0.95,
            ),
            bubble.color.withValues(
              alpha: 0.72,
            ),
            bubble.color.withValues(
              alpha: 0.38,
            ),
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
        );

      canvas.drawCircle(
        center,
        radius,
        bubblePaint,
      );

      // Border.
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white
            .withValues(
          alpha: 0.78,
        );

      canvas.drawCircle(
        center,
        radius,
        borderPaint,
      );

      // Shine.
      final shinePaint = Paint()
        ..color = Colors.white
            .withValues(
          alpha: 0.78,
        );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - radius * 0.25,
            center.dy - radius * 0.28,
          ),
          width: radius * 0.45,
          height: radius * 0.22,
        ),
        shinePaint,
      );
    }

    // ------------------------------------------------------------
    // PARTICLES
    // ------------------------------------------------------------

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color
            .withValues(
          alpha: particle.life,
        );

      canvas.drawCircle(
        particle.position,
        particle.size *
            particle.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _BubblePainter oldDelegate,
  ) {
    return true;
  }
}