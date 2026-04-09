import 'package:flutter/material.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Column(
        children: const [
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: Colors.red),
              SizedBox(width: 6),
              Text("Flooded"),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: Colors.orange),
              SizedBox(width: 6),
              Text("Risk"),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: Colors.green),
              SizedBox(width: 6),
              Text("Safe"),
            ],
          ),
        ],
      ),
    );
  }
}