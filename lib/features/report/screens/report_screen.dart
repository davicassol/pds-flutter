import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/report_service.dart';
import '../widgets/flood_level_selector.dart';
import '../widgets/photo_upload_widget.dart';
import '../../auth/widgets/primary_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String floodLevel = "medium";
  bool isLoading = false;

  File? _selectedImage;

  GoogleMapController? mapController;
  LatLng? selectedLocation;
  final LatLng _fallbackCenter = const LatLng(-29.3385, -49.7291);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 16.0));
    } catch (e) {
      setState(() => selectedLocation = _fallbackCenter);
    }
  }

  void handleSubmit() async {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguarde o GPS ou toque no mapa para escolher o local.")),
      );
      return;
    }

    setState(() { isLoading = true; });
    String? erro = await ReportService().addReport(
      floodLevel: floodLevel,
      selectedLat: selectedLocation!.latitude,
      selectedLng: selectedLocation!.longitude,
      imageFile: _selectedImage,
    );

    if (!mounted) return;
    setState(() { isLoading = false; });

    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alagamento reportado!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Reportar Alagamento",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Toque no mapa para ajustar a localização exata",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: GoogleMap(
                              onMapCreated: (controller) => mapController = controller,
                              initialCameraPosition: CameraPosition(
                                target: selectedLocation ?? _fallbackCenter,
                                zoom: 15.0,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: false,
                              onTap: (newPosition) {
                                setState(() { selectedLocation = newPosition; });
                              },
                              markers: selectedLocation == null ? {} : {
                                Marker(
                                  markerId: const MarkerId('selected_pos'),
                                  position: selectedLocation!,
                                  draggable: true,
                                  onDragEnd: (newPosition) {
                                    setState(() { selectedLocation = newPosition; });
                                  },
                                ),
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        FloodLevelSelector(
                          selected: floodLevel,
                          onChanged: (value) => setState(() => floodLevel = value),
                        ),

                        const SizedBox(height: 20),
                        PhotoUploadWidget(
                          photo: _selectedImage?.path,
                          onChanged: (caminhoDaFoto) {
                            setState(() {
                              if (caminhoDaFoto != null) {
                                _selectedImage = File(caminhoDaFoto);
                              } else {
                                _selectedImage = null;
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        isLoading
                            ? const CircularProgressIndicator(color: Colors.blue)
                            : PrimaryButton(
                          text: "Enviar Reporte",
                          onPressed: handleSubmit,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Seu reporte ajuda a manter a comunidade informada sobre os alagamentos em tempo real.",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}