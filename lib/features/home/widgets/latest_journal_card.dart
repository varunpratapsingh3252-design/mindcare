import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/dashboard_service.dart';

class LatestJournalCard extends StatelessWidget {
  LatestJournalCard({super.key});

  final DashboardService dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: dashboardService.latestJournal(),
      builder: (context, snapshot) {
        String title = "No Journal Yet";
        String content = "Write your first journal entry.";

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          title = data["title"] ?? "Untitled";
          content = data["content"] ?? "";
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Latest Journal",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}