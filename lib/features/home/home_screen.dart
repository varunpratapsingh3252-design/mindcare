import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'widgets/home_header.dart';
import 'widgets/journal_card.dart';
import 'widgets/meditation_card.dart';
import 'widgets/mood_card.dart';
import 'widgets/wellness_tip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    final user = AuthService.currentUser;

    return Scaffold(

      appBar: AppBar(

        title: const Text("MindCare"),

        actions: [

          IconButton(

            icon: const Icon(Icons.logout),

            onPressed: () async {

              await AuthService.logout();

              if (!mounted) return;

              Navigator.pop(context);

            },

          ),

        ],

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              HomeHeader(
                userName: user?.email ?? "Guest",
              ),

              const SizedBox(height: 25),

              const MoodCard(),

              const SizedBox(height: 20),

              const JournalCard(),

              const SizedBox(height: 20),

              const MeditationCard(),

              const SizedBox(height: 20),

              const WellnessTipCard(),

            ],

          ),

        ),

      ),

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {

            currentIndex = index;

          });

        },

        type: BottomNavigationBarType.fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Journal",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "History",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],

      ),

    );
  }
}