import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_errors.dart';
import '../../../core/notifications/notification_router.dart';
import '../../../core/sync/sync_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/notification_models.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/notifications_provider.dart';
import 'inbox_unavailable.dart';

enum _NotificationFilter { all, unread, read }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final notificationsAsync = ref.watch(notificationsListProvider);
    final unavailableMessage = inboxUnavailableMessage(
      canUseApp: auth.canUseApp,
      isOnline: isOnline,
    );

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: 'Notifications',
        actions: [
          if (unavailableMessage == null)
            PopupMenuButton<_NotificationMenuAction>(
              tooltip: 'More options',
              onSelected: (action) => _onMenuAction(context, action),
              itemBuilder: (context) {
                final items = notificationsAsync.value ?? const [];
                final hasUnread = items.any((n) => n.isUnread);
                final hasRead = items.any((n) => !n.isUnread);

                return [
                  if (hasUnread)
                    const PopupMenuItem(
                      value: _NotificationMenuAction.markAllRead,
                      child: Text('Mark all read'),
                    ),
                  if (hasRead)
                    const PopupMenuItem(
                      value: _NotificationMenuAction.clearRead,
                      child: Text('Clear read'),
                    ),
                ];
              },
            ),
        ],
      ),
      body: unavailableMessage != null
          ? InboxUnavailableView(message: unavailableMessage)
          : notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              skipLoadingOnReload: true,
              error: (error, _) {
                if (_isInboxUnsupported(error)) {
                  return InboxUnavailableView(
                    message: inboxErrorMessage(error),
                  );
                }
                return ErrorRetryView(
                  message: inboxErrorMessage(error),
                  onRetry: () => ref.invalidate(notificationsListProvider),
                );
              },
              data: (items) {
                final filtered = _applyFilter(items);
                final unreadCount = items.where((n) => n.isUnread).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All',
                            count: items.length,
                            selected: _filter == _NotificationFilter.all,
                            onSelected: () => setState(
                              () => _filter = _NotificationFilter.all,
                            ),
                          ),
                          _FilterChip(
                            label: 'Unread',
                            count: unreadCount,
                            selected: _filter == _NotificationFilter.unread,
                            onSelected: () => setState(
                              () => _filter = _NotificationFilter.unread,
                            ),
                          ),
                          _FilterChip(
                            label: 'Read',
                            count: items.length - unreadCount,
                            selected: _filter == _NotificationFilter.read,
                            onSelected: () => setState(
                              () => _filter = _NotificationFilter.read,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                _emptyMessage(_filter),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(notificationsListProvider.notifier)
                                  .refresh(),
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final notification = filtered[index];
                                  return _NotificationTile(
                                    key: ValueKey(notification.id),
                                    notification: notification,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<AppNotification> _applyFilter(List<AppNotification> items) {
    return switch (_filter) {
      _NotificationFilter.all => items,
      _NotificationFilter.unread =>
        items.where((notification) => notification.isUnread).toList(),
      _NotificationFilter.read =>
        items.where((notification) => !notification.isUnread).toList(),
    };
  }

  String _emptyMessage(_NotificationFilter filter) {
    return switch (filter) {
      _NotificationFilter.all => 'No notifications yet.',
      _NotificationFilter.unread => 'No unread notifications.',
      _NotificationFilter.read => 'No read notifications.',
    };
  }

  Future<void> _onMenuAction(
    BuildContext context,
    _NotificationMenuAction action,
  ) async {
    final notifier = ref.read(notificationsListProvider.notifier);

    switch (action) {
      case _NotificationMenuAction.markAllRead:
        await notifier.markAllRead();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
      case _NotificationMenuAction.clearRead:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear read notifications?'),
            content: const Text(
              'This removes all read notifications from your inbox. '
              'Unread notifications will stay.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
        );
        if (confirmed != true || !context.mounted) return;
        try {
          await notifier.clearReadNotifications();
          if (!context.mounted) return;
          setState(() => _filter = _NotificationFilter.all);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Read notifications cleared')),
          );
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_actionErrorMessage(error))),
          );
        }
    }
  }
}

enum _NotificationMenuAction { markAllRead, clearRead }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = count > 0 ? '$label ($count)' : label;

    return FilterChip(
      label: Text(text),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({super.key, required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final created = notification.createdAt;
    final subtitle = created != null ? _formatDateTime(created) : null;

    return Dismissible(
      key: ValueKey('dismiss-${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) => _confirmRemove(context),
      onDismissed: (_) async {
        try {
          await ref
              .read(notificationsListProvider.notifier)
              .deleteNotification(notification);
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_actionErrorMessage(error))),
          );
          ref.invalidate(notificationsListProvider);
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: notification.isUnread
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            _iconForType(notification.type),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          notification.displayTitle,
          style: notification.isUnread
              ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.displayBody.isNotEmpty)
              Text(
                notification.displayBody,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: notification.isUnread
            ? Icon(
                Icons.circle,
                size: 10,
                color: theme.colorScheme.primary,
              )
            : IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Remove',
                onPressed: () => _removeNotification(context, ref),
              ),
        onTap: () async {
          await ref
              .read(notificationsListProvider.notifier)
              .markRead(notification);
          if (!context.mounted) return;
          context.push(routeForNotification(notification));
        },
      ),
    );
  }

  Future<void> _removeNotification(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmRemove(context);
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(notificationsListProvider.notifier)
          .deleteNotification(notification);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification removed')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_actionErrorMessage(error))),
      );
    }
  }

  IconData _iconForType(String? type) {
    return switch (type) {
      'new_message' => Icons.chat_bubble_outline,
      'event_rsvp_reminder' => Icons.event_outlined,
      'structured_shoot_log_reminder' => Icons.edit_note_outlined,
      'friend_request' || 'friend_request_accepted' => Icons.person_outline,
      'group_invite' => Icons.group_add_outlined,
      _ => Icons.notifications_outlined,
    };
  }
}

Future<bool?> _confirmRemove(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove notification?'),
      content: const Text('This notification will be deleted from your inbox.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

String _actionErrorMessage(Object error) {
  if (error is DioException && error.response?.statusCode == 404) {
    return 'Remove is not available yet. Update the MarksmanMate server.';
  }
  return 'Something went wrong. Please try again.';
}

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${local.day}/${local.month}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

bool _isInboxUnsupported(Object error) {
  return error is InboxApiUnavailableException ||
      (error is DioException && error.response?.statusCode == 404);
}
