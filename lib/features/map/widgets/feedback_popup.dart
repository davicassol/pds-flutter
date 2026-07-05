import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';

class FeedbackPopup extends StatefulWidget {
  final String reportId;
  final String streetName;
  final VoidCallback onDismissed;

  const FeedbackPopup({
    super.key,
    required this.reportId,
    required this.streetName,
    required this.onDismissed,
  });

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    //configura o timer de 10 segundos
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {});
    });

    //inicia a contagem decrescente
    _progressController.reverse(from: 1.0);

    //quando o tempo acabar, esconde o card
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _handleVote(bool aindaAlagado) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    _progressController.stop(); //para o tempo enquanto envia

    await ReportService().submitFeedback(
      reportId: widget.reportId,
      aindaAlagado: aindaAlagado,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Obrigado por ajudar a comunidade!"),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 2),
        ),
      );
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //barra de progresso
            LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: AppColors.surfaceGrey,
              color: AppColors.primaryBlue,
              minHeight: 4,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.help_outline_rounded, color: AppColors.primaryBlue, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "O alagamento na ${widget.streetName} ainda está lá?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 20),

                  //botões de Voto
                  Row(
                    children: [
                      //sim
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successMain,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSubmitting ? null : () => _handleVote(true),
                          icon: const Icon(Icons.thumb_up_alt_rounded, color: AppColors.textWhite, size: 20),
                          label: const Text(
                            "Ainda está",
                            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      //não
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.alertMedium,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSubmitting ? null : () => _handleVote(false),
                          icon: const Icon(Icons.thumb_down_alt_rounded, color: AppColors.textWhite, size: 20),
                          label: const Text(
                            "Já secou",
                            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}