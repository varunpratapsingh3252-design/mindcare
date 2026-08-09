import 'package:flutter/material.dart';

class WeeklyChartCard extends StatelessWidget {
  const WeeklyChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            "Weekly Mood Chart\n(Coming Soon)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}