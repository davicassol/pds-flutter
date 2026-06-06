import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class CorrelationChart extends StatelessWidget {
  const CorrelationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();

    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Correlação Diária", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Chuva (mm) vs Alertas Reais", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(enabled: true),
                titlesData: _buildTitles(),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateGroups(weather),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateGroups(WeatherProvider weather) {
    return List.generate(weather.weeklyRainfall.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: weather.weeklyRainfall[i],
            color: Colors.blue.withOpacity(0.7),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: weather.dailyReportCounts[i].toDouble() * 5,
            color: Colors.red.withOpacity(0.8),
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Chuva (mm)", Colors.blue),
        const SizedBox(width: 20),
        _legendItem("Alertas Reais", Colors.red),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            const days = ['7d', '6d', '5d', '4d', '3d', '2d', 'Ontem', 'Hoje'];
            return Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10));
          },
        ),
      ),
    );
  }
}