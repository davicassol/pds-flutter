import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, "/home");
            break;
          case 1:
            Navigator.pushNamed(context, "/notifications");
            break;
          case 2:
            Navigator.pushNamed(context, "/route");
            break;
          case 3:
            Navigator.pushNamed(context, "/statistics");
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Alerts"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Routes"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
      ],
    );
  }
}