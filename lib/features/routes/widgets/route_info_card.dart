import 'package:flutter/material.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';

class RouteInfoCard extends StatelessWidget {
  final SafeRouteResult routeData;
  final bool isNavigating;
  final VoidCallback onToggleNavigation;

  const RouteInfoCard({
    super.key,
    required this.routeData,
    required this.isNavigating,
    required this.onToggleNavigation,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompletelySafe = routeData.floodsCrossed == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem("Tempo", routeData.duration),
              _InfoItem("Distância", routeData.distance),
              _StatusBadge(isSafe: isCompletelySafe),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
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
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isNavigating ? Colors.redAccent : const Color(0xFF2B66F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: onToggleNavigation,
              icon: Icon(
                  isNavigating ? Icons.close_rounded : Icons.navigation_rounded,
                  color: Colors.white
              ),
              label: Text(
                  isNavigating ? "Sair da Navegação" : "Iniciar Rota",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87)),
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
            size: 18
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