import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class WeatherData {
  const WeatherData({
    required this.condition,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.windDirectionDegrees,
    required this.humidity,
    required this.pressure,
    required this.latitude,
    required this.longitude,
    this.windGust,
    this.cloudCover,
    this.precipitation,
  });

  final String condition;
  final double temperature;
  final double windSpeed;
  final String windDirection;
  final int windDirectionDegrees;
  final double humidity;
  final double pressure;
  final double latitude;
  final double longitude;
  final double? windGust;
  final double? cloudCover;
  final double? precipitation;
}

class LocationFix {
  const LocationFix({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class WeatherService {
  final _dio = Dio();

  Future<LocationFix> fetchCurrentPosition() async {
    final position = await _getPosition().timeout(const Duration(seconds: 8));
    return LocationFix(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Uses a recent last-known fix when available, then refreshes with GPS.
  Future<LocationFix> fetchCachedOrCurrentPosition() async {
    if (!kIsWeb) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        final age = DateTime.now().difference(last.timestamp);
        if (age.inMinutes < 30) {
          return LocationFix(
            latitude: last.latitude,
            longitude: last.longitude,
          );
        }
      }
    }
    return fetchCurrentPosition();
  }

  Future<WeatherData> fetchWeatherAt(double lat, double lon) =>
      _fetchWeather(lat, lon);

  Future<WeatherData> fetchCurrentWeather() async {
    double lat, lon;

    try {
      final fix = await fetchCachedOrCurrentPosition()
          .timeout(const Duration(seconds: 8));
      lat = fix.latitude;
      lon = fix.longitude;
    } catch (_) {
      final ipLoc = await _getLocationFromIp();
      lat = ipLoc.$1;
      lon = ipLoc.$2;
    }

    return _fetchWeather(lat, lon);
  }

  Future<String?> reverseGeocode(double lat, double lon) async {
    final resp = await _dio
        .get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'format': 'json',
            'zoom': 14,
          },
          options: Options(
            headers: const {'User-Agent': 'MarksmanMate/1.0 (shoot log)'},
          ),
        )
        .timeout(const Duration(seconds: 8));

    final address = resp.data['address'] as Map<String, dynamic>?;
    if (address == null) return null;

    final parts = <String>[
      if (address['city'] != null) address['city'] as String,
      if (address['town'] != null) address['town'] as String,
      if (address['village'] != null) address['village'] as String,
      if (address['county'] != null) address['county'] as String,
    ];
    if (parts.isNotEmpty) return parts.first;
    return resp.data['display_name'] as String?;
  }

  Future<(double, double)> _getLocationFromIp() async {
    final resp = await _dio
        .get('https://ipapi.co/json/')
        .timeout(const Duration(seconds: 8));
    final lat = (resp.data['latitude'] as num).toDouble();
    final lon = (resp.data['longitude'] as num).toDouble();
    return (lat, lon);
  }

  Future<WeatherData> _fetchWeather(double lat, double lon) async {
    final resp = await _dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current': [
          'temperature_2m',
          'relative_humidity_2m',
          'wind_speed_10m',
          'wind_direction_10m',
          'wind_gusts_10m',
          'surface_pressure',
          'weather_code',
          'cloud_cover',
          'precipitation',
        ].join(','),
        'wind_speed_unit': 'kmh',
        'temperature_unit': 'celsius',
      },
    ).timeout(const Duration(seconds: 10));

    final current = resp.data['current'] as Map<String, dynamic>;
    final windDegrees =
        (current['wind_direction_10m'] as num?)?.round() ?? 0;
    return WeatherData(
      condition: _weatherCodeToString(current['weather_code'] as int),
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: _degreesToCompass(windDegrees.toDouble()),
      windDirectionDegrees: windDegrees,
      humidity: (current['relative_humidity_2m'] as num).toDouble(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      latitude: lat,
      longitude: lon,
      windGust: (current['wind_gusts_10m'] as num?)?.toDouble(),
      cloudCover: (current['cloud_cover'] as num?)?.toDouble(),
      precipitation: (current['precipitation'] as num?)?.toDouble(),
    );
  }

  Future<Position> _getPosition() async {
    if (kIsWeb) {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 7),
        ),
      );
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 7),
      ),
    );
  }

  String _degreesToCompass(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _weatherCodeToString(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 48) return 'Foggy';
    if (code <= 55) return 'Drizzle';
    if (code <= 65) return 'Rain';
    if (code <= 75) return 'Snow';
    if (code <= 82) return 'Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}
