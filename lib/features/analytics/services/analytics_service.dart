import 'package:cloud_firestore/cloud_firestore.dart';
import '../../mood/services/mood_service.dart';

class AnalyticsService {
  final MoodService _moodService = MoodService();

  Stream<QuerySnapshot> getMoodStream() {
    return _moodService.getMoods();
  }

  /// Count moods by type
  Map<String, int> countMoods(List<QueryDocumentSnapshot> docs) {
    final Map<String, int> counts = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final mood = data['mood'] as String;

      counts[mood] = (counts[mood] ?? 0) + 1;
    }

    return counts;
  }

  /// Total moods
  int totalMoods(List<QueryDocumentSnapshot> docs) {
    return docs.length;
  }

  /// Most common mood
  String mostFrequentMood(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return "None";

    final counts = countMoods(docs);

    return counts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    ).key;
  }
}