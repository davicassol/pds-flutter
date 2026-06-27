import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'legend_widget.dart';

class MapView extends StatefulWidget {
  final SafeRouteResult? activeRoute;

  const MapView({super.key, this.activeRoute});

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
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != oldWidget.activeRoute && widget.activeRoute != null) {
      _fitRouteOnMap();
    } else if (widget.activeRoute == null && oldWidget.activeRoute != null) {
      _moveCameraToUser();
    }
  }

  void _fitRouteOnMap() {
    if (widget.activeRoute == null || widget.activeRoute!.points.isEmpty || mapController == null) return;

    double minLat = widget.activeRoute!.points.first.latitude;
    double minLng = widget.activeRoute!.points.first.longitude;
    double maxLat = widget.activeRoute!.points.first.latitude;
    double maxLng = widget.activeRoute!.points.first.longitude;

    for (var point in widget.activeRoute!.points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _moveCameraToUser() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 16.0),
      );
    } catch (e) {
      debugPrint("Erro ao mover para usuário: $e");
    }
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
      if (widget.activeRoute == null) {
        _moveCameraToPosition(position);
      }
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    boxShadow: [BoxShadow(color: AppColors.darkNavy.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
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
            ],
          ),
        );
      },
    );
  }

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
          Text("Nenhuma evidência visual anexada", style: TextStyle(color: AppColors.primaryBlue.withOpacity(0.4), fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
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

              double markerHue = BitmapDescriptor.hueRed; //Alto Risco (Vermelho)

              if (level.toLowerCase() == 'low') {
                markerHue = BitmapDescriptor.hueCyan; //Baixo Risco (Azul Claro)
              } else if (level.toLowerCase() == 'medium') {
                markerHue = BitmapDescriptor.hueOrange; //Médio Risco (Laranja)
              }

              markers.add(Marker(
                markerId: MarkerId(doc.id),
                position: pos,
                icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
                onTap: () => _showReportDetails(context, data),
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

        if (widget.activeRoute != null && widget.activeRoute!.points.isNotEmpty) {
          markers.add(Marker(
            markerId: const MarkerId('start_point'),
            position: widget.activeRoute!.points.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ));
          markers.add(Marker(
            markerId: const MarkerId('end_point'),
            position: widget.activeRoute!.points.last,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ));
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _userInitialPosition, zoom: 16.0),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: markers,
              circles: circles,
              polylines: {
                if (widget.activeRoute != null && widget.activeRoute!.points.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('safe_polyline'),
                    points: widget.activeRoute!.points,
                    color: widget.activeRoute!.floodsCrossed == 0 ? Colors.green : Colors.orangeAccent,
                    width: 6,
                  ),
              },
            ),

            //botão de loc personalizado
            Positioned(
              bottom: widget.activeRoute != null ? 230 : 90,
              right: 16,
              child: FloatingActionButton(
                heroTag: "my_location_btn",
                elevation: 4,
                backgroundColor: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  _moveCameraToUser();
                },
                child: const Icon(Icons.my_location_rounded, color: Colors.black87, size: 26),
              ),
            ),

            const Positioned(bottom: 22, left: 32, child: LegendWidget()),
          ],
        );
      },
    );
  }
}