import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class FloodLevelSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const FloodLevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Widget buildOption(String label, Color color, String value, IconData icon) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.darkNavy,
                ),
              ),
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            "Nível do Alagamento",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.darkNavy),
          ),
        ),
        Row(
          children: [
            buildOption("BAIXO", AppColors.alertLow, "low", Icons.waves_rounded),
            const SizedBox(width: 12),
            buildOption("MÉDIO", Colors.orangeAccent, "medium", Icons.water_drop_rounded),
            const SizedBox(width: 12),
            buildOption("ALTO", AppColors.alertHigh, "high", Icons.warning_rounded),
          ],
        ),
      ],
    );
  }
}