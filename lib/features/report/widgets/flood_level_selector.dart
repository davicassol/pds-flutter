import 'package:flutter/material.dart';

class FloodLevelSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const FloodLevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Widget buildOption(String label, Color color, String value) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Flood Level"),
        const SizedBox(height: 10),
        Row(
          children: [
            buildOption("Low", Colors.yellow, "low"),
            const SizedBox(width: 8),
            buildOption("Medium", Colors.orange, "medium"),
            const SizedBox(width: 8),
            buildOption("High", Colors.red, "high"),
          ],
        ),
      ],
    );
  }
}