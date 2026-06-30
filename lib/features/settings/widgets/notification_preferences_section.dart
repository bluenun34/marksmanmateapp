import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_preference_catalog.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationPreferencesSection extends ConsumerWidget {
  const NotificationPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(notificationPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Notifications',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Alert preferences'),
                subtitle: const Text(
                  'Choose which alerts appear on this device. '
                  'Your notification inbox may still list all activity.',
                ),
              ),
              const Divider(height: 1),
              for (var i = 0; i < NotificationPreferenceKey.values.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _PreferenceSwitch(
                  preference: NotificationPreferenceKey.values[i],
                  value: prefs.isOn(NotificationPreferenceKey.values[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceSwitch extends ConsumerWidget {
  const _PreferenceSwitch({
    required this.preference,
    required this.value,
  });

  final NotificationPreferenceKey preference;
  final bool value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile(
      secondary: Icon(preference.icon),
      title: Text(preference.title),
      subtitle: Text(preference.subtitle),
      value: value,
      onChanged: (enabled) => ref
          .read(notificationPreferencesProvider.notifier)
          .setEnabled(preference, enabled),
    );
  }
}
