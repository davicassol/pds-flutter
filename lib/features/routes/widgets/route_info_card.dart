import 'package:flutter/material.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';

class RouteInfoCard extends StatelessWidget {
  final SafeRouteResult routeData;

  const RouteInfoCard({super.key, required this.routeData});

  @override
  Widget build(BuildContext context) {
    bool isCompletelySafe = routeData.floodsCrossed == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem("Tempo", routeData.duration), // Tempo real do Google
              _InfoItem("Distância", routeData.distance), // Distância real
              _StatusBadge(isSafe: isCompletelySafe),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompletelySafe ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompletelySafe
                  ? "Rota segura gerada. Considerando ${routeData.totalFloods} alertas na cidade."
                  : "Cuidado: Esta rota cruza ${routeData.floodsCrossed} ponto(s) de alagamento.",
              style: TextStyle(
                color: isCompletelySafe ? Colors.green[700] : Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isSafe;
  const _StatusBadge({required this.isSafe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
            isSafe ? Icons.check_circle : Icons.warning_rounded,
            color: isSafe ? Colors.green : Colors.orange,
            size: 16
        ),
        const SizedBox(width: 4),
        Text(
          isSafe ? "Rota Segura" : "Alerta",
          style: TextStyle(
            color: isSafe ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}