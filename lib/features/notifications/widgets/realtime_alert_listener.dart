import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class RealtimeAlertListener extends StatefulWidget {
  final Widget child;

  const RealtimeAlertListener({super.key, required this.child});

  @override
  State<RealtimeAlertListener> createState() => _RealtimeAlertListenerState();
}

class _RealtimeAlertListenerState extends State<RealtimeAlertListener> {
  StreamSubscription? _alertsSubscription;
  final Set<String> _knownReportIds = {};
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _startRealtimeAlerts();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }

  void _startRealtimeAlerts() {
    _alertsSubscription = ReportService().getActiveReports().listen((snapshot) async {

      if (_isFirstLoad) {
        for (var doc in snapshot.docs) {
          _knownReportIds.add(doc.id);
        }
        _isFirstLoad = false;
        return;
      }

      for (var doc in snapshot.docs) {
        if (!_knownReportIds.contains(doc.id)) {
          _knownReportIds.add(doc.id);

          final data = doc.data() as Map<String, dynamic>;
          double floodLat = data['lat'];
          double floodLng = data['lng'];
          String streetName = data['streetName'] ?? 'Rua próxima';

          _checkProximityAndNotify(floodLat, floodLng, streetName);
        }
      }
    });
  }

  Future<void> _checkProximityAndNotify(double floodLat, double floodLng, String streetName) async {
    try {
      Position currentPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      double distanceInMeters = Geolocator.distanceBetween(
          currentPos.latitude, currentPos.longitude,
          floodLat, floodLng
      );

      if (distanceInMeters <= 5000.0) {
        _showNewAlertPopup(streetName, distanceInMeters);
      }
    } catch (e) {
      debugPrint("Erro ao checar proximidade do novo alerta: $e");
    }
  }

  void _showNewAlertPopup(String streetName, double distanceInMeters) {
    if (!mounted) return;

    String distanceText = distanceInMeters > 1000
        ? "${(distanceInMeters / 1000).toStringAsFixed(1)} km"
        : "${distanceInMeters.toInt()} m";

    final screenHeight = MediaQuery.of(context).size.height;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        //empurra o alerta para o topo
        margin: EdgeInsets.only(
            bottom: screenHeight - 200,
            left: 16,
            right: 16
        ),
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 6),
        backgroundColor: AppColors.notificationBackground,
        elevation: 8, // Sombra suave
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.alertHigh.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.alertHigh,
                  size: 28
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      "Novo alagamento",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.notificationTitle
                      )
                  ),
                  const SizedBox(height: 2),
                  Text(
                      "$streetName (a $distanceText)",
                      style: const TextStyle(
                          color: AppColors.notificationSubtitle,
                          fontSize: 14
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}