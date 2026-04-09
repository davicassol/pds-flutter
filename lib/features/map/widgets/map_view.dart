import 'package:flutter/material.dart';
import 'flood_marker.dart';
import 'legend_widget.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final floodedAreas = [
      {"color": Colors.red, "top": 0.45, "left": 0.52},
      {"color": Colors.red, "top": 0.38, "left": 0.48},
      {"color": Colors.orange, "top": 0.55, "left": 0.45},
      {"color": Colors.orange, "top": 0.32, "left": 0.58},
    ];

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        ...floodedAreas.map((area) {
          return FloodMarker(
            color: area["color"] as Color,
            top: area["top"] as double,
            left: area["left"] as double,
          );
        }),

        const Center(
          child: Icon(Icons.my_location, color: Colors.blue),
        ),

        const Positioned(
          top: 20,
          right: 20,
          child: LegendWidget(),
        ),
      ],
    );
  }
}