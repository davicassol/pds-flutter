import 'package:flutter/material.dart';

class FloodMapPreview extends StatelessWidget {
  const FloodMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.blue[100],
      child: const Center(
        child: Icon(Icons.map, size: 60, color: Colors.blue),
      ),
    );
  }
}