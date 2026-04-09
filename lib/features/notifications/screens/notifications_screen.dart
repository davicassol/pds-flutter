import 'package:flutter/material.dart';
import '../widgets/notifications_header.dart';
import '../widgets/notification_card.dart';
import '../../../core/widgets/bottom_nav.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "Flood detected near Avenida Beira-Mar",
        "time": "5 minutes ago",
        "severity": "high",
        "location": "Torres, RS",
      },
      {
        "title": "Heavy rain alert",
        "time": "15 minutes ago",
        "severity": "medium",
        "location": "Torres, RS",
      },
      {
        "title": "Flood risk on Rua XV de Novembro",
        "time": "1 hour ago",
        "severity": "high",
        "location": "Torres, RS",
      },
      {
        "title": "Weather warning issued",
        "time": "2 hours ago",
        "severity": "medium",
        "location": "Torres, RS",
      },
      {
        "title": "Flood cleared on Avenida Central",
        "time": "3 hours ago",
        "severity": "low",
        "location": "Torres, RS",
      },
    ];

    return Scaffold(
      body: Column(
        children: [
          const NotificationsHeader(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return NotificationCard(
                  title: item["title"]!,
                  time: item["time"]!,
                  severity: item["severity"]!,
                  location: item["location"]!,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}