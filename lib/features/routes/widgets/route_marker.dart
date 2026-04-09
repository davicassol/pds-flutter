import 'package:flutter/material.dart';

class RouteMarker extends StatelessWidget {
  final bool isStart;
  final double top;
  final double left;

  const RouteMarker({
    super.key,
    required this.isStart,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isStart ? Colors.green : Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
      ),
    );
  }
}