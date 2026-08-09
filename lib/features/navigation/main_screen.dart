import 'package:flutter/material.dart';

import '../analytics/screens/analytics_screen.dart';
import '../home/home_screen.dart';
import '../journal/screens/journal_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../unwind/screens/unwind_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const HomeScreen(),
      const UnwindScreen(),
      const JournalScreen(),
      AnalyticsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: "Unwind",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Journal",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
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