import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_service.dart';
import '../../../shared/models/friendship_models.dart';
import '../../../shared/models/public_user_profile_model.dart';
import '../../../shared/utils/last_seen_formatter.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../providers/user_profile_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Profile'),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          if (error is UserProfileOfflineException) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Connect to the internet to view profiles.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
          return ErrorRetryView(
            message: 'Could not load this profile.',
            onRetry: () => ref.invalidate(userProfileProvider(userId)),
          );
        },
        data: (profile) => _ProfileBody(
          profile: profile,
          onChanged: () => ref.invalidate(userProfileProvider(userId)),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.profile,
    required this.onChanged,
  });

  final PublicUserProfileModel profile;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lastSeen = formatLastSeen(
      lastActiveAt: profile.lastActiveAt,
      lastActiveLabel: profile.lastActiveLabel,
      isOnline: profile.isOnline,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                UserAvatar(
                  name: profile.name,
                  avatarUrl: profile.avatarUrl,
                  radius: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (profile.username != null &&
                    profile.username!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (lastSeen.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        profile.isOnline == true
                            ? Icons.circle
                            : Icons.schedule,
                        size: 14,
                        color: profile.isOnline == true
                            ? Colors.green
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lastSeen,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                if (profile.memberSince != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${profile.memberSince}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (profile.region != null &&
                    profile.region!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.region!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (profile.plan != null)
                      Chip(
                        avatar: const Icon(
                          Icons.workspace_premium_outlined,
                          size: 18,
                        ),
                        label: Text(profile.plan!),
                      ),
                    if (profile.isVerified)
                      const Chip(
                        avatar: Icon(Icons.verified_outlined, size: 18),
                        label: Text('Trusted'),
                      ),
                    if (profile.isVerifiedSeller)
                      const Chip(
                        avatar: Icon(Icons.storefront_outlined, size: 18),
                        label: Text('Verified seller'),
                      ),
                    if (profile.isCoach)
                      const Chip(
                        avatar: Icon(Icons.school_outlined, size: 18),
                        label: Text('Coach'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!profile.isOwnProfile) ...[
          const SizedBox(height: 12),
          _FriendshipActionsCard(profile: profile, onChanged: onChanged),
        ],
        if (profile.canViewFullProfile && profile.stats != null) ...[
          const SizedBox(height: 16),
          _StatsCard(stats: profile.stats!),
        ] else if (!profile.canViewFullProfile) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _limitedProfileMessage(profile),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _limitedProfileMessage(PublicUserProfileModel profile) {
    if (profile.viewerHasBlocked) {
      return 'You blocked this member. Unblock them to view their full profile.';
    }
    if (profile.viewerIsBlocked) {
      return 'This member has blocked you.';
    }
    return 'This profile is only visible to people they allow.';
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final PublicUserProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatTile(label: 'Friends', value: stats.friends),
                _StatTile(label: 'Clubs', value: stats.clubs),
                _StatTile(label: 'Groups', value: stats.groups),
                _StatTile(label: 'Sessions', value: stats.sessions),
                _StatTile(label: 'Rounds', value: stats.rounds),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendshipActionsCard extends ConsumerStatefulWidget {
  const _FriendshipActionsCard({
    required this.profile,
    required this.onChanged,
  });

  final PublicUserProfileModel profile;
  final VoidCallback onChanged;

  @override
  ConsumerState<_FriendshipActionsCard> createState() =>
      _FriendshipActionsCardState();
}

class _FriendshipActionsCardState extends ConsumerState<_FriendshipActionsCard> {
  var _busy = false;

  FriendshipModel? get _friendship => widget.profile.friendship;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendship = _friendship;
    final status = friendship?.status;
    final api = ref.read(apiServiceProvider);

    if (widget.profile.viewerIsBlocked) {
      return const SizedBox.shrink();
    }

    if (status == 'accepted') {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.people_outline),
          title: const Text('Friends'),
          trailing: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : OutlinedButton(
                  onPressed: () => _run(() async {
                    if (friendship != null) {
                      await api.removeFriend(friendship.id);
                    }
                  }),
                  child: const Text('Remove'),
                ),
        ),
      );
    }

    if (status == 'pending' && friendship != null) {
      if (friendship.isIncoming) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Expanded(child: Text('Friend request pending')),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => api.acceptFriendRequest(friendship.id)),
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() => api.declineFriendRequest(friendship.id)),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        child: ListTile(
          leading: const Icon(Icons.hourglass_top_outlined),
          title: const Text('Friend request sent'),
          trailing: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : OutlinedButton(
                  onPressed: () => _run(() => api.removeFriend(friendship.id)),
                  child: const Text('Cancel'),
                ),
        ),
      );
    }

    if (widget.profile.viewerHasBlocked) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.block_outlined),
          title: const Text('You blocked this member'),
          trailing: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : OutlinedButton(
                  onPressed: () => _run(() => api.unblockFriend(widget.profile.id)),
                  child: const Text('Unblock'),
                ),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_add_outlined),
        title: const Text('Not friends yet'),
        trailing: _busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton(
                onPressed: () => _run(() => api.sendFriendRequest(widget.profile.id)),
                child: const Text('Add friend'),
              ),
      ),
    );
  }
}
