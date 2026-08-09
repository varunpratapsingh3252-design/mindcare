import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  // Notifies screens such as Profile whenever saved progress changes.
  static final ValueNotifier<int> progressChanged = ValueNotifier<int>(0);
  // ============================================================
  // PROGRESS KEYS
  // ============================================================

  static const String _meditationSessionsKey =
      'meditation_sessions';

  static const String _meditationMinutesKey =
      'meditation_minutes';

  static const String _unwindSessionsKey =
      'unwind_sessions';

  static const String _currentStreakKey =
      'current_streak';

  static const String _lastActivityDateKey =
      'last_activity_date';

  // ============================================================
  // PROFILE KEYS
  // ============================================================

  static const String _userNameKey =
      'user_name';

  // ============================================================
  // PREFERENCE KEYS
  // ============================================================

  static const String _soundEnabledKey =
      'sound_enabled';

  static const String _notificationsEnabledKey =
      'notifications_enabled';

  static const String _themeModeKey =
      'theme_mode';

  // ============================================================
  // WEEKLY ACTIVITY KEY
  // ============================================================

  static const String _weeklyActivityKey =
      'weekly_activity';

  // ============================================================
  // GET MEDITATION SESSIONS
  // ============================================================

  static Future<int> getMeditationSessions() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
          _meditationSessionsKey,
        ) ??
        0;
  }

  // ============================================================
  // GET MEDITATION MINUTES
  // ============================================================

  static Future<int> getMeditationMinutes() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
          _meditationMinutesKey,
        ) ??
        0;
  }

  // ============================================================
  // GET UNWIND SESSIONS
  // ============================================================

  static Future<int> getUnwindSessions() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
          _unwindSessionsKey,
        ) ??
        0;
  }

  // ============================================================
  // GET CURRENT STREAK
  // ============================================================

  static Future<int> getCurrentStreak() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(
          _currentStreakKey,
        ) ??
        0;
  }

  // ============================================================
  // COMPLETE MEDITATION
  // ============================================================

  static Future<void> completeMeditation(
    int durationMinutes,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final sessions =
        prefs.getInt(
              _meditationSessionsKey,
            ) ??
            0;

    final minutes =
        prefs.getInt(
              _meditationMinutesKey,
            ) ??
            0;

    await prefs.setInt(
      _meditationSessionsKey,
      sessions + 1,
    );

    await prefs.setInt(
      _meditationMinutesKey,
      minutes + durationMinutes,
    );

    // Record activity for the weekly graph.
    await _recordWeeklyActivity(
      prefs,
      amount: durationMinutes,
    );

    // Update streak.
    await _updateStreak(prefs);
    progressChanged.value++;
  }

  // ============================================================
  // COMPLETE UNWIND
  // ============================================================

  static Future<void> completeUnwind() async {
    final prefs =
        await SharedPreferences.getInstance();

    final sessions =
        prefs.getInt(
              _unwindSessionsKey,
            ) ??
            0;

    await prefs.setInt(
      _unwindSessionsKey,
      sessions + 1,
    );

    // Record activity for the weekly graph.
    await _recordWeeklyActivity(
      prefs,
      amount: 1,
    );

    // Update streak.
    await _updateStreak(prefs);
    progressChanged.value++;
  }

  // ============================================================
  // STREAK
  // ============================================================

  static Future<void> _updateStreak(
    SharedPreferences prefs,
  ) async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lastActivityString =
        prefs.getString(
      _lastActivityDateKey,
    );

    int streak =
        prefs.getInt(
              _currentStreakKey,
            ) ??
            0;

    // ----------------------------------------------------------
    // FIRST ACTIVITY EVER
    // ----------------------------------------------------------

    if (lastActivityString == null) {
      streak = 1;
    } else {
      final lastActivity =
          DateTime.tryParse(
        lastActivityString,
      );

      if (lastActivity == null) {
        streak = 1;
      } else {
        final lastDate = DateTime(
          lastActivity.year,
          lastActivity.month,
          lastActivity.day,
        );

        final difference =
            today.difference(lastDate).inDays;

        if (difference == 0) {
          // Already active today.
          //
          // Do not increase the streak again.
        } else if (difference == 1) {
          // Active yesterday and today.
          streak++;
        } else {
          // Missed one or more days.
          streak = 1;
        }
      }
    }

    await prefs.setInt(
      _currentStreakKey,
      streak,
    );

    await prefs.setString(
      _lastActivityDateKey,
      today.toIso8601String(),
    );
  }

  // ============================================================
  // WEEKLY ACTIVITY
  //
  // Stores activity for each calendar date.
  //
  // Example:
  //
  // {
  //   "2026-08-09": 3,
  //   "2026-08-08": 5
  // }
  //
  // The Profile screen can use this to create the real
  // seven-day graph.
  // ============================================================

  static Future<void> _recordWeeklyActivity(
    SharedPreferences prefs, {
    required int amount,
  }) async {
    final raw =
        prefs.getString(
      _weeklyActivityKey,
    );

    Map<String, dynamic> data = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded =
            jsonDecode(raw);

        if (decoded is Map) {
          data = Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {
        data = {};
      }
    }

    final now = DateTime.now();

    final dateKey =
        _dateKey(now);

    final current =
        (data[dateKey] as num?)?.toInt() ??
            0;

    data[dateKey] =
        current + amount;

    // Keep only the last 30 days.
    final cutoff =
        DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      const Duration(days: 30),
    );

    data.removeWhere(
      (key, value) {
        final date =
            DateTime.tryParse(key);

        if (date == null) {
          return true;
        }

        return date.isBefore(cutoff);
      },
    );

    await prefs.setString(
      _weeklyActivityKey,
      jsonEncode(data),
    );
  }

  // ============================================================
  // GET THIS WEEK
  //
  // Returns 7 values:
  //
  // Monday → Sunday
  //
  // Example:
  //
  // [2, 0, 4, 1, 0, 3, 5]
  // ============================================================

  static Future<List<int>> getThisWeekActivity() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(
      _weeklyActivityKey,
    );

    Map<String, dynamic> data = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded =
            jsonDecode(raw);

        if (decoded is Map) {
          data = Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {
        data = {};
      }
    }

    final now = DateTime.now();

    // DateTime.weekday:
    //
    // Monday = 1
    // Tuesday = 2
    // ...
    // Sunday = 7
    //
    final monday =
        DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(
      Duration(
        days: now.weekday - 1,
      ),
    );

    final result =
        <int>[];

    for (int i = 0; i < 7; i++) {
      final date =
          monday.add(
        Duration(days: i),
      );

      final key =
          _dateKey(date);

      final value =
          (data[key] as num?)?.toInt() ??
              0;

      result.add(value);
    }

    return result;
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  static String _dateKey(
    DateTime date,
  ) {
    final year =
        date.year.toString();

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ============================================================
  // USER NAME
  // ============================================================

  static Future<String> getUserName() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
          _userNameKey,
        ) ??
        'MindCare User';
  }

  static Future<void> setUserName(
    String name,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _userNameKey,
      name.trim(),
    );
  }

  // ============================================================
  // SOUND PREFERENCE
  // ============================================================

  static Future<bool> getSoundEnabled() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _soundEnabledKey,
        ) ??
        true;
  }

  static Future<void> setSoundEnabled(
    bool enabled,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _soundEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // NOTIFICATION PREFERENCE
  // ============================================================

  static Future<bool>
      getNotificationsEnabled() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _notificationsEnabledKey,
        ) ??
        true;
  }

  static Future<void>
      setNotificationsEnabled(
    bool enabled,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _notificationsEnabledKey,
      enabled,
    );
  }

  // ============================================================
  // THEME
  //
  // Values:
  //
  // System
  // Light
  // Dark
  // ============================================================

  static Future<String> getThemeMode() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
          _themeModeKey,
        ) ??
        'System';
  }

  static Future<void> setThemeMode(
    String mode,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _themeModeKey,
      mode,
    );
  }

  // ============================================================
  // RESET PROGRESS
  //
  // This resets:
  //
  // Meditation sessions
  // Meditation minutes
  // Unwind sessions
  // Streak
  // Activity history
  //
  // It intentionally DOES NOT delete:
  //
  // User name
  // Sound preference
  // Notification preference
  // Appearance preference
  // ============================================================

  static Future<void> resetProgress() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _meditationSessionsKey,
    );

    await prefs.remove(
      _meditationMinutesKey,
    );

    await prefs.remove(
      _unwindSessionsKey,
    );

    await prefs.remove(
      _currentStreakKey,
    );

    await prefs.remove(
      _lastActivityDateKey,
    );

    await prefs.remove(
      _weeklyActivityKey,
    );

    progressChanged.value++;
  }
}