import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Text(
            "Torres, Brazil",
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
          IconButton(
            icon: const Icon(Icons.warning, color: Colors.blue),
            onPressed: () {
              Navigator.pushNamed(context, '/prediction');
            },
          ),
        ],
      ),
    );
  }
}