import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class LocationPermissionWarning extends StatelessWidget {
  final VoidCallback onRetry;

  const LocationPermissionWarning({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 80, color: AppColors.primaryBlue.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              const Text("Localização Negada", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkNavy), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text("O aplicativo precisa da sua localização para exibir o mapa e calcular as rotas seguras.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.textGreyBlue)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text("Tentar Novamente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () { Geolocator.openAppSettings(); },
                child: const Text("Abrir Configurações", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}