import 'package:flutter/material.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Key Insights"),
          SizedBox(height: 8),
          Text("• Flood risk increases above 40mm"),
          Text("• March has higher rainfall"),
          Text("• 8 floods recorded this week"),
        ],
      ),
    );
  }
}