import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    double maxRain = weather.weeklyRainfall.isNotEmpty
        ? weather.weeklyRainfall.reduce((curr, next) => curr > next ? curr : next)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[900]!, Colors.blue[700]!]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow, size: 20),
              SizedBox(width: 8),
              Text("Destaques da Semana", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          _insightRow("O maior volume registrado foi de ${maxRain.toStringAsFixed(1)}mm."),
          _insightRow(maxRain > 40 ? "Risco de alagamento detectado nos picos de chuva." : "Volumes dentro da normalidade para esta semana."),
          _insightRow("A média diária está em ${(maxRain/7).toStringAsFixed(1)}mm."),
        ],
      ),
    );
  }

  Widget _insightRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("• $text", style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}