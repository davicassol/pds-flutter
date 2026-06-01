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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
        const Text("Nível do Alagamento", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            buildOption("Baixo", Colors.yellow.shade700, "low"),
            const SizedBox(width: 8),
            buildOption("Médio", Colors.orange, "medium"),
            const SizedBox(width: 8),
            buildOption("Alto", Colors.red, "high"),
          ],
        ),
      ],
    );
  }
}