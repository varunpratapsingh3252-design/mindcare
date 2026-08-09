import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../widgets/mood_bar_chart.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/streak_card.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final AnalyticsService analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Analytics"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: analyticsService.getMoodStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No mood data available.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          final total =
              analyticsService.totalMoods(docs);

          final mostFrequent =
              analyticsService.mostFrequentMood(docs);

          final moodCounts =
              analyticsService.countMoods(docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MoodSummaryCard(
                  title: "Total Moods",
                  value: total.toString(),
                  icon: Icons.insert_chart,
                  color: Colors.blue,
                ),

                const SizedBox(height: 16),

                MoodSummaryCard(
                  title: "Most Frequent Mood",
                  value: mostFrequent,
                  icon: Icons.mood,
                  color: Colors.orange,
                ),

                const SizedBox(height: 16),

                StreakCard(
                  streak: total,
                ),

                const SizedBox(height: 16),

                MoodBarChart(
  moodCounts: moodCounts,
),

                const SizedBox(height: 20),

                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Mood Distribution",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ...moodCounts.entries.map(
                          (entry) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style:
                                          const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}