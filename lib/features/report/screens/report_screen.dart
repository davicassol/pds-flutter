import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/report_service.dart';
import '../widgets/photo_upload_widget.dart';
import '../widgets/flood_level_selector.dart';
import '../widgets/info_card.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

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
        SnackBar(
          content: const Text("Aguarde o GPS ou toque no mapa para escolher o local.", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
        SnackBar(
          content: const Text("Alagamento reportado com sucesso!", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reportar Alerta",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.touch_app_rounded, color: AppColors.primaryBlue, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Toque ou arraste no mapa o local exato.",
                            style: TextStyle(
                              color: AppColors.textGreyBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 220,
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
                              mapToolbarEnabled: false,
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
                      ),

                      const SizedBox(height: 20),

                      FloodLevelSelector(
                        selected: floodLevel,
                        onChanged: (value) => setState(() => floodLevel = value),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: AppColors.primaryBlue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: PhotoUploadWidget(
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
                      ),

                      const SizedBox(height: 24),

                      isLoading
                          ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                          : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 6,
                            shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: handleSubmit,
                          child: const Text(
                            "ENVIAR REPORTE",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const ReportInfoCard(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}