import 'package:flutter/material.dart';
import 'route_marker.dart';
import 'flood_marker.dart';

class RouteMap extends StatelessWidget {
  const RouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 🟢 ROTA SEGURA (linha verde simples)
          Positioned.fill(
            child: CustomPaint(
              painter: _SimpleRoutePainter(),
            ),
          ),

          // 📍 PONTO INICIAL
          const RouteMarker(
            isStart: true,
            top: 0.2,
            left: 0.3,
          ),

          // 📍 DESTINO
          const RouteMarker(
            isStart: false,
            top: 0.75,
            left: 0.28,
          ),

          // 🔴 ÁREAS ALAGADAS
          const FloodMarker(top: 0.35, left: 0.55),
          const FloodMarker(top: 0.6, left: 0.48),
        ],
      ),
    );
  }
}

class _SimpleRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.28,
      size.height * 0.75,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}