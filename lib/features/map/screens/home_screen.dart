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

//controle de navegação
class _HomeScreenState extends State<HomeScreen> {
  SafeRouteResult? _currentRoute;
  bool _isNavigating = false;

  void _clearRoute() {
    setState(() {
      _currentRoute = null;
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapView(
              activeRoute: _currentRoute,
              isNavigating: _isNavigating, //passa o estado pro mapa
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

          //se não estiver navegando mostra o card
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
                      _isNavigating = true; //inicia a navegação
                    });
                  },
                ),
              ),
            ),

          //se estiver navegando mostra o botão de sair
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
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNavigating = false;
                        });
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      label: const Text(
                          "Sair da Navegação",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      //botão de reporte
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
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}