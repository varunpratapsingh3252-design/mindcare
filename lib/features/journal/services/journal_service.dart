import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save Journal
  Future<void> saveJournal({
    required String title,
    required String content,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection("journals").add({
      "userId": user.uid,
      "email": user.email,
      "title": title,
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Get Journals
  Stream<QuerySnapshot> getJournals() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection("journals")
        .where("userId", isEqualTo: user.uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Delete Journal
  Future<void> deleteJournal(String id) async {
    await _firestore
        .collection("journals")
        .doc(id)
        .delete();
  }
}