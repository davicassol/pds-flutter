import 'package:flutter/material.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool autoLocation = true;
  bool rainForecast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SettingsSection(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              children: [
                SettingsToggle(
                  title: "Flood Alert Notifications",
                  subtitle: "Get alerts for flood warnings",
                  value: notifications,
                  onChanged: (value) {
                    setState(() => notifications = value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            SettingsSection(
              icon: Icons.location_on,
              title: "Location",
              subtitle: "Location detection settings",
              children: [
                SettingsToggle(
                  title: "Automatic Location",
                  subtitle: "Use GPS to detect your location",
                  value: autoLocation,
                  onChanged: (value) {
                    setState(() => autoLocation = value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            SettingsSection(
              icon: Icons.cloud,
              title: "Weather",
              subtitle: "Weather display preferences",
              children: [
                SettingsToggle(
                  title: "Show Rain Forecast",
                  subtitle: "Display rain predictions on map",
                  value: rainForecast,
                  onChanged: (value) {
                    setState(() => rainForecast = value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Changes are saved automatically",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}