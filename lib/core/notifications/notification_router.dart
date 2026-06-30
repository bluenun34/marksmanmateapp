import '../../shared/models/notification_models.dart';

String routeForNotification(AppNotification notification) {
  switch (notification.type) {
    case 'new_message':
      final conversationId = notification.conversationId;
      if (conversationId != null) {
        return '/messages/$conversationId';
      }
      return '/messages';
    case 'event_rsvp_reminder':
    case 'structured_shoot_log_reminder':
      final eventId = notification.eventId;
      if (eventId != null) return '/events/$eventId';
      return '/events';
    case 'group_invite':
      return '/groups';
    case 'event_tomorrow_digest':
      return '/events';
    default:
      return '/notifications';
  }
}
