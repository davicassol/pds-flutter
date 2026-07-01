import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
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
  final bool isNavigating;
  final VoidCallback? onRouteFinished;

  const MapView({super.key, this.activeRoute, this.isNavigating = false, this.onRouteFinished});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  GoogleMapController? mapController;

  bool _isInitializing = true;
  bool _hasPermission = true;
  LatLng _userInitialPosition = const LatLng(-29.3385, -49.7291);

  //BitmapDescriptor? setaNavegacao;
  Position? _currentPosition;

  double _lastValidHeading = 0.0;
  bool _isFinishingRoute = false;

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //_createNavigationIcon();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates(isBackgroundResume: true);
    }
  }

  // Future<void> _createNavigationIcon() async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   const double size = 80.0;
  //
  //   TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   textPainter.text = TextSpan(
  //     text: String.fromCharCode(Icons.navigation.codePoint),
  //     style: TextStyle(fontSize: size, fontFamily: Icons.navigation.fontFamily, color: const Color(0xFF2B66F6)),
  //   );
  //   textPainter.layout();
  //   textPainter.paint(canvas, const Offset(0.0, 0.0));
  //
  //   final ui.Image img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
  //   final ByteData? data = await img.toByteData(format: ui.ImageByteFormat.png);
  //
  //   if (data != null && mounted) {
  //     setState(() {
  //       setaNavegacao = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  //     });
  //   }
  // }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != oldWidget.activeRoute && widget.activeRoute != null) {
      _fitRouteOnMap();
    } else if (widget.activeRoute == null && oldWidget.activeRoute != null) {
      _moveCameraToUser();
    }

    if (widget.isNavigating && !oldWidget.isNavigating) {
      _moveCameraToUser(force3D: true);
    } else if (!widget.isNavigating && oldWidget.isNavigating) {
      //quando sai da navegação, força a voltar pra visão de cima
      _moveCameraToUser();
      _fitRouteOnMap();
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
    LatLngBounds bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  Future<void> _moveCameraToUser({bool force3D = false}) async {
    if (mapController == null || _currentPosition == null) return;

    //força o tilt e o bearing zerarem
    if (force3D || widget.isNavigating) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 18.5,
            tilt: 60.0,
            bearing: _lastValidHeading,
          ),
        ),
      );
    } else {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 16.0,
            tilt: 0.0, //retorna a visão plana
            bearing: 0.0, //retorna o norte para cima
          ),
        ),
      );
    }
  }

  void _finalizarRota() {
    if (_isFinishingRoute) return;
    _isFinishingRoute = true;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Column(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
                SizedBox(height: 16),
                Text("Você chegou!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkNavy)),
              ],
            ),
            content: const Text("Você chegou ao seu destino final.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _isFinishingRoute = false;
                  if (widget.onRouteFinished != null) {
                    widget.onRouteFinished!();
                  }
                },
                child: const Text("Concluir", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
    );
  }

  Future<void> _startLocationUpdates({bool isBackgroundResume = false}) async {
    if (!mounted) return;

    if (!isBackgroundResume) {
      setState(() { _isInitializing = true; });
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _isInitializing = false; _hasPermission = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && !isBackgroundResume) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _isInitializing = false; _hasPermission = false; });
      return;
    }

    if (mounted) setState(() { _hasPermission = true; });

    try {
      Position? cachedPosition = await Geolocator.getLastKnownPosition();
      if (cachedPosition != null && mounted) {
        setState(() {
          _userInitialPosition = LatLng(cachedPosition.latitude, cachedPosition.longitude);
          if (_currentPosition == null) _currentPosition = cachedPosition;
        });
      }
    } catch (e) {
      //ignora e deixa o stream cuidar
    }

    if (mounted) {
      setState(() { _isInitializing = false; });
    }

    _positionStreamSubscription?.cancel();

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        if (position.speed > 0.5) {
          double diff = (position.heading - _lastValidHeading).abs();
          if (diff > 180.0) diff = 360.0 - diff;
          if (diff > 2.0) _lastValidHeading = position.heading;
        }
      });

      if (widget.isNavigating && widget.activeRoute != null) {
        LatLng destino = widget.activeRoute!.points.last;
        double distancia = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          destino.latitude, destino.longitude,
        );

        if (distancia <= 60.0) {
          _finalizarRota();
          return;
        }
      }

      if (widget.isNavigating) {
        _moveCameraToPosition(position);
      } else if (widget.activeRoute == null) {
        _moveCameraToPosition(position);
      }
    });
  }

  void _moveCameraToPosition(Position position) {
    if (mapController != null) {
      if (widget.isNavigating) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.5,
              tilt: 60.0,
              bearing: _lastValidHeading,
            ),
          ),
        );
      } else {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16.0,
              tilt: 0.0,
              bearing: 0.0,
            ),
          ),
        );
      }
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: severityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
                    boxShadow: [BoxShadow(color: AppColors.darkNavy.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
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
        color: AppColors.primaryBlue.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text("Nenhuma evidência visual anexada", style: TextStyle(color: AppColors.primaryBlue.withValues(alpha: 0.4), fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    if (!_hasPermission) {
      return Container(
        color: const Color(0xFFEFF6FF),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_rounded, size: 80, color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                const Text("Localização Negada", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkNavy), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text("O aplicativo precisa da sua localização para exibir o mapa e calcular as rotas seguras.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppColors.textGreyBlue)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () { _startLocationUpdates(); },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text("Tentar Novamente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () { Geolocator.openAppSettings(); },
                  child: const Text("Abrir Configurações", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
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

              double markerHue = BitmapDescriptor.hueRed;
              if (level.toLowerCase() == 'low') markerHue = BitmapDescriptor.hueCyan;
              else if (level.toLowerCase() == 'medium') markerHue = BitmapDescriptor.hueOrange;

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
                fillColor: _getColor(level).withValues(alpha: 0.3),
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

        // if (_currentPosition != null && setaNavegacao != null) {
        //   markers.add(Marker(
        //     markerId: const MarkerId('current_user_location'),
        //     position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        //     rotation: _lastValidHeading,
        //     icon: setaNavegacao!,
        //     anchor: const Offset(0.5, 0.5),
        //     zIndex: 999,
        //   ));
        // }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _userInitialPosition, zoom: 16.0),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              buildingsEnabled: false,
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
            if (!widget.isNavigating)
              Positioned(
                bottom: widget.activeRoute != null ? 240 : 90,
                right: 16,
                child: FloatingActionButton(
                  heroTag: "my_location_btn",
                  elevation: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onPressed: () { _moveCameraToUser(); },
                  child: const Icon(Icons.my_location_rounded, color: Colors.black87, size: 26),
                ),
              ),
            if (!widget.isNavigating)
              const Positioned(bottom: 22, left: 32, child: LegendWidget()),
          ],
        );
      },
    );
  }
}