import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "YOUR_API_KEY"; // OpenWeather API key

  static Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather"
      "?lat=$lat&lon=$lon&appid=$apiKey&units=metric"
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Weather error: ${response.body}");
      return null;
    }
  }
}