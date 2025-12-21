import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool loading = true;
  String error = "";
  Map<String, dynamic>? weatherData;

  final String apiKey = "fa707d431f816a5702e5cc81aa790614"; // <--- Your key

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  /// ------------------------------------------
  /// 1️⃣ GET USER LOCATION
  /// ------------------------------------------
  Future<Position?> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  /// ------------------------------------------
  /// 2️⃣ FETCH WEATHER FROM API
  /// ------------------------------------------
  Future<void> fetchWeather() async {
    try {
      Position? pos = await _getLocation();

      if (pos == null) {
        setState(() {
          error = "Location not available";
          loading = false;
        });
        return;
      }

      final url =
          "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&appid=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = "Failed to load weather";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        loading = false;
      });
    }
  }

  /// ------------------------------------------
  /// WEATHER UI BUILDER
  /// ------------------------------------------
  Widget weatherUI() {
    if (weatherData == null) return const SizedBox();

    final main = weatherData!["main"];
    final wind = weatherData!["wind"];
    final weather = weatherData!["weather"][0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          weatherData!["name"],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Icon(
          getWeatherIcon(weather["main"]),
          size: 100,
          color: Colors.blue,
        ),

        const SizedBox(height: 10),

        Text(
          "${main["temp"].toStringAsFixed(1)} °C",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        Text(
          weather["description"].toString().toUpperCase(),
          style: const TextStyle(fontSize: 18),
        ),

        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            infoTile(Icons.water_drop, "Humidity", "${main["humidity"]}%"),
            infoTile(Icons.air, "Wind", "${wind["speed"]} m/s"),
            infoTile(Icons.thermostat, "Feels Like",
                "${main["feels_like"].toStringAsFixed(1)}°C"),
          ],
        ),
      ],
    );
  }

  /// ------------------------------------------
  /// ICON SELECTOR BASED ON WEATHER TYPE
  /// ------------------------------------------
  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case "clear":
        return Icons.wb_sunny;
      case "rain":
        return Icons.umbrella;
      case "clouds":
        return Icons.cloud;
      case "snow":
        return Icons.ac_unit;
      case "thunderstorm":
        return Icons.flash_on;
      default:
        return Icons.cloud_queue;
    }
  }

  /// SMALL INFO BOX
  Widget infoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// ------------------------------------------
  /// MAIN UI
  /// ------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Info"),
        centerTitle: true,
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : error.isNotEmpty
                ? Text(error)
                : weatherUI(),
      ),
    );
  }
}