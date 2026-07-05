import 'package:flutter/material.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

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
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.dividerGrey,
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
              color: isCompletelySafe ? AppColors.successBackground : AppColors.warningBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompletelySafe
                  ? "Rota segura gerada. Considerando ${routeData.totalFloods} alertas na cidade."
                  : "Cuidado: Esta rota cruza ${routeData.floodsCrossed} ponto(s) de alagamento.",
              style: TextStyle(
                color: isCompletelySafe ? AppColors.successText : AppColors.warningText,
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
                backgroundColor: isNavigating ? AppColors.actionCancel : AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: onToggleNavigation,
              icon: Icon(
                  isNavigating ? Icons.close_rounded : Icons.navigation_rounded,
                  color: AppColors.textWhite
              ),
              label: Text(
                  isNavigating ? "Sair da Navegação" : "Iniciar Rota",
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)
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
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGreyMedium, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textBlack)),
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
            color: isSafe ? AppColors.successMain : AppColors.warningMain,
            size: 18
        ),
        const SizedBox(width: 4),
        Text(
          isSafe ? "Rota Segura" : "Alerta",
          style: TextStyle(
            color: isSafe ? AppColors.successMain : AppColors.warningMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}