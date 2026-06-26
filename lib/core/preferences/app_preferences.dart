import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences();
});

class AppPreferences {
  static const _rememberEmailKey = 'remembered_email';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _distanceUnitKey = 'pref_distance_unit';
  static const _groupSizeUnitKey = 'pref_group_size_unit';

  Future<String?> rememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rememberEmailKey);
  }

  Future<void> setRememberedEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await prefs.remove(_rememberEmailKey);
    } else {
      await prefs.setString(_rememberEmailKey, email.trim().toLowerCase());
    }
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, value);
  }

  Future<String> distanceUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_distanceUnitKey) ?? 'metres';
  }

  Future<void> setDistanceUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distanceUnitKey, unit);
  }

  Future<String> groupSizeUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_groupSizeUnitKey) ?? 'mm';
  }

  Future<void> setGroupSizeUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groupSizeUnitKey, unit);
  }
}
