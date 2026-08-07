import 'package:flutter/material.dart';

class MoodProvider extends ChangeNotifier {
  String? selectedMood;

  void selectMood(String mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void clearMood() {
    selectedMood = null;
    notifyListeners();
  }
}