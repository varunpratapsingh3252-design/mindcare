import 'dart:ui';

import 'package:flutter/material.dart';

import 'listen_player_screen.dart';
import 'color_relax_screen.dart';
import 'scratch_screen.dart';
import 'bubble_pop_screen.dart';
import 'deep_breathing_screen.dart';

class UnwindScreen extends StatefulWidget {
  const UnwindScreen({super.key});

  @override
  State<UnwindScreen> createState() => _UnwindScreenState();
}

class _UnwindScreenState extends State<UnwindScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        children: [
          const Positioned.fill(
            child: _ListenBackground(),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                _buildTopBar(),

                const SizedBox(height: 18),

                _buildTabSwitch(),

                const SizedBox(height: 18),

                Expanded(
                  child: selectedTab == 0
                      ? _buildListenContent()
                      : _buildUnwindContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const Spacer(),

          Text(
            selectedTab == 0 ? 'Listen' : 'Unwind',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          const SizedBox(
            width: 46,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB SWITCH
  // ============================================================

  Widget _buildTabSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.07,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildTab(
              title: 'Listen',
              index: 0,
            ),

            _buildTab(
              title: 'Unwind',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required int index,
  }) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.black
                  : Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTEN CONTENT
  // ============================================================

  Widget _buildListenContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 40,
      ),
      children: [
        // --------------------------------------------------------
        // AMBIENT SOUNDS
        // --------------------------------------------------------

        _buildSection(
          title: 'Ambient Sounds',
          subtitle: 'Immersive nature sounds',
          items: [
            _ListenItem(
              title: 'Summer Seashore',
              file: 'Summer Seashore.mp3',
              icon: Icons.water,
              colors: [
                const Color(0xFF2877A7),
                const Color(0xFF102D58),
              ],
            ),

            _ListenItem(
              title: 'Morning Sunshine',
              file: 'Morning Sunshine.wav',
              icon: Icons.wb_sunny,
              colors: [
                const Color(0xFF617F40),
                const Color(0xFF182B20),
              ],
            ),

            _ListenItem(
              title: 'Nighttime Camping',
              file: 'Nighttime Camping.wav',
              icon: Icons.nightlight_round,
              colors: [
                const Color(0xFF251E34),
                const Color(0xFF080B16),
              ],
            ),

            _ListenItem(
              title: 'Mystic Cosmos',
              file: 'Mystic Cosmos.mp3',
              icon: Icons.auto_awesome,
              colors: [
                const Color(0xFF253A6A),
                const Color(0xFF090D1C),
              ],
            ),

            _ListenItem(
              title: 'Zen Temple',
              file: 'Zen Temple.mp3',
              icon: Icons.temple_buddhist,
              colors: [
                const Color(0xFF6E91A8),
                const Color(0xFF243849),
              ],
            ),
          ],
        ),

        const SizedBox(height: 34),

        // --------------------------------------------------------
        // MUSIC
        // --------------------------------------------------------

        _buildSection(
          title: 'Music',
          subtitle: 'Melodies that touch the soul',
          items: [
            _ListenItem(
              title: 'Space Travel',
              file: 'Space Travel.mp3',
              icon: Icons.blur_on,
              colors: [
                const Color(0xFF191B42),
                const Color(0xFF03050E),
              ],
            ),

            _ListenItem(
              title: 'Hope',
              file: 'Hope.mp3',
              icon: Icons.local_florist,
              colors: [
                const Color(0xFF18241E),
                const Color(0xFF060807),
              ],
            ),

            _ListenItem(
              title: 'Moonlight',
              file: 'Moonlight.mp3',
              icon: Icons.nightlight,
              colors: [
                const Color(0xFF122C55),
                const Color(0xFF050914),
              ],
            ),

            _ListenItem(
              title: 'Sunglow',
              file: 'Sunglow.mp3',
              icon: Icons.wb_sunny,
              colors: [
                const Color(0xFFB18A4A),
                const Color(0xFF34240C),
              ],
            ),
          ],
        ),

        const SizedBox(height: 34),

        // --------------------------------------------------------
        // COLOURED NOISE
        // --------------------------------------------------------

        _buildLandscapeSection(
          title: 'Coloured noise',
          subtitle: 'A digital world of sounds.',
          items: [
            _ListenItem(
              title: 'White Noise',
              file: 'White Noise.mp3',
              icon: Icons.graphic_eq,
              colors: [
                const Color(0xFF777777),
                const Color(0xFF1D1D1D),
              ],
            ),

            _ListenItem(
              title: 'Pink Noise',
              file: 'Pink Noise.mp3',
              icon: Icons.waves,
              colors: [
                const Color(0xFF754C76),
                const Color(0xFF211323),
              ],
            ),

            _ListenItem(
              title: 'Grey Noise',
              file: 'Grey Noise.mp3',
              icon: Icons.blur_linear,
              colors: [
                const Color(0xFF555555),
                const Color(0xFF111111),
              ],
            ),
          ],
        ),

        const SizedBox(height: 34),

        // --------------------------------------------------------
        // TUNE IN COLOUR
        // --------------------------------------------------------

        _buildLandscapeSection(
          title: 'Tune in Colour',
          subtitle: 'Music for every mood.',
          items: [
            _ListenItem(
              title: 'Contemplate',
              file: 'Contemplate.mp3',
              icon: Icons.self_improvement,
              colors: [
                const Color(0xFFD6A36E),
                const Color(0xFF6B4025),
              ],
            ),

            _ListenItem(
              title: 'Driving',
              file: 'Driving.mp3',
              icon: Icons.directions_car,
              colors: [
                const Color(0xFF1B5B8A),
                const Color(0xFF081D3A),
              ],
            ),

            _ListenItem(
              title: 'Exercise',
              file: 'Exercise.mp3',
              icon: Icons.fitness_center,
              colors: [
                const Color(0xFF8B6A9C),
                const Color(0xFF30233D),
              ],
            ),
          ],
        ),

        const SizedBox(height: 34),

        // --------------------------------------------------------
        // THE TALE OF TWO ORANGES
        // --------------------------------------------------------

        _buildLandscapeSection(
          title: 'The Tale of Two Oranges',
          subtitle: 'Stories for quiet moments.',
          items: [
            _ListenItem(
              title: 'Soft Landing',
              file: 'Soft Landing.mp3',
              icon: Icons.menu_book,
              colors: [
                const Color(0xFF879A62),
                const Color(0xFF3E4C2C),
              ],
            ),

            _ListenItem(
              title: 'A Time for Self',
              file: 'A Time for Self.mp3',
              icon: Icons.chair,
              colors: [
                const Color(0xFFC8A98A),
                const Color(0xFF68513F),
              ],
            ),

            _ListenItem(
              title: 'Night at the club',
              file: 'Night at the club.mp3',
              icon: Icons.nights_stay,
              colors: [
                const Color(0xFF443B87),
                const Color(0xFF17142D),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // OPEN LISTEN PLAYER
  // ============================================================

  void _openListenPlayer(
    _ListenItem item,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListenPlayerScreen(
          title: item.title,
          file: item.file,
          colors: item.colors,
          icon: item.icon,
        ),
      ),
    );
  }

  // ============================================================
  // LARGE SECTION
  // ============================================================

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<_ListenItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: _sectionTitle(
            title,
            subtitle,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 270,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (
              context,
              index,
            ) =>
                const SizedBox(width: 16),
            itemBuilder: (
              context,
              index,
            ) {
              return _buildLargeCard(
                items[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LANDSCAPE SECTION
  // ============================================================

  Widget _buildLandscapeSection({
    required String title,
    required String subtitle,
    required List<_ListenItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: _sectionTitle(
            title,
            subtitle,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 145,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (
              context,
              index,
            ) =>
                const SizedBox(width: 16),
            itemBuilder: (
              context,
              index,
            ) {
              return _buildSmallCard(
                items[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    String subtitle,
  ) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const TextSpan(
            text: '  ',
          ),

          TextSpan(
            text: subtitle,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.28,
              ),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LARGE CARD
  // ============================================================

  Widget _buildLargeCard(
    _ListenItem item,
  ) {
    return GestureDetector(
      onTap: () {
        _openListenPlayer(item);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: item.colors.first.withValues(
                alpha: 0.22,
              ),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CustomPaint(
                  painter: _CardPatternPainter(
                    color: item.colors.first,
                    icon: item.icon,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 18,
              left: 18,
              child: _playIndicator(
                small: false,
              ),
            ),

            Positioned(
              left: 18,
              right: 12,
              bottom: 18,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL CARD
  // ============================================================

  Widget _buildSmallCard(
    _ListenItem item,
  ) {
    return GestureDetector(
      onTap: () {
        _openListenPlayer(item);
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: item.colors.first.withValues(
                alpha: 0.18,
              ),
              blurRadius: 25,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CustomPaint(
                  painter: _CardPatternPainter(
                    color: item.colors.first,
                    icon: item.icon,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 14,
              left: 16,
              child: _playIndicator(
                small: true,
              ),
            ),

            Positioned(
              left: 16,
              right: 10,
              bottom: 14,
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAY INDICATOR
  // ============================================================

  Widget _playIndicator({
    required bool small,
  }) {
    final size = small ? 42.0 : 48.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.30,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.45,
          ),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.white.withValues(
          alpha: 0.85,
        ),
        size: small ? 23 : 26,
      ),
    );
  }

  // ============================================================
  // UNWIND CONTENT
  // ============================================================

  Widget _buildUnwindContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Take a moment for yourself 🌿',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Choose something calming and enjoy a quiet moment.',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.55,
              ),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,

            // FIXED:
            // Gives each card more vertical space.
            childAspectRatio: 0.82,

            children: [
              _buildUnwindCard(
                title: 'Bubble Pop',
                subtitle: 'Pop bubbles slowly',
                icon: Icons.bubble_chart,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BubblePopScreen(),
                    ),
                  );
                },
              ),

              _buildUnwindCard(
                title: 'Deep Breathing',
                subtitle: 'Breathe and relax',
                icon: Icons.air,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DeepBreathingScreen(),
                    ),
                  );
                },
              ),

              _buildUnwindCard(
                title: 'Color Relax',
                subtitle: 'Create calming colors',
                icon: Icons.palette,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ColorRelaxScreen(),
                    ),
                  );
                },
              ),

              _buildUnwindCard(
                title: 'Scratch',
                subtitle: 'A satisfying experience',
                icon: Icons.gesture,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ScratchScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UNWIND CARD
  // ============================================================

  Widget _buildUnwindCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: Colors.white.withValues(
                alpha: 0.08,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FIXED:
                // Reduced from 100x100 to 82x82
                // so the card fits without overflow.
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(
                      alpha: 0.15,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 38,
                    color: color,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.5,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// LISTEN ITEM
// ==================================================================

class _ListenItem {
  final String title;
  final String file;
  final IconData icon;
  final List<Color> colors;

  const _ListenItem({
    required this.title,
    required this.file,
    required this.icon,
    required this.colors,
  });
}

// ==================================================================
// BACKGROUND
// ==================================================================

class _ListenBackground extends StatelessWidget {
  const _ListenBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.25,
          colors: [
            Color(0xFF18345C),
            Color(0xFF090B13),
            Color(0xFF030407),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 180,
            left: -100,
            child: _Glow(
              color: const Color(0xFF315A9A),
              size: 280,
            ),
          ),

          Positioned(
            top: 600,
            right: -100,
            child: _Glow(
              color: const Color(0xFF542B72),
              size: 300,
            ),
          ),

          Positioned(
            bottom: 100,
            left: 40,
            child: _Glow(
              color: const Color(0xFF173C76),
              size: 240,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// GLOW
// ==================================================================

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 70,
        sigmaY: 70,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// CARD PATTERN
// ==================================================================

class _CardPatternPainter extends CustomPainter {
  final Color color;
  final IconData icon;

  _CardPatternPainter({
    required this.color,
    required this.icon,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.055,
      )
      ..style = PaintingStyle.fill;

    final center = Offset(
      size.width * 0.72,
      size.height * 0.35,
    );

    for (int i = 0; i < 8; i++) {
      final radius = 30.0 + i * 22;

      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(
          icon.codePoint,
        ),
        style: TextStyle(
          fontSize: size.width * 0.45,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width * 0.25,
        size.height * 0.20,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant _CardPatternPainter oldDelegate,
  ) {
    return false;
  }
}