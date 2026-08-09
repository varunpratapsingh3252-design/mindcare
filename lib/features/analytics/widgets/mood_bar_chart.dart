import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodBarChart extends StatelessWidget {
  final Map<String, int> moodCounts;

  const MoodBarChart({
    super.key,
    required this.moodCounts,
  });

  @override
  Widget build(BuildContext context) {
    final moods = moodCounts.keys.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),

              gridData: FlGridData(show: true),

              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= moods.length) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          moods[value.toInt()],
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    },
                  ),
                ),
              ),

              barGroups: List.generate(
                moods.length,
                (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: moodCounts[moods[index]]!.toDouble(),
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}