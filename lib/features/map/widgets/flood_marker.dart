import 'package:flutter/material.dart';

class FloodMarker extends StatelessWidget {
  final Color color;
  final double top;
  final double left;

  const FloodMarker({
    super.key,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Icon(Icons.location_pin, color: color, size: 30),
        ],
      ),
    );
  }
}