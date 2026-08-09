import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'services/theme_controller.dart';

class MindCareApp extends StatefulWidget {
  const MindCareApp({super.key});

  @override
  State<MindCareApp> createState() =>
      _MindCareAppState();
}

class _MindCareAppState extends State<MindCareApp> {
  @override
  void initState() {
    super.initState();

    ThemeController.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (
        context,
        themeMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'MindCare',

          // LIGHT
          theme: AppTheme.lightTheme,

          // DARK
          darkTheme: AppTheme.darkTheme,

          // SYSTEM / LIGHT / DARK
          themeMode: themeMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}