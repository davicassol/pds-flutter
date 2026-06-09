import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class DangerZonesCard extends StatelessWidget {
  const DangerZonesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E44),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F1E44).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Zonas de Maior Risco", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 24),

          if (provider.topDangerZones.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text("Nenhum histórico nesta região.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ),
            )
          else
            ...provider.topDangerZones.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> zone = entry.value;
              return _buildDarkRankingRow(index + 1, zone['name'], zone['count']);
            }),
        ],
      ),
    );
  }

  Widget _buildDarkRankingRow(int position, String name, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.map_rounded, color: Colors.white.withOpacity(0.9), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "$count alertas reais",
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Text(
            "#$position",
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}