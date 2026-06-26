import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const sessionDraftPrefsKey = 'shoot_session_draft_v1';

class SessionDraftRepository {
  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(sessionDraftPrefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasDraft() async {
    final draft = await loadDraft();
    return draft != null && draft.isNotEmpty;
  }

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      sessionDraftPrefsKey,
      jsonEncode({...draft, 'savedAt': DateTime.now().toIso8601String()}),
    );
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionDraftPrefsKey);
  }
}

/// Serializes create-session wizard state for draft restore.
Map<String, dynamic> serializeSessionDraft({
  required int currentStep,
  required DateTime date,
  required String discipline,
  required String sessionType,
  required String venueType,
  String? lighting,
  required String range,
  required String location,
  required String laneBay,
  required String rounds,
  required String hits,
  required String misses,
  required String score,
  required String distance,
  required String distanceUnit,
  required String targetType,
  required String stageName,
  required String groupSize,
  required String groupSizeUnit,
  required int rating,
  required String notes,
  required String weather,
  required String temp,
  required String windSpeed,
  required String windDir,
  required String humidity,
  required String pressure,
  required String windGust,
  required String cloudCover,
  required String precip,
  double? latitude,
  double? longitude,
  int? firearmId,
  int? ammoLoadId,
  required List<int> equipmentIds,
  required Map<String, String> disciplineData,
  String? voiceNotePath,
  int? linkedEventId,
}) {
  return {
    'currentStep': currentStep,
    'date': date.toIso8601String(),
    'discipline': discipline,
    'sessionType': sessionType,
    'venueType': venueType,
    'lighting': lighting,
    'range': range,
    'location': location,
    'laneBay': laneBay,
    'rounds': rounds,
    'hits': hits,
    'misses': misses,
    'score': score,
    'distance': distance,
    'distanceUnit': distanceUnit,
    'targetType': targetType,
    'stageName': stageName,
    'groupSize': groupSize,
    'groupSizeUnit': groupSizeUnit,
    'rating': rating,
    'notes': notes,
    'weather': weather,
    'temp': temp,
    'windSpeed': windSpeed,
    'windDir': windDir,
    'humidity': humidity,
    'pressure': pressure,
    'windGust': windGust,
    'cloudCover': cloudCover,
    'precip': precip,
    'latitude': latitude,
    'longitude': longitude,
    'firearmId': firearmId,
    'ammoLoadId': ammoLoadId,
    'equipmentIds': equipmentIds,
    'disciplineData': disciplineData,
    'voiceNotePath': voiceNotePath,
    'linkedEventId': linkedEventId,
  };
}
