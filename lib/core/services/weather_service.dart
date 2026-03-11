import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temp;
  final String condition;
  final String icon;

  WeatherData({required this.temp, required this.condition, required this.icon});
}

class WeatherService {
  static Future<WeatherData> getWeather(double lat, double lon) async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code');
    print("Weather API Request: $url");
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final temp = (current['temperature_2m'] as num).toDouble();
        final code = current['weather_code'] as int;
        
        return _mapWeatherCodeToData(temp, code);
      }
      throw Exception('Failed to load weather');
    } catch (e) {
      print("Weather Error: $e");
      return WeatherData(temp: 25.0, condition: "Unknown", icon: "wb_cloudy_rounded");
    }
  }

  static WeatherData _mapWeatherCodeToData(double temp, int code) {
    String condition = "Clear";
    String icon = "wb_sunny_rounded";

    if (code >= 1 && code <= 3) {
      condition = "Partly Cloudy";
      icon = "cloud_queue_rounded";
    } else if (code >= 45) {
      condition = "Overcast";
      icon = "cloud_rounded";
    } else if (code >= 51) {
      condition = "Rainy";
      icon = "water_drop_rounded";
    }

    return WeatherData(temp: temp, condition: condition, icon: icon);
  }
}
