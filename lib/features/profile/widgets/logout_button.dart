import 'package:flutter/material.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onLogout,
      icon: const Icon(Icons.logout_rounded),
      label: const Text("Sair da Conta", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.alertHigh.withOpacity(0.08),
        foregroundColor: AppColors.alertHigh,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}