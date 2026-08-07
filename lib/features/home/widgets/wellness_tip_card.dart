import 'package:flutter/material.dart';

class WellnessTipCard extends StatelessWidget {
  const WellnessTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "💡 Wellness Tip",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              "The greatest wealth is mental health.",
            ),
          ],
        ),
      ),
    );
  }
}