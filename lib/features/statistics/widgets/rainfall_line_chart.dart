import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class RainfallLineChart extends StatelessWidget {
  const RainfallLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    List<FlSpot> spots = [];
    for (int i = 0; i < weather.weeklyRainfall.length; i++) {
      spots.add(FlSpot(i.toDouble(), weather.weeklyRainfall[i]));
    }

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Text("Volume Diário (mm)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.dividerGrey, strokeWidth: 1),
                ),
                titlesData: _buildTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryBlue]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                          colors: [AppColors.primaryBlue.withOpacity(0.3), AppColors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            const days = ['7d', '6d', '5d', '4d', '3d', '2d', 'Ontem', 'Hoje'];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textGreyMedium));
            }
            return const Text('');
          },
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceWhite,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: AppColors.shadowColor, blurRadius: 15, offset: Offset(0, 8)),
    ],
  );
}