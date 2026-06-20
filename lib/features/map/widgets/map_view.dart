import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
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
    if (safeLevel == 'low') return AppColors.alertLow;
    if (safeLevel == 'medium') return AppColors.alertMedium;
    return AppColors.alertHigh;
  }

  double _getRadius(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return 15.0;
    if (safeLevel == 'medium') return 20.0;
    return 30.0;
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> data) {
    final level = data['floodLevel'] ?? 'high';
    final street = data['streetName'] ?? 'Rua Desconhecida';
    final imageUrl = data['imageUrl'];
    final userName = data['userName'] ?? 'Anônimo';

    final severityColor = _getColor(level);
    final String nivelTraduzido = level.toLowerCase() == 'low'
        ? "BAIXO RISCO"
        : (level.toLowerCase() == 'medium' ? "MÉDIO RISCO" : "ALTO RISCO");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //Tag de Severidade com a Bolinha
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nivelTraduzido,
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              //Nome da rua em destaque
              Text(
                street,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkNavy,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              //Identificação do usuário criador do alerta
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_rounded, size: 16, color: AppColors.textGreyBlue),
                  const SizedBox(width: 6),
                  Text(
                    "Reportado por: $userName",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGreyBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              //Renderização inteligente da imagem
              if (imageUrl != null && imageUrl.toString().isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkNavy.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 280,
                          width: double.infinity,
                          color: Colors.grey[50],
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryBlue),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    ),
                  ),
                )
              else
                _buildImagePlaceholder(),
            ],
          ),
        );
      },
    );
  }

  //Placeholder moderno para reportes que não possuem foto
  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.primaryBlue.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text(
            "Nenhuma evidência visual anexada",
            style: TextStyle(
              color: AppColors.primaryBlue.withOpacity(0.4),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
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