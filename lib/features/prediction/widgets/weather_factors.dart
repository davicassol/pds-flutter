import 'package:flutter/material.dart';

class WeatherFactors extends StatelessWidget {
  const WeatherFactors({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contributing Factors"),
          SizedBox(height: 12),

          _Item("Heavy Rainfall", "45mm/h", Icons.water_drop),
          _Item("Storm Duration", "3-5 hours", Icons.cloud),
          _Item("Soil Saturation", "92%", Icons.warning),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _Item(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value),
        ],
      ),
    );
  }
}