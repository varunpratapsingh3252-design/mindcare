import '../models/meditation_model.dart';

class MeditationService {
  static const List<MeditationModel> meditations = [

    // ============================================================
    // BREATHING
    // ============================================================

    MeditationModel(
      id: 'breathing_3',
      title: '3 Minute Breathing',
      description:
          'A short breathing exercise to calm your mind.',
      category: 'Breathing',
      durationMinutes: 3,
      audioFile: 'FreeMindfulness3MinuteBreathing.mp3',
    ),

    MeditationModel(
      id: 'breathing_5',
      title: '5 Minute Breathing',
      description:
          'A gentle breathing practice for relaxation.',
      category: 'Breathing',
      durationMinutes: 5,
      audioFile: 'LifeHappens5MinuteBreathing.mp3',
    ),

    MeditationModel(
      id: 'breathing_10',
      title: '10 Minute Breathing',
      description:
          'A longer breathing session to settle your mind.',
      category: 'Breathing',
      durationMinutes: 10,
      audioFile: 'FreeMindfulness10MinuteBreathing.mp3',
    ),

    // ============================================================
    // STRESS RELIEF
    // ============================================================

    MeditationModel(
      id: 'stress_5',
      title: '5 Minute Stress Relief',
      description:
          'A short meditation to help release everyday stress.',
      category: 'Stress Relief',
      durationMinutes: 5,
      audioFile: 'MARC5MinuteBreathing.mp3',
    ),

    MeditationModel(
      id: 'stress_20',
      title: '20 Minute Stress Relief',
      description:
          'A longer session to slow down and release tension.',
      category: 'Stress Relief',
      durationMinutes: 20,
      audioFile: 'FreeMindfulness20MinuteBellsWithIntervals.mp3',
    ),

    // ============================================================
    // SLEEP
    // ============================================================

    MeditationModel(
      id: 'sleep_mountain',
      title: 'Mountain Meditation',
      description:
          'A peaceful meditation to help you slow down and relax.',
      category: 'Sleep',
      durationMinutes: 20,
      audioFile: 'FreeMindfulnessMountainMeditation.mp3',
    ),

    MeditationModel(
      id: 'sleep_20_bells',
      title: '20 Minute Bells',
      description:
          'Gentle meditation bells for a peaceful sleep session.',
      category: 'Sleep',
      durationMinutes: 20,
      audioFile: 'FreeMindfulness20MinuteJustBells.mp3',
    ),

    MeditationModel(
      id: 'sleep_30_bells',
      title: '30 Minute Meditation',
      description:
          'A longer peaceful meditation session with gentle bells.',
      category: 'Sleep',
      durationMinutes: 30,
      audioFile: '30MinuteJustBells.mp3',
    ),

    // ============================================================
    // FOCUS
    // ============================================================

    MeditationModel(
      id: 'focus_wisdom',
      title: '10 Minute Wisdom',
      description:
          'A guided meditation to help settle your attention.',
      category: 'Focus',
      durationMinutes: 10,
      audioFile: 'UCSD10MinuteWisdom.mp3',
    ),

    MeditationModel(
      id: 'focus_body_scan',
      title: '20 Minute Seated Body Scan',
      description:
          'A guided body scan to bring your attention inward.',
      category: 'Focus',
      durationMinutes: 20,
      audioFile: 'UCSD20MinuteSeatedBodyScan.mp3',
    ),

    // ============================================================
    // RELAXATION
    // ============================================================

    MeditationModel(
      id: 'relax_body_scan',
      title: 'Body Scan',
      description:
          'A calming body scan to help you relax.',
      category: 'Relaxation',
      durationMinutes: 20,
      audioFile: 'BreathworksBodyScan.mp3',
    ),

    MeditationModel(
      id: 'relax_breath',
      title: 'Breath Awareness',
      description:
          'Bring gentle attention to your breathing.',
      category: 'Relaxation',
      durationMinutes: 6,
      audioFile: 'StillMind6MinuteBreathAwareness.mp3',
    ),

    MeditationModel(
      id: 'relax_tension',
      title: 'Tension Release',
      description:
          'A practice designed to help release physical tension.',
      category: 'Relaxation',
      durationMinutes: 20,
      audioFile: 'VidyamalaTensionRelease.mp3',
    ),

    // ============================================================
    // MORNING
    // ============================================================

    MeditationModel(
      id: 'morning_breathing',
      title: '5 Minute Breathing',
      description:
          'Start your morning with calm and steady breathing.',
      category: 'Morning',
      durationMinutes: 5,
      audioFile: 'MARC5MinuteBreathing.mp3',
    ),

    MeditationModel(
      id: 'morning_mindfulness',
      title: 'Brief Mindfulness Practice',
      description:
          'A short mindfulness practice to begin your day.',
      category: 'Morning',
      durationMinutes: 5,
      audioFile: 'PadraigBriefMindfulnessPractice.mp3',
    ),
  ];

  List<MeditationModel> getMeditations() {
    return meditations;
  }

  List<MeditationModel> getByCategory(String category) {
    return meditations
        .where(
          (meditation) =>
              meditation.category == category,
        )
        .toList();
  }
}