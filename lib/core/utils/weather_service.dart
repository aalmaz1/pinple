import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/constants/campus_constants.dart';

class WeatherData {
  final double temp;
  final String emoji;
  final String description;
  final bool isDay;

  WeatherData({
    required this.temp,
    required this.emoji,
    required this.description,
    required this.isDay,
  });

  factory WeatherData.fromMeteo(Map<String, dynamic> json) {
    final current = json['current'];
    final temp = (current['temperature_2m'] as num).toDouble();
    final code = current['weather_code'] as int;
    final isDay = (current['is_day'] as int) == 1;

    // Map WMO Weather Codes to Emojis and Descriptions
    String emoji = isDay ? '☀️' : '🌙';
    String desc = 'Clear';

    if (code == 0) {
      emoji = isDay ? '☀️' : '🌙';
      desc = 'Clear';
    } else if (code >= 1 && code <= 3) {
      emoji = isDay ? '🌤️' : '☁️';
      desc = 'Cloudy';
    } else if (code >= 45 && code <= 48) {
      emoji = '🌫️';
      desc = 'Foggy';
    } else if (code >= 51 && code <= 55) {
      emoji = '🌦️';
      desc = 'Drizzle';
    } else if (code >= 61 && code <= 67) {
      emoji = '🌧️';
      desc = 'Rainy';
    } else if (code >= 71 && code <= 77) {
      emoji = '❄️';
      desc = 'Snowy';
    } else if (code >= 80 && code <= 82) {
      emoji = '🚿';
      desc = 'Showers';
    } else if (code >= 95 && code <= 99) {
      emoji = '⛈️';
      desc = 'Stormy';
    }

    return WeatherData(temp: temp, emoji: emoji, description: desc, isDay: isDay);
  }
}

final weatherProvider = StreamProvider<WeatherData>((ref) async* {
  const lat = CampusConstants.latitude;
  const lon = CampusConstants.longitude;
  
  // High-accuracy request for Korea
  final url =
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,is_day&models=jma_seamless&timezone=auto';

  while (true) {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        yield WeatherData.fromMeteo(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
    }
    // Update more frequently if needed, 15m is a good balance for accuracy/battery
    await Future.delayed(const Duration(minutes: 15));
  }
});
