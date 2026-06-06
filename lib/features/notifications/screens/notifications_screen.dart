import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/notifications_header.dart';
import '../widgets/notification_card.dart';

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
    //desliga o rastreio do GPS quando o usuário sai da tela
    _positionStream?.cancel();
    super.dispose();
  }

  //Liga o radar do GPS para atualizar a cada 100 metros
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
      print("Erro ao ligar o radar de localização: $e");
    }
  }

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "Agora mesmo";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min atrás";
    if (diff.inHours < 24) return "${diff.inHours}h atrás";
    return "${diff.inDays} dias atrás";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const NotificationsHeader(),

          Expanded(
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                ? const Center(child: Text("Ative o GPS para ver alertas próximos."))
                : _buildRealTimeStream(),
          ),
        ],
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
          print("ERRO NO FIREBASE: ${snapshot.error}");
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text("Erro no Banco: ${snapshot.error}", textAlign: TextAlign.center),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Nenhum alagamento reportado na última hora.");
        }

        List<QueryDocumentSnapshot> nearbyReports = [];

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;

          try {
            //conversão de coordenadas
            double lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
            double lng = (data['lng'] as num?)?.toDouble() ?? 0.0;
            double distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lng,
            );

            if (distanceInMeters <= 5000) {
              nearbyReports.add(doc);
            }
          } catch (e) {
            print("Erro ao processar o documento ${doc.id}: $e");
          }
        }

        if (nearbyReports.isEmpty) {
          return _buildEmptyState("Nenhum alagamento num raio de 5 km da sua região.");
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: nearbyReports.length,
          itemBuilder: (context, index) {
            var data = nearbyReports[index].data() as Map<String, dynamic>;

            DateTime reportTime = DateTime.now();
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              reportTime = (data['timestamp'] as Timestamp).toDate();
            }

            String rua = data['streetName'] ?? "Local desconhecido";
            String nivelAlagamento = data['floodLevel'] ?? "high";

            return NotificationCard(
              title: "Alerta em $rua",
              time: _timeAgo(reportTime),
              severity: nivelAlagamento,
              location: rua,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}