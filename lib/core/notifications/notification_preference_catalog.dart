import 'package:flutter/material.dart';

/// Categories the user can enable or disable for on-device alerts.
enum NotificationPreferenceKey {
  messages(
    'new_message',
    'Messages',
    'New direct messages',
    Icons.chat_bubble_outline,
  ),
  eventReminders(
    'event_rsvp_reminder',
    'Event reminders',
    'RSVP and check-in reminders for events',
    Icons.event_outlined,
  ),
  eventDigests(
    'event_tomorrow_digest',
    'Event digests',
    'Summaries of events happening tomorrow',
    Icons.calendar_view_day_outlined,
  ),
  shootLogReminders(
    'structured_shoot_log_reminder',
    'Shoot log reminders',
    'Prompts to log structured club shoots',
    Icons.edit_note_outlined,
  ),
  friendRequests(
    'friend_request',
    'Friend requests',
    'When someone sends you a friend request',
    Icons.person_add_outlined,
  ),
  friendAccepted(
    'friend_request_accepted',
    'Friend requests accepted',
    'When someone accepts your request',
    Icons.person_outline,
  ),
  groupInvites(
    'group_invite',
    'Group invites',
    'Invitations to join shooting groups',
    Icons.group_add_outlined,
  ),
  upcomingEvents(
    '_local_upcoming_event',
    'Upcoming events',
    'Reminders for events in the next 24 hours',
    Icons.notifications_active_outlined,
  ),
  syncAlerts(
    '_local_sync',
    'Sync alerts',
    'When shoot log sync completes or fails',
    Icons.sync_outlined,
  ),
  other(
    '_other',
    'Other alerts',
    'Any other account notifications',
    Icons.notifications_outlined,
  );

  const NotificationPreferenceKey(
    this.storageKey,
    this.title,
    this.subtitle,
    this.icon,
  );

  final String storageKey;
  final String title;
  final String subtitle;
  final IconData icon;

  static const defaults = NotificationPreferenceKey.values;

  static NotificationPreferenceKey forNotificationType(String? type) {
    if (type == null || type.isEmpty) {
      return NotificationPreferenceKey.other;
    }
    for (final pref in NotificationPreferenceKey.values) {
      if (pref == NotificationPreferenceKey.other) continue;
      if (pref.storageKey == type) return pref;
    }
    return NotificationPreferenceKey.other;
  }
}
