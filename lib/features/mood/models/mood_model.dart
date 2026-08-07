class MoodModel {
  final String id;
  final String userId;
  final String mood;
  final DateTime date;

  MoodModel({
    required this.id,
    required this.userId,
    required this.mood,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'mood': mood,
      'date': date.toIso8601String(),
    };
  }

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      mood: map['mood'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}