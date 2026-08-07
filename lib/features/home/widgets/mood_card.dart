import 'package:flutter/material.dart';

class MoodCard extends StatelessWidget {
  const MoodCard({super.key});

  @override
  Widget build(BuildContext context) {
    final moods = ["😄", "😊", "😐", "😔", "😭"];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "How are you feeling today?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moods.map((emoji) {
                return Text(
                  emoji,
                  style: const TextStyle(fontSize: 34),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}