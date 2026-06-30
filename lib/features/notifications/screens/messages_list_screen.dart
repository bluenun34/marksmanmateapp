import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/sync/sync_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/conversation_avatar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/notifications_provider.dart';
import '../../../core/network/api_errors.dart';
import 'inbox_unavailable.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    final unavailableMessage = inboxUnavailableMessage(
      canUseApp: auth.canUseApp,
      isOnline: isOnline,
    );

    return Scaffold(
      appBar: AppScreenAppBar.main(context, title: 'Messages'),
      body: unavailableMessage != null
          ? InboxUnavailableView(message: unavailableMessage)
          : conversationsAsync.when(
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
                  onRetry: () => ref.invalidate(conversationsProvider),
                );
              },
              data: (conversations) {
                if (conversations.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(conversationsProvider.notifier).refresh(),
                  child: ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: ConversationAvatar(
                          participants: conversation.participants,
                          type: conversation.type,
                          title: conversation.title,
                          size: 48,
                        ),
                        title: Text(
                          conversation.title,
                          style: conversation.unread
                              ? theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)
                              : theme.textTheme.titleSmall,
                        ),
                        subtitle: conversation.latestPreview != null
                            ? Text(
                                conversation.latestPreview!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: conversation.unread
                            ? Icon(
                                Icons.circle,
                                size: 10,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => context.push('/messages/${conversation.id}'),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

bool _isInboxUnsupported(Object error) {
  return error is InboxApiUnavailableException ||
      (error is DioException && error.response?.statusCode == 404);
}
