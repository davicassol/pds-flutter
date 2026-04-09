import 'package:flutter/material.dart';

// IMPORTS DAS TELAS (ajusta os caminhos conforme teu projeto)
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/map/screens/home_screen.dart';
import 'features/report/screens/report_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/routes/screens/route_screen.dart';
import 'features/statistics/screens/rain_statistics_screen.dart';
import 'features/prediction/screens/flood_risk_screen.dart';
import 'features/profile/screens/user_profile_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/about/screens/about_screen.dart';
import 'features/flood_detail/screens/flood_detail_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Flood Monitor',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // 🔥 TELA INICIAL
      initialRoute: "/",

      // 📌 ROTAS DO APP
      routes: {
        "/": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/home": (context) => const HomeScreen(),
        "/report": (context) => const ReportScreen(),
        "/notifications": (context) => const NotificationsScreen(),
        "/route": (context) => const RouteScreen(),
        "/statistics": (context) => const RainStatisticsScreen(),
        "/prediction": (context) => const FloodRiskScreen(),
        "/profile": (context) => const UserProfileScreen(),
        "/settings": (context) => const SettingsScreen(),
        "/about": (context) => const AboutScreen(),
        "/flood-detail": (context) => const FloodDetailScreen(),
      },
    );
  }
}