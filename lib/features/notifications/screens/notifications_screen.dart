import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/features/report/screens/report_screen.dart';
import '../widgets/notifications_header.dart';
import '../widgets/notification_card.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS desativado');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permissão negada');
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isLoadingLocation = false;
          });
        }
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      debugPrint("Erro ao ligar o radar de localização: $e");
    }
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "Agora mesmo";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m atrás";
    if (diff.inHours < 24) return "${diff.inHours}h atrás";
    return "${diff.inDays}d atrás";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryBlue,
          elevation: 6,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Reportar",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            );
          },
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NotificationsHeader(),
            const SizedBox(height: 10),

            Expanded(
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : _currentPosition == null
                  ? _buildEmptyState("Ative o GPS para ver alertas próximos.", Icons.location_off_rounded)
                  : _buildRealTimeStream(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeStream() {
    DateTime oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reportes')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(oneHourAgo))
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return _buildEmptyState("Erro de conexão.", Icons.cloud_off_rounded);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Tudo tranquilo nas últimas horas.", Icons.done_all_rounded);
        }

        List<QueryDocumentSnapshot> nearbyReports = [];

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          try {
            double lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
            double lng = (data['lng'] as num?)?.toDouble() ?? 0.0;
            double distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude, _currentPosition!.longitude, lat, lng,
            );

            if (distanceInMeters <= 5000) {
              nearbyReports.add(doc);
            }
          } catch (e) {
            debugPrint("Erro ao processar o documento ${doc.id}: $e");
          }
        }

        if (nearbyReports.isEmpty) {
          return _buildEmptyState("Nenhum alagamento num raio de 5km.", Icons.safety_check_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          itemCount: nearbyReports.length,
          itemBuilder: (context, index) {
            var data = nearbyReports[index].data() as Map<String, dynamic>;

            DateTime reportTime = DateTime.now();
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              reportTime = (data['timestamp'] as Timestamp).toDate();
            }

            String rua = data['streetName'] ?? "Local desconhecido";
            String nivelAlagamento = data['floodLevel'] ?? "high";
            String? imagemAlagamento = data['imageUrl'];

            return NotificationCard(
              title: "Alerta de Alagamento",
              time: _timeAgo(reportTime),
              severity: nivelAlagamento,
              location: rua,
              imageUrl: imagemAlagamento,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primaryBlue.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textGreyBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}