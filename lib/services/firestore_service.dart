import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/mood/models/mood_model.dart';
import '../features/journal/models/journal_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ===========================
  // USERS
  // ===========================

  static Future<void> saveUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());
  }

  static Future<DocumentSnapshot> getUser(String uid) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  // ===========================
  // MOODS
  // ===========================

  static Future<void> saveMood(MoodModel mood) async {
    await _firestore
        .collection('moods')
        .doc(mood.id)
        .set(mood.toMap());
  }

  static Future<QuerySnapshot> getUserMoods(String userId) async {
    return await _firestore
        .collection('moods')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
  }

  // ===========================
  // JOURNALS
  // ===========================

  static Future<void> saveJournal(JournalModel journal) async {
    await _firestore
        .collection('journals')
        .doc(journal.id)
        .set(journal.toMap());
  }

  static Future<QuerySnapshot> getUserJournals(
      String userId) async {
    return await _firestore
        .collection('journals')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
  }
}