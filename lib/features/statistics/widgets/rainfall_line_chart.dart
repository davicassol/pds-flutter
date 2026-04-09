import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RainfallLineChart extends StatelessWidget {
  const RainfallLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 15),
                FlSpot(2, 32),
                FlSpot(3, 45),
                FlSpot(4, 28),
                FlSpot(5, 52),
              ],
              isCurved: true,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}