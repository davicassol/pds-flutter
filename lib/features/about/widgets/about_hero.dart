import 'package:flutter/material.dart';

class AboutHero extends StatelessWidget {
  const AboutHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.water_drop, color: Colors.blue, size: 30),
          ),
          SizedBox(height: 12),
          Text(
            "Flood Monitor",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          Text(
            "Keeping Torres Safe from Floods",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}