import 'package:flutter/material.dart';

class MyLocationButton extends StatelessWidget {
  final bool isNavigating;
  final bool hasActiveRoute;
  final VoidCallback onPressed;

  const MyLocationButton({
    super.key,
    required this.isNavigating,
    required this.hasActiveRoute,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isNavigating) return const SizedBox.shrink();

    return Positioned(
      bottom: hasActiveRoute ? 240 : 90,
      right: 16,
      child: FloatingActionButton(
        heroTag: "my_location_btn",
        elevation: 4,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: onPressed,
        child: const Icon(Icons.my_location_rounded, color: Colors.black87, size: 26),
      ),
    );
  }
}