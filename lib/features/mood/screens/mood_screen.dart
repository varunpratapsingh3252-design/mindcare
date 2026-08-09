import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/mood_provider.dart';
import '../services/mood_service.dart';
import '../widgets/mood_card.dart';

class MoodItem {
  final String emoji;
  final String title;
  final Color color;

  const MoodItem({
    required this.emoji,
    required this.title,
    required this.color,
  });
}

const moods = [
  MoodItem(
    emoji: "😊",
    title: "Happy",
    color: Colors.orange,
  ),
  MoodItem(
    emoji: "😄",
    title: "Excited",
    color: Colors.amber,
  ),
  MoodItem(
    emoji: "😌",
    title: "Relaxed",
    color: Colors.green,
  ),
  MoodItem(
    emoji: "😐",
    title: "Neutral",
    color: Colors.blueGrey,
  ),
  MoodItem(
    emoji: "😔",
    title: "Sad",
    color: Colors.indigo,
  ),
  MoodItem(
    emoji: "😭",
    title: "Upset",
    color: Colors.red,
  ),
];

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final moodService = MoodService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Tracker"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Good Morning 🌞",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "How are you feeling today?",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  itemCount: moods.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final mood = moods[index];

                    return MoodCard(
                      emoji: mood.emoji,
                      title: mood.title,
                      color: mood.color,
                      isSelected:
                          moodProvider.selectedMood == mood.title,
                      onTap: () {
                        moodProvider.selectMood(mood.title);
                      },
                    );
                  },
                ),
              ),

              if (moodProvider.selectedMood != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Selected Mood: ${moodProvider.selectedMood}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (moodProvider.selectedMood == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("Please select a mood."),
                        ),
                      );
                      return;
                    }

                    try {
                      await moodService.saveMood(
                        mood: moodProvider.selectedMood!,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Mood saved successfully!",
                          ),
                        ),
                      );

                      moodProvider.clearMood();

                      Navigator.pop(context);
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString(),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Save Mood"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}