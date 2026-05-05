import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/map_view.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      body: Stack(
        children: [
          const Positioned.fill(
            child: MapView(),
          ),
          Column(
            children: const [
              HomeHeader(),
              SizedBox(height: 20),
              SearchBarWidget(),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}