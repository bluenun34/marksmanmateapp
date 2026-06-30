import '../../shared/models/shoot_session_model.dart';

/// Builds the Laravel mobile API payload for creating/syncing a shoot session.
Map<String, dynamic> buildShootSessionPayload({
  required DateTime date,
  required String discipline,
  required String sessionType,
  String? location,
  String? rangeName,
  String? venueType,
  double? latitude,
  double? longitude,
  int? firearmId,
  int? ammoLoadId,
  List<int> equipmentIds = const [],
  int? totalRounds,
  int? totalHits,
  int? totalMisses,
  double? totalScore,
  int? rating,
  String? notes,
  String? weatherCondition,
  double? temperature,
  double? windSpeed,
  String? windDirection,
  double? humidity,
  double? pressure,
  Map<String, dynamic>? disciplineData,
  double? distance,
  String? distanceUnit,
  String? targetType,
  String? stageName,
  double? groupSize,
  String? groupSizeUnit,
  int? eventId,
  String? visibilityOverride,
}) {
  final entry = <String, dynamic>{
    if (firearmId != null) 'firearm_id': firearmId,
    if (ammoLoadId != null) 'ammo_load_id': ammoLoadId,
    if (totalRounds != null) 'rounds_fired': totalRounds,
    if (totalHits != null) 'hits': totalHits,
    if (totalMisses != null) 'misses': totalMisses,
    if (totalScore != null) 'score': totalScore,
    if (equipmentIds.isNotEmpty) 'equipment_ids': equipmentIds,
    if (distance != null) 'distance': distance,
    if (distanceUnit != null && distanceUnit.isNotEmpty)
      'distance_unit': distanceUnit,
    if (targetType != null && targetType.isNotEmpty) 'target_type': targetType,
    if (stageName != null && stageName.isNotEmpty) 'stage_name': stageName,
    if (groupSize != null) 'group_size': groupSize,
    if (groupSizeUnit != null && groupSizeUnit.isNotEmpty)
      'group_size_unit': groupSizeUnit,
  };

  Map<String, dynamic>? cleanedDisciplineData;
  if (disciplineData != null) {
    cleanedDisciplineData = Map<String, dynamic>.from(disciplineData)
      ..removeWhere(
        (_, value) =>
            value == null ||
            (value is String && value.trim().isEmpty),
      );
    if (cleanedDisciplineData.isEmpty) cleanedDisciplineData = null;
  }

  return {
    'occurred_at': date.toIso8601String(),
    'discipline': discipline,
    'session_type': sessionType,
    if (location != null && location.isNotEmpty) 'location': location,
    if (rangeName != null && rangeName.isNotEmpty) 'range_name': rangeName,
    if (venueType != null && venueType.isNotEmpty) 'venue_type': venueType,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (totalHits != null) 'total_hits': totalHits,
    if (totalMisses != null) 'total_misses': totalMisses,
    if (totalScore != null) 'total_score': totalScore,
    if (rating != null && rating > 0) 'rating': rating,
    if (notes != null && notes.isNotEmpty) 'notes': notes,
    if (weatherCondition != null && weatherCondition.isNotEmpty)
      'weather_condition': weatherCondition,
    if (temperature != null) 'weather_temp': temperature,
    if (windSpeed != null) 'weather_wind_speed': windSpeed,
    if (windDirectionToDegrees(windDirection) != null)
      'weather_wind_dir': windDirectionToDegrees(windDirection),
    if (humidity != null) 'weather_humidity': humidity.round(),
    if (pressure != null) 'weather_pressure': pressure,
    if (cleanedDisciplineData != null && cleanedDisciplineData.isNotEmpty)
      'discipline_data': cleanedDisciplineData,
    if (eventId != null) 'event_id': eventId,
    if (visibilityOverride != null && visibilityOverride.isNotEmpty)
      'visibility_override': visibilityOverride,
    if (entry.isNotEmpty) 'entries': [entry],
  };
}

int? windDirectionToDegrees(String? direction) {
  if (direction == null || direction.isEmpty) return null;
  final degreeMatch = RegExp(r'\((\d+)°\)').firstMatch(direction);
  if (degreeMatch != null) {
    return int.tryParse(degreeMatch.group(1)!);
  }
  final parsed = int.tryParse(direction);
  if (parsed != null && parsed >= 0 && parsed <= 360) return parsed;
  const compass = {
    'N': 0,
    'NE': 45,
    'E': 90,
    'SE': 135,
    'S': 180,
    'SW': 225,
    'W': 270,
    'NW': 315,
  };
  return compass[direction.toUpperCase()];
}

Map<String, dynamic> shootSessionToPayload({
  required DateTime date,
  required String discipline,
  required String sessionType,
  String? location,
  String? rangeName,
  String? venueType,
  double? latitude,
  double? longitude,
  int? firearmId,
  int? ammoLoadId,
  List<int> equipmentIds = const [],
  int? totalRounds,
  int? totalHits,
  int? totalMisses,
  double? totalScore,
  int? rating,
  String? notes,
  String? weatherCondition,
  double? temperature,
  double? windSpeed,
  String? windDirection,
  double? humidity,
  double? pressure,
  Map<String, dynamic>? disciplineData,
  double? distance,
  String? distanceUnit,
  String? targetType,
  String? stageName,
  double? groupSize,
  String? groupSizeUnit,
  int? eventId,
  String? visibilityOverride,
}) =>
    buildShootSessionPayload(
      date: date,
      discipline: discipline,
      sessionType: sessionType,
      location: location,
      rangeName: rangeName,
      venueType: venueType,
      latitude: latitude,
      longitude: longitude,
      firearmId: firearmId,
      ammoLoadId: ammoLoadId,
      equipmentIds: equipmentIds,
      totalRounds: totalRounds,
      totalHits: totalHits,
      totalMisses: totalMisses,
      totalScore: totalScore,
      rating: rating,
      notes: notes,
      weatherCondition: weatherCondition,
      temperature: temperature,
      windSpeed: windSpeed,
      windDirection: windDirection,
      humidity: humidity,
      pressure: pressure,
      disciplineData: disciplineData,
      distance: distance,
      distanceUnit: distanceUnit,
      targetType: targetType,
      stageName: stageName,
      groupSize: groupSize,
      groupSizeUnit: groupSizeUnit,
      eventId: eventId,
      visibilityOverride: visibilityOverride,
    );

ShootSessionModel remoteSessionFromJson(Map<String, dynamic> json) =>
    ShootSessionModel.fromApiJson(json);
