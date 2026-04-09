import 'package:flutter/material.dart';
import '../widgets/about_header.dart';
import '../widgets/about_hero.dart';
import '../widgets/about_section.dart';
import '../widgets/tech_item.dart';
import '../widgets/version_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: const [
          AboutHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    AboutHero(),
                    SizedBox(height: 16),

                    AboutSection(
                      title: "About This App",
                      content:
                      "Flood Monitor helps residents navigate safely during flood events with real-time monitoring and AI predictions.",
                    ),

                    AboutSection(
                      title: "Our Purpose",
                      content:
                      "Provide citizens with timely information and safer routes during floods.",
                    ),

                    TechList(),

                    VersionInfo(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}