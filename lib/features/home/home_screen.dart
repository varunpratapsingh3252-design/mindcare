import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/progress_service.dart';

import 'widgets/home_header.dart';
import 'widgets/today_mood_card.dart';
import 'widgets/mood_streak_card.dart';
import 'widgets/weekly_chart_card.dart';
import 'widgets/latest_journal_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/about_mindcare_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeFuture;

  @override
  void initState() {
    super.initState();

    _homeFuture = _loadHomeData();

    // Refresh Home whenever meditation/unwind progress changes.
    ProgressService.progressChanged.addListener(
      _onProgressChanged,
    );
  }

  // ============================================================
  // LOAD REAL HOME DATA
  // ============================================================

  Future<Map<String, dynamic>> _loadHomeData() async {
    final userName = await ProgressService.getUserName();

    final meditationSessions =
        await ProgressService.getMeditationSessions();

    final meditationMinutes =
        await ProgressService.getMeditationMinutes();

    final unwindSessions =
        await ProgressService.getUnwindSessions();

    final currentStreak =
        await ProgressService.getCurrentStreak();

    final weeklyActivity =
        await ProgressService.getThisWeekActivity();

    return {
      'userName': userName,
      'meditationSessions': meditationSessions,
      'meditationMinutes': meditationMinutes,
      'unwindSessions': unwindSessions,
      'currentStreak': currentStreak,
      'weeklyActivity': weeklyActivity,
    };
  }

  // ============================================================
  // PROGRESS CHANGED
  // ============================================================

  void _onProgressChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _homeFuture = _loadHomeData();
    });
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshHome() async {
    final future = _loadHomeData();

    if (!mounted) {
      return;
    }

    setState(() {
      _homeFuture = future;
    });

    await future;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    ProgressService.progressChanged.removeListener(
      _onProgressChanged,
    );

    super.dispose();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _homeFuture,

          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF673AB7),
                ),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Unable to load your progress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),

                      FilledButton(
                        onPressed: _refreshHome,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ==================================================
            // DATA
            // ==================================================

            final data = snapshot.data ?? {};

            final userName =
                data['userName'] as String? ??
                    'MindCare User';

            final meditationSessions =
                data['meditationSessions'] as int? ?? 0;

            final meditationMinutes =
                data['meditationMinutes'] as int? ?? 0;

            final unwindSessions =
                data['unwindSessions'] as int? ?? 0;

            final currentStreak =
                data['currentStreak'] as int? ?? 0;

            final weeklyActivity =
                (data['weeklyActivity'] as List<dynamic>?)
                        ?.map(
                          (value) => value as int,
                        )
                        .toList() ??
                    List<int>.filled(7, 0);

            // ==================================================
            // HOME CONTENT
            // ==================================================

            return RefreshIndicator(
              color: const Color(0xFF673AB7),
              onRefresh: _refreshHome,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    HomeHeader(
                      userName: userName,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // CURRENT STREAK
                    // ==================================================

                    MoodStreakCard(
                      currentStreak: currentStreak,
                      meditationSessions:
                          meditationSessions,
                      meditationMinutes:
                          meditationMinutes,
                      unwindSessions:
                          unwindSessions,
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // TODAY'S MOOD
                    // ==================================================

                    TodayMoodCard(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // QUICK ACTIONS
                    // MEDITATION / UNWIND / LISTEN
                    // ==================================================

                    const QuickActionsCard(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // LATEST JOURNAL
                    // ==================================================

                    LatestJournalCard(),

                    const SizedBox(height: 20),

                    // ==================================================
                    // WEEKLY ACTIVITY
                    // ==================================================

                    WeeklyChartCard(
                      weeklyActivity: weeklyActivity,
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // ABOUT MINDCARE
                    // ==================================================

                    const AboutMindCareCard(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}