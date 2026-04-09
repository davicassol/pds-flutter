import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../widgets/route_header.dart';
import '../widgets/route_map.dart';
import '../widgets/route_info_card.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          const RouteHeader(),

          Expanded(
            child: Stack(
              children: const [
                RouteMap(),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 90,
                  child: RouteInfoCard(),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}