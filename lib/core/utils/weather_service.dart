import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/constants/campus_constants.dart';

class WeatherData {
  final double temp;
  final String iconCode;

  WeatherData({required this.temp, required this.iconCode});

  factory WeatherData.fromMeteo(Map<String, dynamic> json) {
    final current = json['current'];
    final temp = (current['temperature_2m'] as num).toDouble();
    final code = current['weather_code'] as int;

    // Map WMO Weather Codes to simple icons
    String icon = '01d';
    if (code >= 1 && code <= 3) icon = '02d';
    if (code >= 45 && code <= 48) icon = '50d';
    if (code >= 51 && code <= 67) icon = '10d';
    if (code >= 71 && code <= 77) icon = '13d';
    if (code >= 80 && code <= 99) icon = '11d';

    return WeatherData(temp: temp, iconCode: icon);
  }
}

final weatherProvider = FutureProvider<WeatherData>((ref) async {
  const lat = CampusConstants.latitude;
  const lon = CampusConstants.longitude;

  // Optimized for Korea: Using JMA (Japan Meteorological Agency) high-resolution regional model.
  final url =
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&models=jma_seamless&timezone=auto';

  try {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return WeatherData.fromMeteo(jsonDecode(response.body));
    } else {
      throw Exception('Meteo Regional Error');
    }
  } catch (e) {
    rethrow;
  }
});
