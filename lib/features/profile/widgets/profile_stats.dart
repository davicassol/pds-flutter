import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _Item("12", "Reports")),
        SizedBox(width: 10),
        Expanded(child: _Item("45", "Routes")),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String value;
  final String label;

  const _Item(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}