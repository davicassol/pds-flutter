import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String riskLevel;

  const AlertCard({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final color = riskLevel == "high"
        ? Colors.red
        : riskLevel == "medium"
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Flooding expected soon. Avoid risk areas.",
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}