import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/conversation_avatar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../providers/notifications_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final int conversationId;

  @override
  ConsumerState<ConversationScreen> createState() =>
      _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  var _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(conversationThreadProvider(widget.conversationId).notifier)
          .send(body);
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not send message: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync =
        ref.watch(conversationThreadProvider(widget.conversationId));
    final currentUserId = ref.watch(authStateProvider).user?.id;

    return Scaffold(
      appBar: AppScreenAppBar.back(
        context,
        title: threadAsync.maybeWhen(
          data: (thread) => thread.conversation.title,
          orElse: () => 'Conversation',
        ),
      ),
      body: threadAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load conversation.',
          onRetry: () => ref.invalidate(
            conversationThreadProvider(widget.conversationId),
          ),
        ),
        data: (thread) {
          return Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      ConversationAvatar(
                        participants: thread.conversation.participants,
                        type: thread.conversation.type,
                        title: thread.conversation.title,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          thread.conversation.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: thread.messages.length,
                  itemBuilder: (context, index) {
                    final message = thread.messages[index];
                    final isMine = message.userId == currentUserId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMine) ...[
                            UserAvatar(
                              name: message.userName,
                              avatarUrl: message.avatarUrl,
                              radius: 16,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMine && message.userName != null)
                                    Text(
                                      message.userName!,
                                      style:
                                          Theme.of(context).textTheme.labelSmall,
                                    ),
                                  Text(message.body),
                                  if (message.createdAt != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _formatTime(message.createdAt!),
                                        style:
                                            Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (isMine) ...[
                            const SizedBox(width: 8),
                            UserAvatar(
                              name: ref.watch(authStateProvider).user?.name,
                              avatarUrl:
                                  ref.watch(authStateProvider).user?.avatarUrl,
                              radius: 16,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
