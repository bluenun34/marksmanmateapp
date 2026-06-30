import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_preference_catalog.dart';
import '../../../core/preferences/app_preferences.dart';

class NotificationPreferences {
  const NotificationPreferences({required this.enabled});

  final Map<NotificationPreferenceKey, bool> enabled;

  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      enabled: {
        for (final key in NotificationPreferenceKey.values) key: true,
      },
    );
  }

  bool isOn(NotificationPreferenceKey key) => enabled[key] ?? true;

  bool isOnForNotificationType(String? type) {
    return isOn(NotificationPreferenceKey.forNotificationType(type));
  }

  NotificationPreferences copyWith({
    Map<NotificationPreferenceKey, bool>? enabled,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
    );
  }
}

class NotificationPreferencesNotifier extends Notifier<NotificationPreferences> {
  @override
  NotificationPreferences build() {
    _load();
    return NotificationPreferences.defaults();
  }

  Future<void> _load() async {
    final stored =
        await ref.read(appPreferencesProvider).notificationPreferences();
    state = NotificationPreferences(enabled: stored);
  }

  Future<void> setEnabled(
    NotificationPreferenceKey key,
    bool value,
  ) async {
    final next = Map<NotificationPreferenceKey, bool>.from(state.enabled)
      ..[key] = value;
    state = state.copyWith(enabled: next);
    await ref.read(appPreferencesProvider).setNotificationPreferences(next);
  }
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  NotificationPreferencesNotifier.new,
);
