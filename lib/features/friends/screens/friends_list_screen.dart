import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/friendship_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/friends_provider.dart';

class FriendsListScreen extends ConsumerStatefulWidget {
  const FriendsListScreen({super.key});

  @override
  ConsumerState<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends ConsumerState<FriendsListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _invalidateAll() {
    ref.invalidate(friendsProvider);
    ref.invalidate(receivedFriendRequestsProvider);
    ref.invalidate(sentFriendRequestsProvider);
    if (_searchQuery.length >= 2) {
      ref.invalidate(friendSearchProvider(_searchQuery));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = ref.watch(isOnlineProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final requestsAsync = ref.watch(receivedFriendRequestsProvider);
    final sentAsync = ref.watch(sentFriendRequestsProvider);
    final searchAsync = _searchQuery.length >= 2
        ? ref.watch(friendSearchProvider(_searchQuery))
        : null;

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Friends'),
      body: Column(
        children: [
          if (!isOnline)
            Material(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Connect to manage friends.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Find shooters',
                hintText: 'Search by name',
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : const Icon(Icons.search),
              ),
              onSubmitted: (value) => setState(() => _searchQuery = value.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _invalidateAll(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_searchQuery.length >= 2) ...[
                    Text(
                      'Search results',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (searchAsync != null)
                      searchAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Search failed.'),
                        data: (results) {
                          if (results.isEmpty) {
                            return const Text('No shooters found.');
                          }
                          return Column(
                            children: results
                                .map(
                                  (user) => _SearchResultCard(
                                    user: user,
                                    onChanged: _invalidateAll,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                  requestsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (requests) {
                      if (requests.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Friend requests',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final request in requests) ...[
                            _RequestCard(
                              friendship: request,
                              onChanged: _invalidateAll,
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                  sentAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (sent) {
                      if (sent.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Sent requests',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final request in sent) ...[
                            _SentRequestCard(
                              friendship: request,
                              onChanged: _invalidateAll,
                            ),
                            const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                  friendsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => ErrorRetryView(
                      message: 'Could not load friends.',
                      onRetry: _invalidateAll,
                    ),
                    data: (friends) {
                      if (friends.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'No friends yet. Search for shooters to connect.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${friends.length} friend${friends.length == 1 ? '' : 's'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final friend in friends) ...[
                            _FriendCard(
                              friendship: friend,
                              onChanged: _invalidateAll,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentRequestCard extends ConsumerWidget {
  const _SentRequestCard({
    required this.friendship,
    required this.onChanged,
  });

  final FriendshipModel friendship;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: ListTile(
        title: Text(friendship.userName),
        subtitle: const Text('Request pending'),
        trailing: OutlinedButton(
          onPressed: () async {
            await ref.read(apiServiceProvider).removeFriend(friendship.id);
            onChanged();
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({
    required this.friendship,
    required this.onChanged,
  });

  final FriendshipModel friendship;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(child: Text(friendship.userName)),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(apiServiceProvider)
                    .acceptFriendRequest(friendship.id);
                onChanged();
              },
              child: const Text('Accept'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () async {
                await ref
                    .read(apiServiceProvider)
                    .declineFriendRequest(friendship.id);
                onChanged();
              },
              child: const Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends ConsumerWidget {
  const _FriendCard({
    required this.friendship,
    required this.onChanged,
  });

  final FriendshipModel friendship;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: ListTile(
        title: Text(friendship.userName),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'remove') {
              await ref.read(apiServiceProvider).removeFriend(friendship.id);
            } else if (value == 'block') {
              await ref.read(apiServiceProvider).blockFriend(friendship.userId);
            }
            onChanged();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Text('Remove friend'),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Text('Block'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({
    required this.user,
    required this.onChanged,
  });

  final FriendUserModel user;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRequest = user.canRequest;
    final isPending = user.friendshipStatus == 'pending';

    return AppCard(
      child: ListTile(
        title: Text(user.name),
        subtitle: isPending ? const Text('Request pending') : null,
        trailing: canRequest
            ? FilledButton(
                onPressed: () async {
                  await ref
                      .read(apiServiceProvider)
                      .sendFriendRequest(user.id);
                  onChanged();
                },
                child: const Text('Add'),
              )
            : null,
      ),
    );
  }
}
