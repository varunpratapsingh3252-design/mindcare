import 'package:flutter/material.dart';

class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Listen",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Sounds to help you relax, focus and sleep.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(
            title: "Ambient Sounds",
            subtitle: "Relax with calming sounds from nature",
          ),

          const SizedBox(height: 14),

          _buildAudioRow(
            [
              _AudioItem(
                title: "Ocean",
                icon: Icons.waves,
              ),
              _AudioItem(
                title: "Rain",
                icon: Icons.water_drop,
              ),
              _AudioItem(
                title: "Forest",
                icon: Icons.forest,
              ),
            ],
          ),

          const SizedBox(height: 30),

          _buildSectionTitle(
            title: "Mindfulness",
            subtitle: "Guided practices for your mind",
          ),

          const SizedBox(height: 14),

          _buildAudioRow(
            [
              _AudioItem(
                title: "Breathing",
                icon: Icons.air,
              ),
              _AudioItem(
                title: "Body Scan",
                icon: Icons.self_improvement,
              ),
              _AudioItem(
                title: "Mindfulness",
                icon: Icons.spa,
              ),
            ],
          ),

          const SizedBox(height: 30),

          _buildSectionTitle(
            title: "Sleep & Relaxation",
            subtitle: "Slow down and prepare for rest",
          ),

          const SizedBox(height: 14),

          _buildAudioRow(
            [
              _AudioItem(
                title: "Deep Sleep",
                icon: Icons.nightlight_round,
              ),
              _AudioItem(
                title: "Night Rain",
                icon: Icons.nightlight,
              ),
              _AudioItem(
                title: "Calm",
                icon: Icons.favorite_border,
              ),
            ],
          ),

          const SizedBox(height: 30),

          _buildSectionTitle(
            title: "Focus",
            subtitle: "Create a peaceful environment",
          ),

          const SizedBox(height: 14),

          _buildAudioRow(
            [
              _AudioItem(
                title: "White Noise",
                icon: Icons.graphic_eq,
              ),
              _AudioItem(
                title: "Pink Noise",
                icon: Icons.graphic_eq,
              ),
              _AudioItem(
                title: "Brown Noise",
                icon: Icons.graphic_eq,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioRow(List<_AudioItem> items) {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];

          return _buildAudioCard(
            context,
            item,
          );
        },
      ),
    );
  }

  Widget _buildAudioCard(
    BuildContext context,
    _AudioItem item,
  ) {
    return SizedBox(
      width: 145,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${item.title} will be available soon.",
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.withValues(
                        alpha: 0.75,
                      ),
                      Colors.blue.withValues(
                        alpha: 0.45,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Icon(
                      item.icon,
                      color: Colors.white,
                      size: 36,
                    ),

                    const Spacer(),

                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Play",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
}

class _AudioItem {
  final String title;
  final IconData icon;

  const _AudioItem({
    required this.title,
    required this.icon,
  });
}