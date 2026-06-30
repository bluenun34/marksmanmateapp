import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/notification_preference_catalog.dart';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences();
});

class AppPreferences {
  static const _rememberEmailKey = 'remembered_email';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _distanceUnitKey = 'pref_distance_unit';
  static const _groupSizeUnitKey = 'pref_group_size_unit';
  static const _dismissedStructuredLogKey = 'dismissed_structured_log_events';
  static const _eventReminderNotifKey = 'event_reminder_notif_ids';

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

  Future<Set<int>> dismissedStructuredLogEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedStructuredLogKey) ?? const [];
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> dismissStructuredLogEvent(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await dismissedStructuredLogEventIds();
    current.add(eventId);
    await prefs.setStringList(
      _dismissedStructuredLogKey,
      current.map((id) => id.toString()).toList(),
    );
  }

  Future<Set<int>> scheduledEventReminderIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_eventReminderNotifKey) ?? const [];
    return list.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> markEventReminderScheduled(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await scheduledEventReminderIds();
    current.add(eventId);
    await prefs.setStringList(
      _eventReminderNotifKey,
      current.map((id) => id.toString()).toList(),
    );
  }

  static const _pushedNotificationIdsKey = 'pushed_notification_ids';
  static const _notificationPrefPrefix = 'notif_pref_';

  Future<Map<NotificationPreferenceKey, bool>> notificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final key in NotificationPreferenceKey.values)
        key: prefs.getBool('$_notificationPrefPrefix${key.storageKey}') ?? true,
    };
  }

  Future<void> setNotificationPreferences(
    Map<NotificationPreferenceKey, bool> values,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in values.entries) {
      await prefs.setBool(
        '$_notificationPrefPrefix${entry.key.storageKey}',
        entry.value,
      );
    }
  }

  Future<Set<String>> pushedNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_pushedNotificationIdsKey) ?? const []).toSet();
  }

  Future<void> markNotificationPushed(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await pushedNotificationIds();
    current.add(notificationId);
    final trimmed = current.length > 200
        ? current.skip(current.length - 200).toSet()
        : current;
    await prefs.setStringList(
      _pushedNotificationIdsKey,
      trimmed.toList(),
    );
  }
}
