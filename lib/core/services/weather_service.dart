import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class WeatherData {
  final double temp;
  final String condition;
  final String icon;
  final int humidity;
  final double rain;

  WeatherData({
    required this.temp,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.rain,
  });
}

class WeatherService {
  static const String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  // Backward compatible method for DashboardScreen
  static Future<WeatherData> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
          "$_baseUrl?latitude=$lat&longitude=$lon&current_weather=true&hourly=relative_humidity_2m,precipitation");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        final humidity = data['hourly']['relative_humidity_2m'][0];
        final precipitation = data['hourly']['precipitation'][0];

        return WeatherData(
          temp: current['temperature'],
          condition: _getDisplayCondition(current['weathercode']),
          icon: _getIconName(current['weathercode']),
          humidity: humidity,
          rain: precipitation.toDouble(),
        );
      }
    } catch (e) {
      dev.log("Weather Error: $e");
    }
    return WeatherData(
      temp: 32.0,
      condition: "Sunny",
      icon: "wb_sunny_rounded",
      humidity: 45,
      rain: 0.0,
    );
  }

  static String _getDisplayCondition(int code) {
    if (code == 0) return "Clear Sky";
    if (code <= 3) return "Partly Cloudy";
    if (code <= 48) return "Foggy";
    if (code <= 67) return "Rainy";
    if (code <= 77) return "Snowy";
    if (code <= 99) return "Thunderstorm";
    return "Cloudy";
  }

  static String _getIconName(int code) {
    if (code == 0) return "wb_sunny_rounded";
    if (code <= 3) return "cloud_queue_rounded";
    if (code <= 67) return "water_drop_rounded";
    return "wb_cloudy_rounded";
  }
}
