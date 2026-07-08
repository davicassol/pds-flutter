import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tcc_alagouai/features/report/services/report_service.dart';

class SafeRouteResult {
  final List<LatLng> points;
  final String encodedPolyline;
  final String distance;
  final String duration;
  final int floodsCrossed;
  final int totalFloods;
  final double score;
  final LatLng? criticalFlood;

  SafeRouteResult({
    required this.points,
    required this.encodedPolyline,
    required this.distance,
    required this.duration,
    required this.floodsCrossed,
    required this.totalFloods,
    required this.score,
    this.criticalFlood,
  });
}

class RouteService {
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? "";

  //calcula rota com o longclicker
  Future<SafeRouteResult?> calculateRouteFromMapClick(LatLng destination) async {
    try {
      //mesma lógica pela searchbar
      Position currentPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng originLatLng = LatLng(currentPos.latitude, currentPos.longitude);

      final floodSnapshot = await ReportService().getActiveReports().first;
      List<Map<String, dynamic>> activeFloods = [];

      for (var doc in floodSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['lat'] != null && data['lng'] != null) {
          activeFloods.add(data);
        }
      }

      //usa a função principal de rotas para calcular o caminho
      return await getRoute(originLatLng, destination, activeFloods);

    } catch (e) {
      print("Erro ao calcular rota pelo clique no mapa: $e");
      return null;
    }
  }

  bool _isPointInFlood(LatLng routePoint, double floodLat, double floodLng, double toleranceMeters) {
    double distance = Geolocator.distanceBetween(
        routePoint.latitude, routePoint.longitude,
        floodLat, floodLng
    );
    return distance <= toleranceMeters;
  }

  List<LatLng> _generateEscapePoints(LatLng center, double distanceInMeters) {
    double latOffset = distanceInMeters / 111320.0;
    double lngOffset = distanceInMeters / (40075000.0 * math.cos(center.latitude * math.pi / 180) / 360.0);

    return [
      LatLng(center.latitude + latOffset, center.longitude), // Norte
      LatLng(center.latitude - latOffset, center.longitude), // Sul
      LatLng(center.latitude, center.longitude + lngOffset), // Leste
      LatLng(center.latitude, center.longitude - lngOffset), // Oeste
      LatLng(center.latitude + latOffset, center.longitude + lngOffset), // Nordeste
      LatLng(center.latitude + latOffset, center.longitude - lngOffset), // Noroeste
      LatLng(center.latitude - latOffset, center.longitude + lngOffset), // Sudeste
      LatLng(center.latitude - latOffset, center.longitude - lngOffset), // Sudoeste
    ];
  }

  //preenche retas longas com pontos intermediários
  List<LatLng> _densifyRoute(List<LatLng> route, double maxDistanceMeters) {
    List<LatLng> denseRoute = [];
    if (route.isEmpty) return denseRoute;

    for (int i = 0; i < route.length - 1; i++) {
      LatLng p1 = route[i];
      LatLng p2 = route[i + 1];
      denseRoute.add(p1);

      double dist = Geolocator.distanceBetween(
          p1.latitude, p1.longitude, p2.latitude, p2.longitude);

      if (dist > maxDistanceMeters) {
        int numPoints = (dist / maxDistanceMeters).ceil();
        for (int j = 1; j < numPoints; j++) {
          double fraction = j / numPoints;
          double lat = p1.latitude + (p2.latitude - p1.latitude) * fraction;
          double lng = p1.longitude + (p2.longitude - p1.longitude) * fraction;
          denseRoute.add(LatLng(lat, lng));
        }
      }
    }
    denseRoute.add(route.last); //adiciona o último ponto da rota original
    return denseRoute;
  }

  Future<SafeRouteResult?> getRoute(
      LatLng origin,
      LatLng destination,
      List<Map<String, dynamic>> activeFloods
      ) async {
    if (apiKey.isEmpty) return null;

    SafeRouteResult? originalRoute = await _fetchAndScoreRoute(origin, destination, activeFloods, null);

    if (originalRoute == null || originalRoute.floodsCrossed == 0) {
      return originalRoute;
    }

    print("Rota cruzou ${originalRoute.floodsCrossed} alagamentos. Ativando Radar Octogonal de Desvio");

    LatLng problemArea = originalRoute.criticalFlood ?? LatLng(activeFloods.first['lat'], activeFloods.first['lng']);

    List<LatLng> escapePoints = _generateEscapePoints(problemArea, 100);

    SafeRouteResult? bestDetour;
    double bestDetourScore = double.infinity;

    for (var escapePoint in escapePoints) {
      SafeRouteResult? detourAttempt = await _fetchAndScoreRoute(origin, destination, activeFloods, escapePoint);

      if (detourAttempt != null) {
        if (detourAttempt.floodsCrossed == 0) {
          print("Desvio Encontrado! Contornando o alagamento");
          return detourAttempt;
        }

        if (detourAttempt.score < bestDetourScore) {
          bestDetourScore = detourAttempt.score;
          bestDetour = detourAttempt;
        }
      }
    }

    if (bestDetour != null && bestDetour.score < originalRoute.score) {
      print("Desvio imperfeito usado. Tem água, mas é menos perigoso que a rota original");
      return bestDetour;
    }

    print("Bairro isolado. Mantendo rota original com alerta vermelho.");
    return originalRoute;
  }

  Future<SafeRouteResult?> _fetchAndScoreRoute(
      LatLng origin, LatLng destination, List<Map<String, dynamic>> activeFloods, LatLng? waypoint) async {

    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&alternatives=true&key=$apiKey';

    if (waypoint != null) {
      url += '&waypoints=via:${waypoint.latitude},${waypoint.longitude}';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final routes = data['routes'] as List;
      if (routes.isEmpty) return null;

      List<LatLng> bestRoute = [];
      double bestScore = double.infinity;
      String bestDistance = "";
      String bestDuration = "";
      int bestFloodsHit = 0;
      LatLng? worstFloodHit;
      String bestPolyline = "";

      for (var route in routes) {
        double baseDistance = (route['legs'][0]['distance']['value']).toDouble();
        String currentDistanceText = route['legs'][0]['distance']['text'];
        String currentDurationText = route['legs'][0]['duration']['text'];
        String encodedPolyline = route['overview_polyline']['points'];
        List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);
        List<LatLng> currentRouteCoords = decodedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

        //cria pontos a cada 15 metros para identificar alagamentos na rota
        List<LatLng> denseRouteCoords = _densifyRoute(currentRouteCoords, 15.0);

        double penaltyScore = 0;
        Set<int> floodsHit = {};
        LatLng? localWorstFlood;
        double highestPenalty = 0;

        //for percorre toda rota
        for (var coord in denseRouteCoords) {
          for (int i = 0; i < activeFloods.length; i++) {
            if (floodsHit.contains(i)) continue;

            var flood = activeFloods[i];
            String safeLevel = (flood['floodLevel'] ?? 'high').toLowerCase();

            //margens de colisão
            double tolerance = safeLevel == 'low' ? 15.0 : (safeLevel == 'medium' ? 20.0 : 30.0);
            //sistema de score da rota
            if (_isPointInFlood(coord, flood['lat'], flood['lng'], tolerance)) {
              floodsHit.add(i);
              double currentPenalty = 0;

              if (safeLevel == 'high') {
                currentPenalty = 99000000.0;
              } else if (safeLevel == 'medium') {
                currentPenalty = 50000.0;
              } else {
                currentPenalty = 10000.0;
              }

              penaltyScore += currentPenalty;

              if (currentPenalty > highestPenalty) {
                highestPenalty = currentPenalty;
                localWorstFlood = LatLng(flood['lat'], flood['lng']);
              }
            }
          }
        }

        double totalRouteScore = baseDistance + penaltyScore;

        if (totalRouteScore < bestScore) {
          bestScore = totalRouteScore;
          bestRoute = currentRouteCoords;
          bestDistance = currentDistanceText;
          bestDuration = currentDurationText;
          bestFloodsHit = floodsHit.length;
          worstFloodHit = localWorstFlood;
          bestPolyline = encodedPolyline;
        }
      }

      return SafeRouteResult(
        points: bestRoute,
        encodedPolyline: bestPolyline,
        distance: bestDistance,
        duration: bestDuration,
        floodsCrossed: bestFloodsHit,
        totalFloods: activeFloods.length,
        score: bestScore,
        criticalFlood: worstFloodHit,
      );
    } catch (e) {
      return null;
    }
  }
}