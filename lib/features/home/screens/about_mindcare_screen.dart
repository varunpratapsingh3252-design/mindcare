import 'package:flutter/material.dart';

class AboutMindCareScreen extends StatelessWidget {
  const AboutMindCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About MindCare',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.deepPurple,
                    size: 55,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'MindCare',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Your personal space for mindfulness and wellbeing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // WHAT IS MINDCARE?
              // ==================================================

              _buildSection(
                icon: Icons.favorite_outline,
                title: 'What is MindCare?',
                text:
                    'MindCare is a mindfulness and wellbeing app designed '
                    'to help you build healthy daily habits and take time '
                    'for yourself.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // HOW TO USE
              // ==================================================

              _buildSection(
                icon: Icons.touch_app_outlined,
                title: 'How can you use MindCare?',
                text:
                    'Use the different sections of the app according to '
                    'what you need. You can practice meditation, complete '
                    'Unwind activities, listen to calming sounds, record '
                    'your mood, and write in your journal.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // WHY USE
              // ==================================================

              _buildSection(
                icon: Icons.self_improvement,
                title: 'Why use MindCare?',
                text:
                    'MindCare helps you make mindfulness part of your '
                    'routine. You can track your activities, view your '
                    'progress, and understand your mindfulness habits '
                    'over time.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // WHO CAN USE
              // ==================================================

              _buildSection(
                icon: Icons.people_outline,
                title: 'Who can use MindCare?',
                text:
                    'MindCare can be used by anyone who wants to spend '
                    'some time focusing on their mental wellbeing, '
                    'relaxation, mindfulness, or daily self-care.',
              ),

              const SizedBox(height: 22),

              // ==================================================
              // FEATURES
              // ==================================================

              _buildFeaturesSection(),

              const SizedBox(height: 30),

              // ==================================================
              // DISCLAIMER
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.orange.withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'MindCare is a wellbeing and mindfulness tool. '
                        'It is not intended to replace professional '
                        'medical or mental health care.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: Colors.deepPurple,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURES
  // ============================================================

  Widget _buildFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(
          alpha: 0.06,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What can you do with MindCare?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          _buildFeatureItem(
            Icons.self_improvement,
            'Meditation',
            'Practice guided mindfulness sessions.',
          ),

          _buildFeatureItem(
            Icons.spa_outlined,
            'Unwind',
            'Take part in relaxing activities.',
          ),

          _buildFeatureItem(
            Icons.headphones_outlined,
            'Listen',
            'Listen to relaxing and calming sounds.',
          ),

          _buildFeatureItem(
            Icons.book_outlined,
            'Journal',
            'Write down your thoughts and experiences.',
          ),

          _buildFeatureItem(
            Icons.mood_outlined,
            'Mood',
            'Record how you are feeling.',
          ),

          _buildFeatureItem(
            Icons.bar_chart_outlined,
            'Progress',
            'See your mindfulness activity and progress.',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE ITEM
  // ============================================================

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepPurple,
            size: 24,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}