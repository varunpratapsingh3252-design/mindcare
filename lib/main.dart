import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'features/mood/provider/mood_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // KEEP THE ENTIRE APP IN PORTRAIT MODE
  // ============================================================

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ============================================================
  // INITIALIZE FIREBASE
  // ============================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // START MINDCARE
  // ============================================================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MoodProvider>(
          create: (_) => MoodProvider(),
        ),
      ],
      child: const MindCareApp(),
    ),
  );
}