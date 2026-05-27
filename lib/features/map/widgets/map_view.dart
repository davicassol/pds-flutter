import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'legend_widget.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? mapController;

  bool _isInitializing = true;
  LatLng _userInitialPosition = const LatLng(-29.3385, -49.7291);

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isInitializing = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isInitializing = false);
      return;
    }

    try {
      Position? cachedPosition = await Geolocator.getLastKnownPosition();
      Position finalPosition = cachedPosition ?? await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);

      if (mounted) {
        setState(() {
          _userInitialPosition = LatLng(finalPosition.latitude, finalPosition.longitude);
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isInitializing = false);
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _moveCameraToPosition(position);
    });
  }

  void _moveCameraToPosition(Position position) {
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16.0,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Color _getColor(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return Colors.yellow;
    if (safeLevel == 'medium') return Colors.orange;
    return Colors.red;
  }

  double _getRadius(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return 15.0;
    if (safeLevel == 'medium') return 20.0;
    return 30.0;
  }

  // Mostra os detalhes do reporte com foto
  void _showReportDetails(BuildContext context, Map<String, dynamic> data) {
    final level = data['floodLevel'] ?? 'high';
    final street = data['streetName'] ?? 'Rua Desconhecida';
    final imageUrl = data['imageUrl'];
    final userName = data['userName'] ?? 'Anônimo';

    String nivelTraduzido = "Crítico";
    if (level.toLowerCase() == 'low') nivelTraduzido = "Atenção (Baixo)";
    if (level.toLowerCase() == 'medium') nivelTraduzido = "Risco Médio";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nível: $nivelTraduzido",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getColor(level),
                    ),
                  ),
                  const Icon(Icons.water_drop, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                street,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "Reportado por: $userName",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              if (imageUrl != null && imageUrl.toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Erro ao carregar imagem", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Sem foto disponível", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: ReportService().getActiveReports(),
      builder: (context, snapshot) {
        Set<Marker> markers = {};
        Set<Circle> circles = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['lat'] != null && data['lng'] != null) {
              final pos = LatLng(data['lat'], data['lng']);
              final level = data['floodLevel'] ?? 'high';

              double markerColor = BitmapDescriptor.hueRed;

              if (level.toLowerCase() == 'low') {
                markerColor = BitmapDescriptor.hueYellow;
              } else if (level.toLowerCase() == 'medium') {
                markerColor = BitmapDescriptor.hueOrange;
              }

              markers.add(Marker(
                markerId: MarkerId(doc.id),
                position: pos,
                icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
                onTap: () {
                  _showReportDetails(context, data);
                },
              ));

              circles.add(Circle(
                circleId: CircleId("circle_${doc.id}"),
                center: pos,
                radius: _getRadius(level),
                fillColor: _getColor(level).withOpacity(0.3),
                strokeColor: _getColor(level),
                strokeWidth: 2,
              ));
            }
          }
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _userInitialPosition,
                zoom: 16.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: markers,
              circles: circles,
            ),
            const Positioned(
              bottom: 24,
              left: 16,
              child: LegendWidget(),
            ),
          ],
        );
      },
    );
  }
}