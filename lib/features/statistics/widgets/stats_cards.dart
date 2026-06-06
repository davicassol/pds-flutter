import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    double totalRain = 0.0;
    if (weather.weeklyRainfall.isNotEmpty) {
      //soma todos os valores da semana
      totalRain = weather.weeklyRainfall.reduce((a, b) => a + b);
    }
    //calcula a média diária
    double avgRain = totalRain / 7;

    return Row(
      children: [
        Expanded(
          child: _Card(
            "Esta Semana",
            weather.isLoading ? "..." : "${totalRain.toStringAsFixed(1)}mm",
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Card(
            "Média/Dia",
            weather.isLoading ? "..." : "${avgRain.toStringAsFixed(1)}mm",
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          //continua mocado só até nós ligar o Firebase nele!
          child: _Card("Alagamentos", "8", Icons.water_drop, Colors.red),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _Card(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}