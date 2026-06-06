import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoService {
  Future<Map<String, dynamic>?> getWeatherData(double lat, double lng) async {
    // Parâmetros: current=temperature_2m,weather_code (Clima Agora)
    // Parâmetros: daily=precipitation_sum (Chuva Histórica)
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code&daily=precipitation_sum&past_days=7&forecast_days=1&timezone=America/Sao_Paulo');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Erro na Open-Meteo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }
}