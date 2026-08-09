import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListenPlayerScreen extends StatefulWidget {
  final String title;
  final String file;
  final List<Color> colors;
  final IconData icon;

  const ListenPlayerScreen({
    super.key,
    required this.title,
    required this.file,
    required this.colors,
    required this.icon,
  });

  @override
  State<ListenPlayerScreen> createState() => _ListenPlayerScreenState();
}

class _ListenPlayerScreenState extends State<ListenPlayerScreen> {
  late final AudioPlayer _playerA;
  late final AudioPlayer _playerB;

  AudioPlayer? _activePlayer;

  StreamSubscription<Duration>? _positionSubscriptionA;
  StreamSubscription<Duration>? _positionSubscriptionB;

  StreamSubscription<Duration>? _durationSubscriptionA;
  StreamSubscription<Duration>? _durationSubscriptionB;

  StreamSubscription<PlayerState>? _stateSubscriptionA;
  StreamSubscription<PlayerState>? _stateSubscriptionB;

  Timer? _sessionTimer;
  Timer? _positionTimer;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isFading = false;

  double _volume = 1.0;

  // 0 = infinity
  int _timerMinutes = 0;

  DateTime? _sessionEndTime;

  bool _playerAIsActive = true;

  static const Duration _crossfadeDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    // Keep this player screen portrait only.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _playerA = AudioPlayer();
    _playerB = AudioPlayer();

    _setupPlayers();
    _startAudio();
  }

  Future<void> _setupPlayers() async {
    await _playerA.setReleaseMode(ReleaseMode.stop);
    await _playerB.setReleaseMode(ReleaseMode.stop);

    await _playerA.setVolume(0);
    await _playerB.setVolume(0);

    _listenToPlayerA();
    _listenToPlayerB();
  }

  // ============================================================
  // PLAYER A
  // ============================================================

  void _listenToPlayerA() {
    _positionSubscriptionA =
        _playerA.onPositionChanged.listen((position) {
      if (!_playerAIsActive) return;

      _position = position;

      if (!mounted) return;

      setState(() {});

      _checkForCrossfade(_playerA, position);
    });

    _durationSubscriptionA =
        _playerA.onDurationChanged.listen((duration) {
      if (!_playerAIsActive) return;

      _duration = duration;
    });

    _stateSubscriptionA =
        _playerA.onPlayerStateChanged.listen((state) {
      if (!_playerAIsActive) return;

      if (state == PlayerState.completed) {
        _handleUnexpectedCompletion(_playerA);
      }
    });
  }

  // ============================================================
  // PLAYER B
  // ============================================================

  void _listenToPlayerB() {
    _positionSubscriptionB =
        _playerB.onPositionChanged.listen((position) {
      if (_playerAIsActive) return;

      _position = position;

      if (!mounted) return;

      setState(() {});

      _checkForCrossfade(_playerB, position);
    });

    _durationSubscriptionB =
        _playerB.onDurationChanged.listen((duration) {
      if (_playerAIsActive) return;

      _duration = duration;
    });

    _stateSubscriptionB =
        _playerB.onPlayerStateChanged.listen((state) {
      if (_playerAIsActive) return;

      if (state == PlayerState.completed) {
        _handleUnexpectedCompletion(_playerB);
      }
    });
  }

  // ============================================================
  // START AUDIO
  // ============================================================

  Future<void> _startAudio() async {
    try {
      await Future.wait([
        _playerA.stop(),
        _playerB.stop(),
      ]);

      await _playerA.setVolume(0);
      await _playerB.setVolume(0);

      _playerAIsActive = true;
      _activePlayer = _playerA;

      await _playerA.play(
        AssetSource('audio/${widget.file}'),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });

      await _fadePlayer(
        _playerA,
        0,
        _volume,
        const Duration(seconds: 2),
      );

      _startPositionTimer();
    } catch (e) {
      debugPrint('Listen audio error: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
    }
  }

  // ============================================================
  // POSITION CHECK
  // ============================================================

  void _startPositionTimer() {
    _positionTimer?.cancel();

    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (!_isPlaying) return;

        final player = _activePlayer;

        if (player == null) return;

        _checkForCrossfade(
          player,
          _position,
        );
      },
    );
  }

  void _checkForCrossfade(
    AudioPlayer player,
    Duration position,
  ) {
    if (!_isPlaying) return;
    if (_isFading) return;
    if (player != _activePlayer) return;

    if (_duration <= Duration.zero) return;

    final remaining = _duration - position;

    if (remaining <= _crossfadeDuration) {
      _beginCrossfade();
    }
  }

  // ============================================================
  // CROSSFADE LOOP
  // ============================================================

  Future<void> _beginCrossfade() async {
    if (_isFading) return;
    if (!_isPlaying) return;

    _isFading = true;

    final oldPlayer = _activePlayer;

    if (oldPlayer == null) {
      _isFading = false;
      return;
    }

    final newPlayer =
        oldPlayer == _playerA ? _playerB : _playerA;

    try {
      await newPlayer.stop();
      await newPlayer.setVolume(0);

      await newPlayer.play(
        AssetSource('audio/${widget.file}'),
      );

      const fadeSteps = 20;

      final stepMilliseconds =
          _crossfadeDuration.inMilliseconds ~/ fadeSteps;

      for (int i = 0; i <= fadeSteps; i++) {
        if (!_isPlaying) break;

        final progress = i / fadeSteps;

        final newVolume =
            (_volume * progress).clamp(0.0, 1.0);

        final oldVolume =
            (_volume * (1 - progress)).clamp(0.0, 1.0);

        await Future.wait([
          newPlayer.setVolume(newVolume),
          oldPlayer.setVolume(oldVolume),
        ]);

        await Future.delayed(
          Duration(milliseconds: stepMilliseconds),
        );
      }

      if (!_isPlaying) {
        await newPlayer.stop();
        await oldPlayer.stop();

        _isFading = false;
        return;
      }

      await oldPlayer.stop();
      await newPlayer.setVolume(_volume);

      _activePlayer = newPlayer;

      _playerAIsActive = newPlayer == _playerA;

      _position = Duration.zero;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Crossfade error: $e');
    }

    _isFading = false;
  }

  Future<void> _handleUnexpectedCompletion(
    AudioPlayer player,
  ) async {
    if (!_isPlaying) return;
    if (_isFading) return;

    if (player == _activePlayer) {
      await _beginCrossfade();
    }
  }

  // ============================================================
  // GENERIC FADE
  // ============================================================

  Future<void> _fadePlayer(
    AudioPlayer player,
    double from,
    double to,
    Duration duration,
  ) async {
    const steps = 20;

    final difference = to - from;

    final stepDuration = Duration(
      milliseconds: duration.inMilliseconds ~/ steps,
    );

    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;

      final value = from + difference * progress;

      await player.setVolume(
        value.clamp(0.0, 1.0),
      );

      await Future.delayed(stepDuration);
    }
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

  Future<void> _togglePlay() async {
    if (_isLoading) return;
    if (_isFading) return;

    final player = _activePlayer;

    if (player == null) return;

    if (_isPlaying) {
      _isFading = true;

      await _fadePlayer(
        player,
        _volume,
        0,
        const Duration(milliseconds: 450),
      );

      await player.pause();

      _isFading = false;

      if (!mounted) return;

      setState(() {
        _isPlaying = false;
      });
    } else {
      await player.setVolume(0);
      await player.resume();

      if (!mounted) return;

      setState(() {
        _isPlaying = true;
      });

      await _fadePlayer(
        player,
        0,
        _volume,
        const Duration(milliseconds: 600),
      );
    }
  }

  // ============================================================
  // VOLUME
  // ============================================================

  Future<void> _setVolume(double value) async {
    _volume = value;

    final player = _activePlayer;

    if (player == null) return;

    if (_isPlaying && !_isFading) {
      await player.setVolume(value);
    }
  }

  // ============================================================
  // SLEEP TIMER
  // ============================================================

  void _setTimer(int minutes) {
    _sessionTimer?.cancel();

    _timerMinutes = minutes;

    // 0 = infinity
    if (minutes == 0) {
      _sessionEndTime = null;

      if (mounted) {
        setState(() {});
      }

      return;
    }

    _sessionEndTime = DateTime.now().add(
      Duration(minutes: minutes),
    );

    _sessionTimer = Timer(
      Duration(minutes: minutes),
      _timerFinished,
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _timerFinished() async {
    if (!_isPlaying) return;

    _sessionTimer?.cancel();
    _sessionTimer = null;
    _sessionEndTime = null;

    final player = _activePlayer;

    if (player == null) return;

    _isFading = true;

    await _fadePlayer(
      player,
      _volume,
      0,
      const Duration(seconds: 3),
    );

    await Future.wait([
      _playerA.stop(),
      _playerB.stop(),
    ]);

    _isFading = false;

    if (!mounted) return;

    setState(() {
      _isPlaying = false;
      _timerMinutes = 0;
      _position = Duration.zero;
    });
  }

  String _timerText() {
    if (_timerMinutes == 0) {
      return 'Infinity';
    }

    if (_sessionEndTime == null) {
      return '$_timerMinutes min';
    }

    final remaining =
        _sessionEndTime!.difference(DateTime.now());

    if (remaining.isNegative) {
      return '0:00';
    }

    final minutes = remaining.inMinutes;

    final seconds = remaining.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // TIMER MENU
  // ============================================================

  void _showTimerMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.82,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF15171D),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  // Handle
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Sleep Timer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose how long you want to listen',
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _timerOption(
                    title: 'Infinity',
                    minutes: 0,
                  ),

                  _timerOption(
                    title: '1 minute',
                    minutes: 1,
                  ),

                  _timerOption(
                    title: '5 minutes',
                    minutes: 5,
                  ),

                  _timerOption(
                    title: '10 minutes',
                    minutes: 10,
                  ),

                  _timerOption(
                    title: '15 minutes',
                    minutes: 15,
                  ),

                  _timerOption(
                    title: '30 minutes',
                    minutes: 30,
                  ),

                  _timerOption(
                    title: '60 minutes',
                    minutes: 60,
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _timerOption({
    required String title,
    required int minutes,
  }) {
    final selected = _timerMinutes == minutes;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(
          minutes == 0
              ? Icons.all_inclusive_rounded
              : Icons.timer_outlined,
          color: selected
              ? Colors.white
              : Colors.white54,
          size: 30,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.white70,
            fontSize: 17,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 30,
              )
            : null,
        onTap: () {
          _setTimer(minutes);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  Future<void> _close() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    _positionTimer?.cancel();

    final player = _activePlayer;

    if (player != null &&
        _isPlaying &&
        !_isFading) {
      _isFading = true;

      await _fadePlayer(
        player,
        _volume,
        0,
        const Duration(milliseconds: 500),
      );
    }

    await Future.wait([
      _playerA.stop(),
      _playerB.stop(),
    ]);

    if (mounted) {
      Navigator.pop(context);
    }
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
          _buildBackground(),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.28),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 0.5,
                  sigmaY: 0.5,
                ),
                child: const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                const Spacer(),

                _buildTitle(),

                const SizedBox(height: 22),

                _buildTimerDisplay(),

                const SizedBox(height: 55),

                _buildPlayButton(),

                const SizedBox(height: 55),

                _buildControlRow(),

                const Spacer(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 1.25,
              colors: [
                widget.colors.first,
                widget.colors.last,
                Colors.black,
              ],
              stops: const [
                0.0,
                0.58,
                1.0,
              ],
            ),
          ),
        ),

        Positioned(
          top: -120,
          left: -100,
          child: _glow(
            widget.colors.first,
            360,
          ),
        ),

        Positioned(
          top: 280,
          right: -130,
          child: _glow(
            widget.colors.first,
            320,
          ),
        ),

        Positioned(
          bottom: -100,
          left: -80,
          child: _glow(
            widget.colors.last,
            380,
          ),
        ),

        Center(
          child: Opacity(
            opacity: 0.18,
            child: Icon(
              widget.icon,
              size: 430,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _glow(
    Color color,
    double size,
  ) {
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
          color: color.withValues(alpha: 0.30),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _close,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: _showTimerMenu,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 19,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _timerMinutes == 0
                        ? '∞'
                        : _timerText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          IconButton(
            onPressed: _showOptions,
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'listen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Text(
            widget.title.toLowerCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMER DISPLAY
  // ============================================================

  Widget _buildTimerDisplay() {
    return GestureDetector(
      onTap: _showTimerMenu,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              color: Colors.white70,
              size: 18,
            ),

            const SizedBox(width: 8),

            Text(
              _timerMinutes == 0
                  ? 'Infinity'
                  : _timerText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAY BUTTON
  // ============================================================

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.34),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.colors.first.withValues(
                alpha: 0.35,
              ),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  _isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 52,
                ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControlRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _controlButton(
          icon: Icons.timer_outlined,
          onTap: _showTimerMenu,
        ),

        const SizedBox(width: 28),

        _controlButton(
          icon: Icons.tune_rounded,
          onTap: _showVolumeControl,
          large: true,
        ),

        const SizedBox(width: 28),

        _controlButton(
          icon: Icons.stop_circle_outlined,
          onTap: _close,
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool large = false,
  }) {
    final size = large ? 76.0 : 58.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(
            alpha: large ? 0.24 : 0.14,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: large ? 31 : 25,
        ),
      ),
    );
  }

  // ============================================================
  // VOLUME
  // ============================================================

  void _showVolumeControl() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                24,
                35,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF15171D),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Volume',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(
                        Icons.volume_down_rounded,
                        color: Colors.white70,
                      ),

                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 1,
                          value: _volume,
                          onChanged: (value) {
                            setModalState(() {
                              _volume = value;
                            });

                            _setVolume(value);
                          },
                        ),
                      ),

                      const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // OPTIONS
  // ============================================================

  void _showOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF15171D),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.drag_handle_rounded,
                color: Colors.white38,
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(
                  Icons.timer_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Sleep Timer',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  _timerMinutes == 0
                      ? 'Infinity'
                      : '$_timerMinutes minutes',
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showTimerMenu();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Volume',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showVolumeControl();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Stop listening',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _close();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _positionTimer?.cancel();

    _positionSubscriptionA?.cancel();
    _positionSubscriptionB?.cancel();

    _durationSubscriptionA?.cancel();
    _durationSubscriptionB?.cancel();

    _stateSubscriptionA?.cancel();
    _stateSubscriptionB?.cancel();

    _playerA.dispose();
    _playerB.dispose();

    // Allow the rest of the application to rotate normally.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }
}