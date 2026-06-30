import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/group_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/groups_provider.dart';

class GroupPostsTab extends ConsumerWidget {
  const GroupPostsTab({
    super.key,
    required this.group,
  });

  final GroupDetailModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final postsAsync = ref.watch(groupPostsProvider(group.id));

    return Stack(
      children: [
        postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ErrorRetryView(
            message: 'Could not load group posts.',
            onRetry: () => ref.invalidate(groupPostsProvider(group.id)),
          ),
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No posts yet. Share an update with the group.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(groupPostsProvider(group.id)),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _PostCard(post: posts[index]);
                },
              ),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showCreatePostSheet(context, ref),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('New post'),
          ),
        ),
      ],
    );
  }

  Future<void> _showCreatePostSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CreatePostSheet(groupId: group.id),
    );
  }
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet({required this.groupId});

  final int groupId;

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _busy) return;

    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).createGroupPost(
            widget.groupId,
            title: title,
            body: _bodyCtrl.text,
          );
      ref.invalidate(groupPostsProvider(widget.groupId));
      ref.invalidate(groupDetailProvider(widget.groupId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New group post',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final GroupPostModel post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.push_pin,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    post.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              post.authorName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (post.body?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(post.body!.trim()),
            ],
            if (post.linkUrl != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse(post.linkUrl!),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  post.linkUrl!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${post.commentCount} comment${post.commentCount == 1 ? '' : 's'}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('${AppConfig.websiteBaseUrl}/forum/posts/${post.id}'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('View on web'),
            ),
          ],
        ),
      ),
    );
  }
}
