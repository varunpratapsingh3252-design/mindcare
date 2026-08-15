import 'package:flutter/material.dart';

class MoodStreakCard extends StatelessWidget {
  final int currentStreak;
  final int meditationSessions;
  final int meditationMinutes;
  final int unwindSessions;

  const MoodStreakCard({
    super.key,
    required this.currentStreak,
    required this.meditationSessions,
    required this.meditationMinutes,
    required this.unwindSessions,
  });

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 34,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$currentStreak',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'days',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _getMessage(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage() {
    if (currentStreak == 0) {
      return 'Start your mindfulness journey today';
    }

    if (currentStreak == 1) {
      return 'Great start! Keep going';
    }

    if (currentStreak < 7) {
      return 'You are building a healthy habit';
    }

    if (currentStreak < 30) {
      return 'Amazing consistency!';
    }

    return 'Outstanding mindfulness streak!';
  }
}