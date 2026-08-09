import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../mood/screens/mood_screen.dart';
import '../services/dashboard_service.dart';

class TodayMoodCard extends StatelessWidget {
  TodayMoodCard({super.key});

  final DashboardService dashboardService = DashboardService();

  String getEmoji(String mood) {
    switch (mood) {
      case "Happy":
        return "😊";
      case "Excited":
        return "😄";
      case "Relaxed":
        return "😌";
      case "Neutral":
        return "😐";
      case "Sad":
        return "😔";
      case "Upset":
        return "😭";
      default:
        return "🙂";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: dashboardService.latestMood(),
      builder: (context, snapshot) {
        String mood = "No Mood";

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          mood = data["mood"] ?? "No Mood";
        }

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MoodScreen(),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    getEmoji(mood),
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Mood",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          mood,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Tap to update your mood",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}