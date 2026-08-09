import 'package:flutter/material.dart';

import '../models/meditation_model.dart';
import '../services/meditation_service.dart';
import '../widgets/meditation_item_card.dart';
import 'meditation_player_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() =>
      _MeditationScreenState();
}

class _MeditationScreenState
    extends State<MeditationScreen> {
  final MeditationService meditationService =
      MeditationService();

  String selectedCategory = 'All';

  // ============================================================
  // FILTERED MEDITATIONS
  // ============================================================

  List<MeditationModel> get filteredMeditations {
    final allMeditations =
        meditationService.getMeditations();

    if (selectedCategory == 'All') {
      return allMeditations;
    }

    return allMeditations
        .where(
          (meditation) =>
              meditation.category == selectedCategory,
        )
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final meditations = filteredMeditations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meditation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              const Text(
                'Find Your Calm 🧘',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Take a moment for yourself and relax your mind.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // CATEGORIES TITLE
              // ==================================================

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // CATEGORY CARDS
              // ==================================================

              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildCategory(
                      title: 'All',
                      icon: Icons.apps_rounded,
                      color: Colors.deepPurple,
                    ),

                    _buildCategory(
                      title: 'Breathing',
                      icon: Icons.air_rounded,
                      color: Colors.blue,
                    ),

                    _buildCategory(
                      title: 'Stress Relief',
                      icon: Icons.spa_rounded,
                      color: Colors.orange,
                    ),

                    _buildCategory(
                      title: 'Sleep',
                      icon: Icons.nightlight_round,
                      color: Colors.indigo,
                    ),

                    _buildCategory(
                      title: 'Focus',
                      icon: Icons.center_focus_strong,
                      color: Colors.green,
                    ),

                    _buildCategory(
                      title: 'Relaxation',
                      icon: Icons.self_improvement,
                      color: Colors.purple,
                    ),

                    _buildCategory(
                      title: 'Morning',
                      icon: Icons.wb_sunny_rounded,
                      color: Colors.amber.shade700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // SELECTED CATEGORY HEADER
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory == 'All'
                          ? 'All Meditations'
                          : selectedCategory,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple
                          .withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${meditations.length}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // MEDITATION LIST
              // ==================================================

              if (meditations.isEmpty)
                _buildEmptyState()
              else
                ...meditations.map(
                  (
                    MeditationModel meditation,
                  ) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: MeditationItemCard(
                        meditation: meditation,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MeditationPlayerScreen(
                                meditation:
                                    meditation,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategory({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final isSelected =
        selectedCategory == title;

    return GestureDetector(
      onTap: () {
        if (selectedCategory == title) {
          return;
        }

        setState(() {
          selectedCategory = title;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 120,
        margin:
            const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.grey.withValues(
                    alpha: 0.12,
                  ),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isSelected ? 0.08 : 0.04,
              ),
              blurRadius: isSelected ? 8 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                width: isSelected ? 54 : 50,
                height: isSelected ? 54 : 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                    alpha: isSelected
                        ? 0.18
                        : 0.12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSelected ? 29 : 27,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: isSelected
                      ? color
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(top: 10),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(
          alpha: 0.05,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement,
            size: 55,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          Text(
            'No meditations available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try selecting another category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}