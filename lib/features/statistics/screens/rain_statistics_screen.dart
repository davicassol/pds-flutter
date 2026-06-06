import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/correlation_chart.dart';
import '../widgets/danger_zones_card.dart';
import 'package:tcc_alagouai/core/providers/weather_provider.dart';

class RainStatisticsScreen extends StatefulWidget {
  const RainStatisticsScreen({super.key});

  @override
  State<RainStatisticsScreen> createState() => _RainStatisticsScreenState();
}

class _RainStatisticsScreenState extends State<RainStatisticsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<WeatherProvider>();
    provider.isLoading = true;
    provider.notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS desativado");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Monitoramento", style: TextStyle(color: Colors.black87, fontSize: 13)),
                Text(
                    provider.isLoading ? "..." : provider.lastUpdateTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.normal)
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    provider.isLoading ? "Buscando..." : provider.currentLocationName,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRiskCard(provider),
            const SizedBox(height: 24),

            // O gráfico duplo de correlação
            const CorrelationChart(),
            const SizedBox(height: 24),

            // O ranking de zonas de perigo
            const DangerZonesCard(),
            const SizedBox(height: 24),
            _buildEmergencyContactsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(WeatherProvider provider) {
    double rainToday = provider.weeklyRainfall.isNotEmpty ? provider.weeklyRainfall.last : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: provider.riskColor.withOpacity(0.1),
        border: Border.all(color: provider.riskColor.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_rounded, color: provider.riskColor, size: 40),
          const SizedBox(height: 8),
          Text(
            "Risco ${provider.riskLevel}",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: provider.riskColor),
          ),
          const SizedBox(height: 8),
          Text(
            "A previsão atual é de ${provider.description.toLowerCase()} com volume de ${rainToday.toStringAsFixed(1)}mm para hoje.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  //widget para os Contatos de Emergência
  Widget _buildEmergencyContactsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_phone, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                "Contatos de Emergência",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[900]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Em caso de alagamento iminente ou perigo extremo, ligue imediatamente:",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyButton("Defesa Civil", "199", Colors.red[800]!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEmergencyButton("Bombeiros", "193", Colors.red[600]!),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(String title, String phone, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () async {
        final Uri launchUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        }
      },
      icon: const Icon(Icons.call, size: 18),
      label: Text(
        "$title ($phone)",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}