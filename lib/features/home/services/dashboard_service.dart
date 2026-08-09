import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<QuerySnapshot> latestMood() {
    return _firestore
        .collection("moods")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> latestJournal() {
    return _firestore
        .collection("journals")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> allMoods() {
    return _firestore
        .collection("moods")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  /// Simple streak (number of mood entries)
  int calculateStreak(List<QueryDocumentSnapshot> docs) {
    return docs.length;
  }
}