import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // <--- Importante para o GPS
import 'legend_widget.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;

  // Torres continua aqui apenas como "Plano B" caso o GPS esteja desligado
  final LatLng _fallbackCenter = const LatLng(-29.3385, -49.7291);

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Tenta pegar a localização logo ao iniciar
  }

  /// Função para pedir permissão e pegar a localização atual
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verifica se o serviço de GPS do celular está ligado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // 2. Verifica as permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // 3. Pega a posição atual
    Position position = await Geolocator.getCurrentPosition();

    // 4. Move a câmera do mapa para onde o usuário está de verdade
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15.0, // Zoom mais próximo para ver as ruas
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Tenta mover para a localização assim que o mapa estiver pronto
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _fallbackCenter, // Abre em Torres por 1 segundo enquanto o GPS carrega
            zoom: 14.0,
          ),
          myLocationEnabled: true, // Mostra a bolinha azul
          myLocationButtonEnabled: true, // Botão para centralizar no usuário
          zoomControlsEnabled: false,
          // Aqui você poderá carregar os marcadores do Firebase futuramente
          markers: {
            const Marker(
              markerId: MarkerId('test_marker'),
              position: LatLng(-29.3400, -49.7300),
              infoWindow: InfoWindow(title: "Área de Risco"),
            ),
          },
        ),

        const Positioned(
          top: 16,
          right: 16,
          child: LegendWidget(),
        ),
      ],
    );
  }
}