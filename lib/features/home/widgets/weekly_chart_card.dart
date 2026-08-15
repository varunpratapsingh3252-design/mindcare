import 'package:flutter/material.dart';

class WeeklyChartCard extends StatelessWidget {
  final List<int> weeklyActivity;

  const WeeklyChartCard({
    super.key,
    required this.weeklyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final values = _normalizeData();

    final maxValue = values.isEmpty
        ? 1
        : values.reduce(
            (a, b) => a > b ? a : b,
          );

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          18,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Your mindfulness activity this week',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: List.generate(
                  7,
                  (index) {
                    final value = values[index];

                    final barHeight = maxValue == 0
                        ? 6.0
                        : value == 0
                            ? 6.0
                            : (value / maxValue) * 75;

                    return Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 18,
                              child: value > 0
                                  ? Text(
                                      '$value',
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          const TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            Color(0xFF673AB7),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(height: 3),

                            Container(
                              width: 24,
                              height: barHeight,
                              decoration:
                                  BoxDecoration(
                                color: value == 0
                                    ? Colors.grey.shade300
                                    : const Color(
                                        0xFF7E57C2,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            SizedBox(
                              height: 18,
                              child: Text(
                                _dayName(index),
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.grey.shade600,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _normalizeData() {
    final result = List<int>.filled(7, 0);

    for (
      int i = 0;
      i < weeklyActivity.length && i < 7;
      i++
    ) {
      result[i] = weeklyActivity[i];
    }

    return result;
  }

  String _dayName(int index) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[index];
  }
}