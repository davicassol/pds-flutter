import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class RainfallLineChart extends StatelessWidget {
  const RainfallLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    //converte os dados da API para pontos do gráfico
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
          const Text("Volume Diário (mm)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1)),
                titlesData: _buildTitles(),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
              return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
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
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
    ],
  );
}