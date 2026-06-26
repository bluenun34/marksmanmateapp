class ShootSessionModel {
  const ShootSessionModel({
    required this.id,
    required this.date,
    required this.discipline,
    required this.sessionType,
    this.location,
    this.rangeName,
    this.venueType,
    this.latitude,
    this.longitude,
    this.totalRounds,
    this.totalHits,
    this.totalMisses,
    this.totalScore,
    this.rating,
    this.notes,
    this.weatherCondition,
    this.temperature,
    this.windSpeed,
    this.windDirection,
    this.humidity,
    this.pressure,
    this.updatedAt,
  });

  final int? id;
  final DateTime date;
  final String discipline;
  final String sessionType;
  final String? location;
  final String? rangeName;
  final String? venueType;
  final double? latitude;
  final double? longitude;
  final int? totalRounds;
  final int? totalHits;
  final int? totalMisses;
  final double? totalScore;
  final int? rating;
  final String? notes;
  final String? weatherCondition;
  final double? temperature;
  final double? windSpeed;
  final String? windDirection;
  final double? humidity;
  final double? pressure;
  final DateTime? updatedAt;

  factory ShootSessionModel.fromJson(Map<String, dynamic> json) =>
      ShootSessionModel.fromApiJson(json);

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static ShootSessionModel fromApiJson(Map<String, dynamic> json) {
    final weather = _asMap(json['weather']);
    final totals = _asMap(json['totals']);
    final windDir = weather?['wind_dir'];
    final occurredAt = json['occurred_at'] ?? json['date'];
    if (occurredAt == null) {
      throw const FormatException('Shoot log missing occurred_at');
    }

    return ShootSessionModel(
      id: _asInt(json['id']),
      date: DateTime.parse(occurredAt as String),
      discipline: json['discipline'] as String,
      sessionType: json['session_type'] as String,
      location: json['location'] as String?,
      rangeName: json['range_name'] as String?,
      venueType: json['venue_type'] as String?,
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      totalRounds: _asInt(totals?['rounds'] ?? json['total_rounds']),
      totalHits: _asInt(totals?['hits'] ?? json['total_hits']),
      totalMisses: _asInt(totals?['misses'] ?? json['total_misses']),
      totalScore: _asDouble(totals?['score'] ?? json['total_score']),
      rating: _asInt(json['rating']),
      notes: json['notes'] as String?,
      weatherCondition:
          weather?['condition'] as String? ?? json['weather_condition'] as String?,
      temperature: _asDouble(weather?['temp'] ?? json['temperature']),
      windSpeed: _asDouble(weather?['wind_speed'] ?? json['wind_speed']),
      windDirection: weather?['wind_direction_label'] as String? ??
          (windDir is num ? windDir.toString() : windDir as String?),
      humidity: _asDouble(weather?['humidity'] ?? json['humidity']),
      pressure: _asDouble(weather?['pressure'] ?? json['pressure']),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _asDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
