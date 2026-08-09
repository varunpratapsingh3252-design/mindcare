import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streak;

  const StreakCard({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepOrange.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.deepOrange,
              size: 42,
            ),

            const SizedBox(width: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mood Streak",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  "$streak Days",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}