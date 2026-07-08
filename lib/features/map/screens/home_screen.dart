import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/map_view.dart';
import '../widgets/custom_drawer.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'package:tcc_alagouai/features/routes/widgets/route_header.dart';
import 'package:tcc_alagouai/features/routes/widgets/route_info_card.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';
import 'package:tcc_alagouai/features/notifications/widgets/realtime_alert_listener.dart';
import 'package:tcc_alagouai/features/route_history/services/route_history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SafeRouteResult? _currentRoute;
  bool _isNavigating = false;

  void _clearRoute() {
    setState(() {
      _currentRoute = null;
      _isNavigating = false;
    });
  }

  //manda o serviço salvar e limpa o mapa
  Future<void> _salvarEFinalizarRota() async {
    if (_currentRoute != null && _isNavigating) {
      await RouteHistoryService().saveCompletedRoute(
        route: _currentRoute!,
      );
    }
    _clearRoute();
  }

  @override
  Widget build(BuildContext context) {
    return RealtimeAlertListener(
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: Stack(
          children: [
            Positioned.fill(
              child: MapView(
                activeRoute: _currentRoute,
                isNavigating: _isNavigating,
                onRouteFinished: () {
                  _salvarEFinalizarRota();
                },
                onMapLongPress: (LatLng coordenadasClicadas) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Calculando rota segura..."), duration: Duration(seconds: 1)),
                  );

                  final result = await RouteService().calculateRouteFromMapClick(coordenadasClicadas);

                  if (result != null && result.points.isNotEmpty) {
                    setState(() {
                      _currentRoute = result;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Não foi possível encontrar uma rota para este local.")),
                    );
                  }
                },
              ),
            ),

            if (!_isNavigating)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: RouteHeader(
                    onRouteCalculated: (result) {
                      setState(() {
                        _currentRoute = result;
                      });
                    },
                  ),
                ),
              ),

            if (_currentRoute != null && !_isNavigating)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.down,
                  onDismissed: (direction) {
                    _clearRoute();
                  },
                  child: RouteInfoCard(
                    routeData: _currentRoute!,
                    isNavigating: _isNavigating,
                    onToggleNavigation: () {
                      setState(() {
                        _isNavigating = true;
                      });
                    },
                  ),
                ),
              ),

            if (_isNavigating)
              Positioned(
                bottom: 17,
                left: 70,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 80.0),
                    child: SizedBox(
                      width: 220,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionCancel,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          _salvarEFinalizarRota();
                        },
                        icon: const Icon(Icons.close_rounded, color: AppColors.textWhite),
                        label: const Text(
                            "Sair da Navegação",
                            style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          heroTag: "report_btn",
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          onPressed: () {
            Navigator.pushNamed(context, '/report');
          },
          child: const Icon(Icons.add, color: AppColors.textWhite, size: 28),
        ),
      ),
    );
  }
}