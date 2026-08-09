import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';

class MoodStreakCard extends StatelessWidget {
  MoodStreakCard({super.key});

  final DashboardService dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: dashboardService.allMoods(),
      builder: (context, snapshot) {
        int streak = 0;

        if (snapshot.hasData) {
          streak = dashboardService.calculateStreak(
            snapshot.data!.docs,
          );
        }

        return Card(
          color: Colors.orange.shade50,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.deepOrange,
                  size: 45,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mood Entries",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "$streak",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}