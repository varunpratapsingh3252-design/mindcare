import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/mood_service.dart';

class MoodHistoryScreen extends StatelessWidget {
  MoodHistoryScreen({super.key});

  final MoodService moodService = MoodService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: moodService.getMoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No moods recorded yet.",
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
                  docs[index].data() as Map<String, dynamic>;

              final timestamp =
                  data["createdAt"] as Timestamp?;

              final date = timestamp == null
                  ? "Just now"
                  : DateFormat(
                      "dd MMM yyyy • hh:mm a",
                    ).format(
                      timestamp.toDate(),
                    );

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.mood,
                    color: Colors.orange,
                    size: 40,
                  ),
                  title: Text(data["mood"]),
                  subtitle: Text(date),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await moodService.deleteMood(
                        docs[index].id,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}