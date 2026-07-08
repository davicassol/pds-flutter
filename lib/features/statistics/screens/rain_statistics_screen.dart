import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/correlation_chart.dart';
import '../widgets/danger_zones_card.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';
import 'package:tcc_alagouai/core/constants/app_colors.dart';

class RainStatisticsScreen extends StatefulWidget {
  const RainStatisticsScreen({super.key});

  @override
  State<RainStatisticsScreen> createState() => _RainStatisticsScreenState();
}

class _RainStatisticsScreenState extends State<RainStatisticsScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData(isBackgroundResume: true);
    }
  }

  Future<void> _loadData({bool isBackgroundResume = false}) async {
    final provider = context.read<WeatherProvider>();

    if (!isBackgroundResume) {
      provider.isLoading = true;
      provider.notifyListeners();
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS desativado");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (isBackgroundResume) throw Exception("Permissão negada (Silencioso)");

        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Permissão negada");
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await provider.fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      provider.errorMessage = "Ative o GPS para monitorar sua região.";
      provider.isLoading = false;
      provider.notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: SafeArea(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : provider.errorMessage != null
              ? _buildEmptyState(provider.errorMessage!, Icons.location_off_rounded)
              : RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primaryBlue,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _buildHeader(provider),
                const SizedBox(height: 30),
                _buildBlueRiskCard(provider),
                const SizedBox(height: 30),
                const CorrelationChart(),
                const SizedBox(height: 30),
                const DangerZonesCard(),
                const SizedBox(height: 20),
                _buildEmergencyContactsCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WeatherProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            "Monitoramento",
            style: TextStyle(color: AppColors.textGreyBlue, fontSize: 13, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 4),
            Text(
              provider.currentLocationName,
              style: const TextStyle(color: AppColors.darkNavy, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlueRiskCard(WeatherProvider provider) {
    double rainToday = provider.weeklyRainfall.isNotEmpty ? provider.weeklyRainfall.last : 0.0;

    Color accentColor = provider.riskLevel.toLowerCase() == 'alto' ? AppColors.alertHigh : AppColors.surfaceWhite;

    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40, top: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceWhite.withOpacity(0.15), width: 1)),
            ),
          ),
          Positioned(
            left: 20, bottom: -80,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceWhite.withOpacity(0.1), width: 1)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.surfaceWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.water_drop, color: accentColor, size: 24),
                    ),
                    Text(provider.lastUpdateTime, style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Risco ${provider.riskLevel}",
                      style: TextStyle(color: accentColor, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    //ativo mostra chuva, se não esconde os dados
                    if (provider.showRainStats)
                      Text(
                        "Previsão: ${rainToday.toStringAsFixed(1)}mm hoje.",
                        style: TextStyle(color: AppColors.textWhite.withOpacity(0.9), fontSize: 14),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.surfaceDark.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_in_talk, color: AppColors.textWhite.withOpacity(0.9), size: 20),
              const SizedBox(width: 12),
              const Text("Emergência", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textWhite)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildEmergencyButton("Defesa Civil", "199", AppColors.surfaceWhite.withOpacity(0.1))),
              const SizedBox(width: 12),
              Expanded(child: _buildEmergencyButton("Bombeiros", "193", AppColors.surfaceWhite.withOpacity(0.1))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(String title, String phone, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () async {
        final Uri launchUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        }
      },
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.primaryBlue.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textGreyBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}