import 'package:flutter/material.dart';

class RiskBar extends StatelessWidget {
  const RiskBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Low"),
            Text("Medium"),
            Text("High"),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: const [
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: Colors.green))),
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: Colors.orange))),
              Expanded(child: SizedBox(height: 10, child: ColoredBox(color: Colors.red))),
            ],
          ),
        ),
      ],
    );
  }
}