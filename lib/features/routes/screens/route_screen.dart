import 'package:flutter/material.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import '../widgets/route_header.dart';
import '../widgets/route_map.dart';
import '../widgets/route_info_card.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  SafeRouteResult? _routeResult;

  void _updateRoute(SafeRouteResult newRoute) {
    setState(() {
      _routeResult = newRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          RouteHeader(onRouteCalculated: _updateRoute),

          Expanded(
            child: Stack(
              children: [
                // passa os pontos para o mapa se houver rota
                RouteMap(routePoints: _routeResult?.points ?? []),

                // só mostra o Card se a rota foi calculada
                if (_routeResult != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 90,
                    child: RouteInfoCard(routeData: _routeResult!),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}