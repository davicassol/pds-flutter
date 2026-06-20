import 'package:flutter/material.dart';
import '../../features/map/screens/home_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/routes/screens/route_screen.dart';
import '../../features/statistics/screens/rain_statistics_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  //chave de controle para a tela de notificações
  Key _notificationsKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          NotificationsScreen(key: _notificationsKey),
          const RouteScreen(),
          const RainStatisticsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;

            if (index == 1) {
              _notificationsKey = UniqueKey();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alertas"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Rotas"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Dados"),
        ],
      ),
    );
  }
}