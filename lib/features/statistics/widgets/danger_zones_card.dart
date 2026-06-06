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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.not_listed_location, color: Colors.redAccent),
              SizedBox(width: 8),
              Text("Zonas de Maior Risco", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Locais com mais alertas no histórico", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          if (provider.topDangerZones.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Nenhum histórico de alagamento nesta região.", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...provider.topDangerZones.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> zone = entry.value;
              return _buildRankingRow(index + 1, zone['name'], zone['count']);
            }),
        ],
      ),
    );
  }

  Widget _buildRankingRow(int position, String name, int count) {
    Color badgeColor = position == 1 ? Colors.red : (position == 2 ? Colors.orange : Colors.amber);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: badgeColor,
            child: Text(position.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text("$count alertas", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}