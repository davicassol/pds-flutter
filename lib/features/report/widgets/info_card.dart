import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class ReportInfoCard extends StatelessWidget {
  const ReportInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryBlue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Seu reporte atualiza o mapa em tempo real e ajuda a traçar rotas seguras para todos.",
              style: TextStyle(color: AppColors.textGreyBlue, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}