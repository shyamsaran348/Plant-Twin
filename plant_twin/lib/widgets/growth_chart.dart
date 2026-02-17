import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/plant_log.dart';
import '../theme/app_theme.dart';

class GrowthChart extends StatelessWidget {
  final List<PlantLog> logs;

  const GrowthChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text("No growth data available."));
    }

    // Sort logs by date
    final sortedLogs = List<PlantLog>.from(logs)..sort((a, b) => a.date.compareTo(b.date));
    
    // Map data points
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedLogs[i].height));
    }

    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          color: Color(0xFF232C33),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(
                    color: Color(0xff37434d),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < sortedLogs.length) {
                        final date = DateTime.parse(sortedLogs[index].date);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            "${date.day}/${date.month}",
                             style: const TextStyle(color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Color(0xff67727d),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left,
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d)),
              ),
              minX: 0,
              maxX: (sortedLogs.length - 1).toDouble(),
              minY: 0,
              maxY: sortedLogs.map((e) => e.height).reduce((a, b) => a > b ? a : b) + 10,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.secondaryGreen,
                      AppTheme.lightGreen,
                    ],
                  ),
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.secondaryGreen.withOpacity(0.3),
                        AppTheme.lightGreen.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
