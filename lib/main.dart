import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

import 'providers/mood_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => MoodProvider(),
      ),
    ],
    child: const MindCareApp(),
  ),
);
}