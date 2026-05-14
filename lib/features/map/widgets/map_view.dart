import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../report/services/report_service.dart';
import 'legend_widget.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  final LatLng _fallbackCenter = const LatLng(-29.3385, -49.7291);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16.0,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _determinePosition();
  }

  // Define a cor baseada no nível do alagamento
  Color _getColor(String level) {
    if (level.toLowerCase() == 'low') return Colors.yellow;
    if (level.toLowerCase() == 'medium') return Colors.orange;
    return Colors.red;
  }

  // Define o raio da mancha
  double _getRadius(String level) {
    if (level.toLowerCase() == 'low') return 15.0;
    if (level.toLowerCase() == 'medium') return 30.0;
    return 50.0;
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

              final level = data['floodLevel'] ?? 'medium';
              final street = data['streetName'] ?? 'Rua Desconhecida';

              // Cria o PINO
              markers.add(Marker(
                markerId: MarkerId(doc.id),
                position: pos,
                infoWindow: InfoWindow(title: "Rua: $street"),
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
                target: _fallbackCenter,
                zoom: 14.0,
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