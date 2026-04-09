import 'package:flutter/material.dart';
import '../widgets/flood_header.dart';
import '../widgets/flood_info_card.dart';
import '../widgets/flood_actions.dart';
import '../widgets/flood_map_preview.dart';

class FloodDetailScreen extends StatelessWidget {
  const FloodDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Flood Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: const [
          FloodMapPreview(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FloodHeader(),
                  FloodInfoCard(),
                  FloodActions(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}