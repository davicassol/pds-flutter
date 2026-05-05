import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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
    _determinePosition(); // Tenta pegar a localização logo ao iniciar
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se o serviço de GPS do celular está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // Verifica as permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Pega a posição atual
    Position position = await Geolocator.getCurrentPosition();

    // Move a câmera do mapa para onde o usuário está de verdade
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15.0, // Zoom mais próximo para ver as ruas
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
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
          markers: {
            const Marker(
              markerId: MarkerId('test_marker'),
              position: LatLng(-29.3400, -49.7300),
              infoWindow: InfoWindow(title: "Área de Risco"),
            ),
          },
        ),
        const Positioned(
          bottom: 24,
          left: 16,
          child: LegendWidget(),
        ),
      ],
    );
  }
}