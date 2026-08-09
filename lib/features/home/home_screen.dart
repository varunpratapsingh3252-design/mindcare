import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

import 'widgets/home_header.dart';
import 'widgets/today_mood_card.dart';
import 'widgets/mood_streak_card.dart';
import 'widgets/weekly_chart_card.dart';
import 'widgets/latest_journal_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/wellness_tip_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MindCare"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();

              if (!context.mounted) return;

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                userName: user?.email ?? "Guest",
              ),

              const SizedBox(height: 25),

              TodayMoodCard(),

              const SizedBox(height: 20),

             MoodStreakCard(),

              const SizedBox(height: 20),

              const WeeklyChartCard(),

              const SizedBox(height: 20),

              LatestJournalCard(),

              const SizedBox(height: 20),

              const QuickActionsCard(),

              const SizedBox(height: 20),

              const WellnessTipCard(),
            ],
          ),
        ),
      ),
    );
  }
}