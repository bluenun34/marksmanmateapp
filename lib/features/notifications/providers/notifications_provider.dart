import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/network/api_errors.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/notifications/notification_router.dart';
import '../../../core/sync/sync_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/notification_preferences_provider.dart';
import '../../../shared/models/notification_models.dart';

const _inboxRequestTimeout = Duration(seconds: 20);

bool _canLoadRemoteInbox(Ref ref) {
  final access = ref.watch(
    authStateProvider.select(
      (state) => (state.isAuthenticated, state.canUseApp),
    ),
  );
  if (!access.$1 || !access.$2) return false;
  return ref.watch(isOnlineProvider);
}

final notificationSummaryProvider =
    AsyncNotifierProvider<NotificationSummaryNotifier, NotificationSummary>(
  NotificationSummaryNotifier.new,
);

class NotificationSummaryNotifier extends AsyncNotifier<NotificationSummary> {
  static const _empty = NotificationSummary(
    unreadNotifications: 0,
    unreadMessages: 0,
    pendingFriendRequests: 0,
    pendingGroupInvites: 0,
  );

  @override
  Future<NotificationSummary> build() async {
    if (!_canLoadRemoteInbox(ref)) return _empty;
    return ref
        .read(apiServiceProvider)
        .getNotificationSummary()
        .timeout(_inboxRequestTimeout);
  }

  Future<void> refresh() async {
    if (!_canLoadRemoteInbox(ref)) {
      state = const AsyncData(_empty);
      return;
    }
    state = await AsyncValue.guard(() async {
      return ref
          .read(apiServiceProvider)
          .getNotificationSummary()
          .timeout(_inboxRequestTimeout);
    });
  }
}

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, List<AppNotification>>(
  NotificationsListNotifier.new,
);

class NotificationsListNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    if (!_canLoadRemoteInbox(ref)) return const [];
    return ref
        .read(apiServiceProvider)
        .getNotifications()
        .timeout(_inboxRequestTimeout);
  }

  Future<void> refresh() async {
    if (!_canLoadRemoteInbox(ref)) {
      state = const AsyncData([]);
      return;
    }
    state = await AsyncValue.guard(() async {
      return ref
          .read(apiServiceProvider)
          .getNotifications()
          .timeout(_inboxRequestTimeout);
    });
    await ref.read(notificationSummaryProvider.notifier).refresh();
  }

  Future<void> markRead(AppNotification notification) async {
    if (!notification.isUnread) return;
    await ref.read(apiServiceProvider).markNotificationRead(notification.id);
    await refresh();
  }

  Future<void> markAllRead() async {
    await ref.read(apiServiceProvider).markAllNotificationsRead();
    await refresh();
  }

  Future<void> deleteNotification(AppNotification notification) async {
    await ref.read(apiServiceProvider).deleteNotification(notification.id);
    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.where((item) => item.id != notification.id).toList(),
      );
    }
    await ref.read(notificationSummaryProvider.notifier).refresh();
  }

  Future<void> clearReadNotifications() async {
    await ref.read(apiServiceProvider).clearReadNotifications();
    await refresh();
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationSummary>>(
  ConversationsNotifier.new,
);

class ConversationsNotifier extends AsyncNotifier<List<ConversationSummary>> {
  @override
  Future<List<ConversationSummary>> build() async {
    if (!_canLoadRemoteInbox(ref)) return const [];
    return ref
        .read(apiServiceProvider)
        .getConversations()
        .timeout(_inboxRequestTimeout);
  }

  Future<void> refresh() async {
    if (!_canLoadRemoteInbox(ref)) {
      state = const AsyncData([]);
      return;
    }
    state = await AsyncValue.guard(() async {
      return ref
          .read(apiServiceProvider)
          .getConversations()
          .timeout(_inboxRequestTimeout);
    });
    await ref.read(notificationSummaryProvider.notifier).refresh();
  }
}

final conversationThreadProvider = AsyncNotifierProvider.autoDispose
    .family<ConversationThreadNotifier, ({ConversationSummary conversation, List<ChatMessage> messages}), int>(
  ConversationThreadNotifier.new,
);

class ConversationThreadNotifier extends AsyncNotifier<
    ({ConversationSummary conversation, List<ChatMessage> messages})> {
  ConversationThreadNotifier(this.conversationId);
  final int conversationId;

  @override
  Future<({ConversationSummary conversation, List<ChatMessage> messages})>
      build() async {
    if (!_canLoadRemoteInbox(ref)) {
      throw StateError('Connect to the internet to load messages.');
    }
    return ref
        .read(apiServiceProvider)
        .getConversation(conversationId)
        .timeout(_inboxRequestTimeout);
  }

  Future<void> refresh() async {
    if (!_canLoadRemoteInbox(ref)) return;
    state = await AsyncValue.guard(() async {
      return ref
          .read(apiServiceProvider)
          .getConversation(conversationId)
          .timeout(_inboxRequestTimeout);
    });
    await ref.read(notificationSummaryProvider.notifier).refresh();
  }

  Future<void> send(String body) async {
    await ref
        .read(apiServiceProvider)
        .sendConversationMessage(conversationId, body: body);
    await refresh();
    await ref.read(conversationsProvider.notifier).refresh();
  }
}

/// Polls for new server notifications and raises local alerts.
final notificationPollerProvider = Provider<NotificationPoller>((ref) {
  final poller = NotificationPoller(ref);
  ref.onDispose(poller.dispose);
  return poller;
});

class NotificationPoller {
  NotificationPoller(this._ref);

  final Ref _ref;
  Timer? _timer;
  var _knownIds = <String>{};
  var _started = false;

  void start() {
    if (_started) return;
    _started = true;
    unawaited(_poll());
    _timer = Timer.periodic(const Duration(minutes: 2), (_) => _poll());
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> _poll() async {
    if (!_canLoadRemoteInbox(_ref)) return;

    try {
      final notifications = await _ref
          .read(apiServiceProvider)
          .getNotifications()
          .timeout(_inboxRequestTimeout);
      final prefs = _ref.read(appPreferencesProvider);
      final pushed = await prefs.pushedNotificationIds();

      for (final notification in notifications) {
        if (!notification.isUnread) continue;
        if (_knownIds.contains(notification.id)) continue;
        if (pushed.contains(notification.id)) continue;
        if (!_ref
            .read(notificationPreferencesProvider)
            .isOnForNotificationType(notification.type)) {
          continue;
        }

        _knownIds.add(notification.id);
        await prefs.markNotificationPushed(notification.id);

        await LocalNotificationsService.instance.showInboxNotification(
          id: notification.id.hashCode,
          title: notification.displayTitle,
          body: notification.displayBody,
          route: routeForNotification(notification),
        );
      }

      if (_knownIds.isEmpty && notifications.isNotEmpty) {
        _knownIds.addAll(notifications.map((n) => n.id));
      }

      unawaited(_ref.read(notificationSummaryProvider.notifier).refresh());
    } on InboxApiUnavailableException {
      // Server has not deployed inbox routes yet.
    } catch (_) {}
  }
}
