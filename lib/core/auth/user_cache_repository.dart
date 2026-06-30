import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/user_model.dart';

const cachedUserPrefsKey = 'cached_user_v1';

final userCacheRepositoryProvider = Provider<UserCacheRepository>((ref) {
  return UserCacheRepository();
});

/// Persists the last known user profile for offline session restore.
class UserCacheRepository {
  Future<void> save(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cachedUserPrefsKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(cachedUserPrefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cachedUserPrefsKey);
  }
}
