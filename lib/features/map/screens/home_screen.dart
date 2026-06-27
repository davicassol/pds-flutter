import 'package:flutter/material.dart';
import '../widgets/map_view.dart';
import '../widgets/custom_drawer.dart';
import 'package:tcc_alagouai/features/routes/services/route_service.dart';
import 'package:tcc_alagouai/features/routes/widgets/route_header.dart';
import 'package:tcc_alagouai/features/routes/widgets/route_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SafeRouteResult? _currentRoute;

  void _clearRoute() {
    setState(() {
      _currentRoute = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(activeRoute: _currentRoute),
          ),

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

          if (_currentRoute != null)
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
                child: RouteInfoCard(routeData: _currentRoute!),
              ),
            ),
        ],
      ),

      //Botão de Reportar
      floatingActionButton: FloatingActionButton(
        heroTag: "report_btn",
        backgroundColor: const Color(0xFF2B66F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}