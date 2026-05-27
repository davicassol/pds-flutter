import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';

class RouteMap extends StatefulWidget {
  final List<LatLng> routePoints;

  const RouteMap({
    super.key,
    required this.routePoints,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? mapController;
  final LatLng _fallbackCenter = const LatLng(-29.3385, -49.7291);

  @override
  void initState() {
    super.initState();
    _centerMapOnUser();
  }

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints.isNotEmpty && mapController != null) {
      _fitRouteOnMap();
    }
  }

  // centraliza no GPS do usuário logo de início
  Future<void> _centerMapOnUser() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        if (mapController != null && widget.routePoints.isEmpty) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude),
              15.0,
            ),
          );
        }
      }
    } catch (e) {
      print("Erro ao buscar GPS na tela de rotas: $e");
    }
  }

  // calcula os limites (caixa) para caber a rota inteira na tela
  void _fitRouteOnMap() {
    if (widget.routePoints.isEmpty) return;

    double minLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLat = widget.routePoints.first.latitude;
    double maxLng = widget.routePoints.first.longitude;

    for (var point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  Color _getColor(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return Colors.yellow;
    if (safeLevel == 'medium') return Colors.orange;
    return Colors.red;
  }

  double _getCircleRadius(String level) {
    String safeLevel = level.toLowerCase();
    if (safeLevel == 'low') return 15.0;
    if (safeLevel == 'medium') return 20.0;
    return 30.0; 
  }

  @override
  Widget build(BuildContext context) {
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
              if (level.toString().toLowerCase() == 'low') markerColor = BitmapDescriptor.hueYellow;
              if (level.toString().toLowerCase() == 'medium') markerColor = BitmapDescriptor.hueOrange;

              markers.add(Marker(
                markerId: MarkerId("flood_${doc.id}"),
                position: pos,
                icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
              ));

              circles.add(Circle(
                circleId: CircleId("circle_${doc.id}"),
                center: pos,
                radius: _getCircleRadius(level),
                fillColor: _getColor(level).withValues(alpha: 0.3),
                strokeColor: _getColor(level),
                strokeWidth: 2,
              ));
            }
          }
        }

        if (widget.routePoints.isNotEmpty) {
          markers.add(Marker(
            markerId: const MarkerId('start_point'),
            position: widget.routePoints.first,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ));
          markers.add(Marker(
            markerId: const MarkerId('end_point'),
            position: widget.routePoints.last,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ));
        }

        return GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
            _centerMapOnUser(); // Centraliza logo que o mapa carregar a primeira vez
          },
          initialCameraPosition: CameraPosition(
            target: _fallbackCenter,
            zoom: 14.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: markers,
          circles: circles,
          polylines: {
            if (widget.routePoints.isNotEmpty)
              Polyline(
                polylineId: const PolylineId('safe_polyline'),
                points: widget.routePoints,
                color: Colors.green,
                width: 5,
              ),
          },
        );
      },
    );
  }
}