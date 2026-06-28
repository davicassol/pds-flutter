import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tcc_alagouai/features/auth/screens/verify_email_screen.dart';
import 'core/screens/main_layout_screen.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/verify_email_screen.dart';
import 'features/map/screens/home_screen.dart';
import 'features/report/screens/report_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/statistics/screens/rain_statistics_screen.dart';
import 'features/profile/screens/user_profile_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/about/screens/about_screen.dart';
import 'features/flood_detail/screens/flood_detail_screen.dart';
import 'features/splash/splash_screen.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

void main() async {
  //garante que o Flutter e os widgets estejam prontos antes de chamar código nativo
  WidgetsFlutterBinding.ensureInitialized();

  //carrega as chaves do arquivo .env de forma segura antes de rodar o app
  await dotenv.load(fileName: ".env");

  //inicializa o Firebase com as configurações corretas para o Android
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
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

      initialRoute: "/",

      //ROTAS DO APP
      routes: {
        "/": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignUpScreen(),
        "/verify-email": (context) => const VerifyEmailScreen(),
        "/home": (context) => const MainLayoutScreen(),
        "/report": (context) => const ReportScreen(),
        "/notifications": (context) => const NotificationsScreen(),
        "/statistics": (context) => const RainStatisticsScreen(),
        "/profile": (context) => const UserProfileScreen(),
        "/settings": (context) => const SettingsScreen(),
        "/about": (context) => const AboutScreen(),
        "/flood-detail": (context) => const FloodDetailScreen(),
      },
    );
  }
}