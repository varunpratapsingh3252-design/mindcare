import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save Mood
  Future<void> saveMood({
    required String mood,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection("moods").add({
      "userId": user.uid,
      "email": user.email,
      "mood": mood,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Get Moods
  Stream<QuerySnapshot> getMoods() {
    final user = _auth.currentUser;

    return _firestore
        .collection("moods")
        .where("userId", isEqualTo: user!.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Delete Mood
  Future<void> deleteMood(String id) async {
    await _firestore.collection("moods").doc(id).delete();
  }
}