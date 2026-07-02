import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RouteSimulator {
  Timer? _timer;
  int _index = 0;
  double _lastHeading = 0.0;

  //inicia a viagem virtual pelos pontos da rota
  void start({
    required List<LatLng> points,
    required Function(Position position) onPositionChanged,
    required VoidCallback onFinished,
    //intervalo bem rápido (300ms) para dar a sensação de fluidez
    Duration interval = const Duration(milliseconds: 300),
  }) {
    if (points.isEmpty) return;

    _index = 0;
    _timer?.cancel();

    List<LatLng> smoothPoints = _interpolateRoute(points, 10.0);

    _timer = Timer.periodic(interval, (timer) {
      if (_index >= smoothPoints.length) {
        stop();
        onFinished(); //avisa que chegou ao destino
        return;
      }

      LatLng currentPoint = smoothPoints[_index];

      //se houver um próximo ponto, calcula a direção
      if (_index < smoothPoints.length - 1) {
        _lastHeading = _calculateBearing(currentPoint, smoothPoints[_index + 1]);
      }

      //cria um objeto Position "falso" mas com dados válidos
      Position mockPosition = Position(
        latitude: currentPoint.latitude,
        longitude: currentPoint.longitude,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: _lastHeading,
        headingAccuracy: 1.0,
        speed: 11.1, // Simula ~40 km/h
        speedAccuracy: 1.0,
      );

      //entrega a nova posição para o MapView
      onPositionChanged(mockPosition);

      _index++;
    });
  }

  //para o simulador imediatamente
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  //verifica se o simulador está rodando
  bool get isRunning => _timer != null;

  List<LatLng> _interpolateRoute(List<LatLng> originalPoints, double stepMeters) {
    List<LatLng> densePoints = [];

    for (int i = 0; i < originalPoints.length - 1; i++) {
      LatLng start = originalPoints[i];
      LatLng end = originalPoints[i + 1];
      densePoints.add(start);

      //calcula a distância real entre essa esquina e a próxima
      double dist = Geolocator.distanceBetween(
        start.latitude, start.longitude,
        end.latitude, end.longitude,
      );

      //se a distância for maior que o nosso passo, cria pontos no meio
      if (dist > stepMeters) {
        int steps = (dist / stepMeters).floor();
        for (int j = 1; j <= steps; j++) {
          double fraction = j / steps;
          //matemática simples para calcular a coordenada intermediária na reta
          double lat = start.latitude + (end.latitude - start.latitude) * fraction;
          double lng = start.longitude + (end.longitude - start.longitude) * fraction;
          densePoints.add(LatLng(lat, lng));
        }
      }
    }
    //garante que o destino final exato esteja na lista
    densePoints.add(originalPoints.last);

    return densePoints;
  }

  //função matemática para descobrir o ângulo entre duas coordenadas
  double _calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * math.pi / 180.0;
    double lon1 = start.longitude * math.pi / 180.0;
    double lat2 = end.latitude * math.pi / 180.0;
    double lon2 = end.longitude * math.pi / 180.0;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double bearing = math.atan2(y, x);
    return (bearing * 180.0 / math.pi + 360.0) % 360.0;
  }
}