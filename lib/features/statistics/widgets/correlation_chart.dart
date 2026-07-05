import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class CorrelationChart extends StatelessWidget {
  const CorrelationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    List<FlSpot> rainSpots = List.generate(weather.weeklyRainfall.length, (i) {
      return FlSpot(i.toDouble(), weather.weeklyRainfall[i]);
    });
    List<FlSpot> alertSpots = List.generate(weather.dailyReportCounts.length, (i) {
      return FlSpot(i.toDouble(), weather.dailyReportCounts[i].toDouble() * 5); // x5 para escala
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Correlação Diária",
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.darkNavy
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,

              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.surfaceDark,
                  tooltipRoundedRadius: 12,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isRain = spot.barIndex == 0;

                      String textoDoBalao = isRain
                          ? spot.y.toStringAsFixed(1)
                          : (spot.y / 5).toInt().toString();

                      return LineTooltipItem(
                        textoDoBalao,
                        TextStyle(
                          color: isRain ? AppColors.alertLow : AppColors.alertHigh,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),

              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: _buildTitles(),
              lineBarsData: [
                //chuva
                LineChartBarData(
                  spots: rainSpots.isEmpty ? const [FlSpot(0, 0)] : rainSpots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: AppColors.alertLow,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.alertLow.withOpacity(0.15),
                  ),
                ),
                //alertas
                LineChartBarData(
                  spots: alertSpots.isEmpty ? const [FlSpot(0, 0)] : alertSpots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: AppColors.alertHigh,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            const days = ['7d', '6d', '5d', '4d', '3d', '2d', 'Ontem', 'Hoje'];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  days[value.toInt()],
                  style: const TextStyle(
                      color: AppColors.textGreyBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
    );
  }
}