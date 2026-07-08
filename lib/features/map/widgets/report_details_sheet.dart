import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';

class ReportDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final Position? currentPosition;

  const ReportDetailsSheet({
    super.key,
    required this.data,
    required this.currentPosition,
  });

  Color _getColor(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return AppColors.alertLow;
    if (safeLevel == 'medium') return AppColors.alertMedium;
    return AppColors.alertHigh;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text("Nenhuma evidência visual anexada", style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.4), fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = data['floodLevel'] ?? 'high';
    final street = data['streetName'] ?? 'Rua Desconhecida';
    final imageUrl = data['imageUrl'];
    final userName = data['userName'] ?? 'Anônimo';
    final reportId = data['id'];

    final severityColor = _getColor(level);
    final String nivelTraduzido = level.toLowerCase() == 'low'
        ? "BAIXO RISCO"
        : (level.toLowerCase() == 'medium' ? "MÉDIO RISCO" : "ALTO RISCO");

    double distance = -1;
    if (currentPosition != null && data['lat'] != null && data['lng'] != null) {
      distance = Geolocator.distanceBetween(
        currentPosition!.latitude, currentPosition!.longitude,
        data['lat'], data['lng'],
      );
    }

    bool isCloseEnough = distance >= 0 && distance <= 200.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(nivelTraduzido, style: TextStyle(color: severityColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(street, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.darkNavy, height: 1.1)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_pin_circle_rounded, size: 16, color: AppColors.textGreyBlue),
              const SizedBox(width: 6),
              Text("Reportado por: $userName", style: const TextStyle(fontSize: 14, color: AppColors.textGreyBlue, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),

          if (imageUrl != null && imageUrl.toString().isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.darkNavy.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl, width: double.infinity, height: 280, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                ),
              ),
            )
          else
            _buildImagePlaceholder(),

          const SizedBox(height: 24),

          if (reportId != null) ...[
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                bool isSubmitting = false;

                if (isCloseEnough) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("O local ainda está alagado?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonFeedbackActive,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: isSubmitting ? null : () async {
                                setModalState(() => isSubmitting = true);

                                String? erro = await ReportService().submitFeedback(reportId: reportId, aindaAlagado: true);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(erro ?? "Obrigado por ajudar a comunidade!"),
                                        backgroundColor: erro != null ? Colors.redAccent : AppColors.primaryBlue,
                                        duration: const Duration(seconds: 3),
                                      )
                                  );
                                }
                              },
                              icon: isSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.water_drop_rounded, color: AppColors.textWhite, size: 20),
                              label: const Text("Sim, ainda está", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonFeedbackResolved,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: isSubmitting ? null : () async {
                                setModalState(() => isSubmitting = true);

                                String? erro = await ReportService().submitFeedback(reportId: reportId, aindaAlagado: false);

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(erro ?? "Obrigado por ajudar a comunidade!"),
                                      backgroundColor: erro != null ? Colors.redAccent : AppColors.primaryBlue,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              icon: isSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.check_circle_outline_rounded, color: AppColors.textWhite, size: 20),
                              label: const Text("Não, já secou", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.textGreyBlue, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Aproxime-se do local (menos de 200m) para avaliar a situação do alagamento.",
                            style: TextStyle(color: AppColors.textGreyBlue, fontSize: 13, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}