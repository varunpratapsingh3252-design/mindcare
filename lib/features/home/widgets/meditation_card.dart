import 'package:flutter/material.dart';

class MeditationCard extends StatelessWidget {
  const MeditationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.self_improvement),

        title: const Text("Meditation"),

        subtitle: const Text(
          "Take a 5 minute break",
        ),

        trailing: const Icon(Icons.play_arrow),
      ),
    );
  }
}