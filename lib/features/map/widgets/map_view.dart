import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'package:tcc_alagouai/features/routes/services/route_simulator.dart';
import 'package:tcc_alagouai/features/map/widgets/feedback_popup.dart';
import 'package:tcc_alagouai/features/map/widgets/location_permission_warning.dart';
import 'package:tcc_alagouai/features/map/widgets/report_details_sheet.dart';
import 'package:tcc_alagouai/features/map/widgets/my_location_button.dart';
import 'legend_widget.dart';

class MapView extends StatefulWidget {
  final SafeRouteResult? activeRoute;
  final bool isNavigating;
  final VoidCallback? onRouteFinished;
  final Function(LatLng)? onMapLongPress;

  const MapView({super.key,
    this.activeRoute,
    this.isNavigating = false,
    this.onRouteFinished,
    this.onMapLongPress,});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  GoogleMapController? mapController;

  bool _isInitializing = true;
  bool _hasPermission = true;
  LatLng _userInitialPosition = const LatLng(-29.3385, -49.7291);
  Position? _currentPosition;

  final RouteSimulator _simulator = RouteSimulator();
  final bool _isSimulating = true;

  double _lastValidHeading = 0.0;
  bool _isFinishingRoute = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  //controle do radar/popup
  String? _popupReportId;
  String? _popupStreetName;
  final Set<String> _askedReports = {};
  final List<Map<String, dynamic>> _currentActiveReports = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startLocationUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionStreamSubscription?.cancel();
    _simulator.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates(isBackgroundResume: true);
    }
  }

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != oldWidget.activeRoute && widget.activeRoute != null) {
      _fitRouteOnMap();
    } else if (widget.activeRoute == null && oldWidget.activeRoute != null) {
      _moveCameraToUser();
    }

    //inicio/fim da negagação
    if (widget.isNavigating && !oldWidget.isNavigating) {
      if (_isSimulating && widget.activeRoute != null) {
        //pausa o GPS real e inicia o emulador
        _positionStreamSubscription?.pause();
        _simulator.start(
          points: widget.activeRoute!.points,
          onPositionChanged: (mockPosition) {
            if (!mounted) return;
            setState(() {
              _currentPosition = mockPosition;
              _lastValidHeading = mockPosition.heading;
            });
            _moveCameraToPosition(mockPosition);
            _checkProximityToFloods(mockPosition);
          },
          onFinished: () => _finalizarRota(),
        );
      } else {
        _moveCameraToUser();
      }
    } else if (!widget.isNavigating && oldWidget.isNavigating) {
      if (_isSimulating) {
        _simulator.stop();
        _positionStreamSubscription?.resume();
      }
      _moveCameraToUser();
      _fitRouteOnMap();
    }
  }

  void _checkProximityToFloods(Position position) {
    if (_popupReportId != null) return;

    for (var report in _currentActiveReports) {
      String id = report['id'];
      if (_askedReports.contains(id)) continue;

      double lat = report['lat'];
      double lng = report['lng'];
      double distance = Geolocator.distanceBetween(position.latitude, position.longitude, lat, lng);

      if (distance <= 80.0) {
        setState(() {
          _popupReportId = id;
          _popupStreetName = report['streetName'] ?? 'Rua Desconhecida';
        });
        _askedReports.add(id);
        break;
      }
    }
  }

  void _showReportDetailsSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => ReportDetailsSheet(data: data, currentPosition: _currentPosition),
    );
  }

  Future<void> _startLocationUpdates({bool isBackgroundResume = false}) async {
    if (!mounted) return;
    if (!isBackgroundResume) setState(() { _isInitializing = true; });

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
    } catch (_) {}

    if (mounted) setState(() { _isInitializing = false; });
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((Position position) {
      if (!mounted || _simulator.isRunning) return;

      setState(() {
        _currentPosition = position;
        if (position.speed > 0.5) {
          double diff = (position.heading - _lastValidHeading).abs();
          if (diff > 180.0) diff = 360.0 - diff;
          if (diff > 2.0) _lastValidHeading = position.heading;
        }
      });

      _checkProximityToFloods(position);

      if (widget.isNavigating && widget.activeRoute != null) {
        LatLng destino = widget.activeRoute!.points.last;
        double distancia = Geolocator.distanceBetween(position.latitude, position.longitude, destino.latitude, destino.longitude);
        if (distancia <= 60.0) {
          _finalizarRota();
          return;
        }
      }

      _moveCameraToPosition(position);
    });
  }

  void _moveCameraToPosition(Position position) {
    if (mapController == null) return;
    mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: widget.isNavigating ? 18.5 : 16.0,
          tilt: widget.isNavigating ? 60.0 : 0.0,
          bearing: widget.isNavigating ? _lastValidHeading : 0.0,
        ),
      ),
    );
  }

  Future<void> _moveCameraToUser() async {
    if (_currentPosition != null) _moveCameraToPosition(_currentPosition!);
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
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 80));
  }

  Color _getColor(String level) {
    if (level.toLowerCase() == 'low') return AppColors.alertLow;
    if (level.toLowerCase() == 'medium') return AppColors.alertMedium;
    return AppColors.alertHigh;
  }

  double _getRadius(String level) {
    if (level.toLowerCase() == 'low') return 15.0;
    if (level.toLowerCase() == 'medium') return 20.0;
    return 30.0;
  }

  void _finalizarRota() {
    if (_isFinishingRoute) return;
    _isFinishingRoute = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            onPressed: () {
              Navigator.pop(context);
              _isFinishingRoute = false;
              if (widget.onRouteFinished != null) widget.onRouteFinished!();
            },
            child: const Text("Concluir", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    if (!_hasPermission) return LocationPermissionWarning(onRetry: () => _startLocationUpdates());

    return StreamBuilder<QuerySnapshot>(
      stream: ReportService().getActiveReports(),
      builder: (context, snapshot) {
        Set<Marker> markers = {};
        Set<Circle> circles = {};

        if (snapshot.hasData) {
          _currentActiveReports.clear();
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            _currentActiveReports.add(data);

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
                onTap: () => _showReportDetailsSheet(data),
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
          markers.add(Marker(markerId: const MarkerId('start_point'), position: widget.activeRoute!.points.first, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
          markers.add(Marker(markerId: const MarkerId('end_point'), position: widget.activeRoute!.points.last, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
        }

        if (_isSimulating && _simulator.isRunning && _currentPosition != null) {
          markers.add(Marker(
            markerId: const MarkerId('simulated_car'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            rotation: _lastValidHeading,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            anchor: const Offset(0.5, 0.5),
            zIndexInt: 999,
          ));
        }

        return Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(target: _userInitialPosition, zoom: 16.0),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              buildingsEnabled: false,
              markers: markers,
              circles: circles,
              onLongPress: widget.isNavigating ? null : widget.onMapLongPress,
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

            MyLocationButton(
              isNavigating: widget.isNavigating,
              hasActiveRoute: widget.activeRoute != null,
              onPressed: () => _moveCameraToUser(),
            ),

            if (!widget.isNavigating)
              const Positioned(bottom: 22, left: 32, child: LegendWidget()),

            if (widget.isNavigating && _popupReportId != null)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: FeedbackPopup(
                    reportId: _popupReportId!,
                    streetName: _popupStreetName!,
                    onDismissed: () => setState(() => _popupReportId = null),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}