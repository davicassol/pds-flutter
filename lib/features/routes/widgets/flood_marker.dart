import 'package:flutter/material.dart';

class FloodMarker extends StatelessWidget {
  final double top;
  final double left;

  const FloodMarker({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.location_on, color: Colors.red),
        ],
      ),
    );
  }
}