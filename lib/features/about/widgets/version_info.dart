import 'package:flutter/material.dart';

class VersionInfo extends StatelessWidget {
  const VersionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 16),
        Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
        Text("Build 2026.03.13", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}