import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc_alagouai/core/services/open_meteo_service.dart';

class WeatherProvider with ChangeNotifier {
  final OpenMeteoService _meteoService = OpenMeteoService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double? currentTemp;
  int? weatherCode;
  List<double> weeklyRainfall = [];
  List<int> dailyReportCounts = List.filled(8, 0);
  List<Map<String, dynamic>> topDangerZones = [];

  String lastUpdateTime = "--:--";
  String currentLocationName = "Buscando localização...";
  String currentCity = "";
  String riskLevel = "Baixo";
  Color riskColor = Colors.green;

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchWeather(double lat, double lng) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        currentCity = place.subAdministrativeArea ?? place.locality ?? "";
        final subLocality = place.subLocality != null && place.subLocality!.isNotEmpty ? "${place.subLocality}, " : "";
        currentLocationName = "$subLocality$currentCity";
      }

      // Busca os dados de chuva e temperatura na Open-Meteo
      final data = await _meteoService.getWeatherData(lat, lng);
      if (data != null) {
        currentTemp = data['current']['temperature_2m'];
        weatherCode = data['current']['weather_code'];
        List<dynamic> precipitation = data['daily']['precipitation_sum'];
        weeklyRainfall = precipitation.map((e) => (e as num).toDouble()).toList();

        // Calcula o nível de risco com base na chuva de hoje
        _calculateRisk();
      } else {
        weeklyRainfall = List.filled(8, 0.0);
      }

      // Busca a quantidade de alertas reais no Firebase Firestore
      await _fetchFirebaseReports();
      await _fetchDangerZones();

      final agora = DateTime.now();
      final minuto = agora.minute < 10 ? "0${agora.minute}" : "${agora.minute}";
      final hora = agora.hour < 10 ? "0${agora.hour}" : "${agora.hour}";
      lastUpdateTime = "Atualizado às $hora:$minuto";

    } catch (e) {
      errorMessage = "Erro ao sincronizar dados meteorológicos.";
      print("Erro no WeatherProvider: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFirebaseReports() async {
    dailyReportCounts = List.filled(8, 0);

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime sevenDaysAgo = today.subtract(const Duration(days: 7));

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reportes')
          .where('city', isEqualTo: currentCity.toLowerCase())
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc.data() != null && (doc.data() as Map).containsKey('timestamp')) {
          DateTime reportFullDate = (doc['timestamp'] as Timestamp).toDate();
          if (reportFullDate.isBefore(sevenDaysAgo)) {
            continue;
          }

          DateTime reportDay = DateTime(reportFullDate.year, reportFullDate.month, reportFullDate.day);

          int difference = today.difference(reportDay).inDays;

          if (difference >= 0 && difference < 8) {
            dailyReportCounts[7 - difference]++;
          }
        }
      }
    } catch (e) {
      print("Erro ao buscar reports no Firebase: $e");
    }
  }

  //busca as zonas de perigo
  Future<void> _fetchDangerZones() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('reportes')
          .where('city', isEqualTo: currentCity.toLowerCase())
          .get();

      Map<String, int> locationCounts = {};

      for (var doc in querySnapshot.docs) {
        if (doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;

          String locationName = data['streetName'] ?? data['address'] ?? data['neighborhood'] ?? 'Local não especificado';

          if (locationName != 'Local não especificado') {
            locationCounts[locationName] = (locationCounts[locationName] ?? 0) + 1;
          }
        }
      }

      var sortedLocations = locationCounts.keys.toList()
        ..sort((a, b) => locationCounts[b]!.compareTo(locationCounts[a]!));

      topDangerZones = sortedLocations.take(3).map((loc) => {
        'name': loc,
        'count': locationCounts[loc],
      }).toList();

    } catch (e) {
      print("Erro ao buscar ranking de zonas: $e");
    }
  }

  void _calculateRisk() {
    if (weeklyRainfall.isEmpty) return;

    double rainToday = weeklyRainfall.last;

    if (rainToday > 40) {
      riskLevel = "Crítico";
      riskColor = Colors.red;
    } else if (rainToday > 15) {
      riskLevel = "Atenção";
      riskColor = Colors.orange;
    } else {
      riskLevel = "Baixo";
      riskColor = Colors.green;
    }
  }

  String get temperature => currentTemp != null ? "${currentTemp!.round()}°C" : "--";

  String get description {
    if (weatherCode == null) return "Clima não disponível";
    return _translateWeatherCode(weatherCode!);
  }

  String _translateWeatherCode(int code) {
    switch (code) {
      case 0: return "Céu limpo";
      case 1: case 2: case 3: return "Parcialmente nublado";
      case 45: case 48: return "Neblina";
      case 51: case 53: case 55: return "Garoa leve";
      case 56: case 57: return "Garoa congelante";
      case 61: return "Chuva leve";
      case 63: return "Chuva moderada";
      case 65: return "Chuva forte";
      case 66: case 67: return "Chuva congelante";
      case 71: case 73: case 75: return "Neve";
      case 77: return "Granizo miúdo";
      case 80: return "Pancadas de chuva leves";
      case 81: return "Pancadas de chuva moderadas";
      case 82: return "Pancadas de chuva violentas";
      case 85: case 86: return "Pancadas de neve";
      case 95: return "Tempestade com trovões";
      case 96: case 99: return "Tempestade com granizo forte";
      default: return "Clima instável";
    }
  }
}