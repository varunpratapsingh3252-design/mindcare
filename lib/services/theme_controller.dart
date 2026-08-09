import 'package:flutter/material.dart';

import 'progress_service.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> loadTheme() async {
    final savedTheme =
        await ProgressService.getThemeMode();

    switch (savedTheme) {
      case 'Light':
        themeMode.value = ThemeMode.light;
        break;

      case 'Dark':
        themeMode.value = ThemeMode.dark;
        break;

      case 'System':
      default:
        themeMode.value = ThemeMode.system;
        break;
    }
  }

  static Future<void> setTheme(String theme) async {
    await ProgressService.setThemeMode(theme);

    switch (theme) {
      case 'Light':
        themeMode.value = ThemeMode.light;
        break;

      case 'Dark':
        themeMode.value = ThemeMode.dark;
        break;

      case 'System':
      default:
        themeMode.value = ThemeMode.system;
        break;
    }
  }
}