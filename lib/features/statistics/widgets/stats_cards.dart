import 'package:flutter/material.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _Card("This Week", "230mm", Icons.calendar_today, Colors.blue)),
        SizedBox(width: 8),
        Expanded(child: _Card("Avg/Day", "33mm", Icons.trending_up, Colors.green)),
        SizedBox(width: 8),
        Expanded(child: _Card("Floods", "8", Icons.water_drop, Colors.red)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}