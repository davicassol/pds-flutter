import 'dart:math';
import 'package:flutter/material.dart';

class RiskGauge extends StatelessWidget {
  final String riskLevel;

  const RiskGauge({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final percentage = _getPercentage();
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text("Current Risk Level"),
          const SizedBox(height: 4),
          const Text(
            "Based on AI prediction model",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _GaugePainter(percentage, color),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: color, size: 40),
                    Text("$percentage%",
                        style: const TextStyle(fontSize: 28)),
                    Text(
                      "$riskLevel Risk".toUpperCase(),
                      style: TextStyle(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getPercentage() {
    switch (riskLevel) {
      case "high":
        return 85;
      case "medium":
        return 55;
      default:
        return 25;
    }
  }

  Color _getColor() {
    switch (riskLevel) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

class _GaugePainter extends CustomPainter {
  final int percentage;
  final Color color;

  _GaugePainter(this.percentage, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 14.0;
    final radius = size.width / 2 - stroke;

    final center = Offset(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final sweep = 2 * pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}