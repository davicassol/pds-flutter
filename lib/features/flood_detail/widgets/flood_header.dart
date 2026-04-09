import 'package:flutter/material.dart';

class FloodHeader extends StatelessWidget {
  const FloodHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Avenida Beira-Mar",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Reported: 5 minutes ago",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}