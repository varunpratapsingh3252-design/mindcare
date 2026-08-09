import 'package:flutter/material.dart';

import '../models/meditation_model.dart';

class MeditationItemCard extends StatelessWidget {
  final MeditationModel meditation;
  final VoidCallback onTap;

  const MeditationItemCard({
    super.key,
    required this.meditation,
    required this.onTap,
  });

  IconData getIcon() {
    switch (meditation.category) {
      case "Breathing":
        return Icons.air;

      case "Stress Relief":
        return Icons.spa;

      case "Sleep":
        return Icons.nightlight_round;

      case "Focus":
        return Icons.center_focus_strong;

      case "Relaxation":
        return Icons.self_improvement;

      case "Morning":
        return Icons.wb_sunny;

      default:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // LEFT ICON
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: Colors.deepPurple,
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // MAIN CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      meditation.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // DESCRIPTION
                    Text(
                      meditation.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // INFO ROW
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 15,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          "${meditation.durationMinutes} min",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Icon(
                          getIcon(),
                          size: 15,
                          color: Colors.deepPurple,
                        ),

                        const SizedBox(width: 5),

                        // THIS PREVENTS THE OVERFLOW
                        Expanded(
                          child: Text(
                            meditation.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // PLAY BUTTON
              const Icon(
                Icons.play_circle_fill,
                color: Colors.deepPurple,
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}