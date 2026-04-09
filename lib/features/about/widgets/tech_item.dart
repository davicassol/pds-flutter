import 'package:flutter/material.dart';

class TechList extends StatelessWidget {
  const TechList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _Item("Maps & Routing API", Icons.map),
        _Item("Weather API", Icons.cloud),
        _Item("AI Prediction", Icons.psychology),
        _Item("Flutter", Icons.phone_android),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final IconData icon;

  const _Item(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}