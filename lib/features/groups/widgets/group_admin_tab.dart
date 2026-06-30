import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/group_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../providers/groups_provider.dart';
import '../providers/groups_provider.dart';
import '../widgets/group_ui_helpers.dart';

class GroupAdminTab extends ConsumerStatefulWidget {
  const GroupAdminTab({super.key, required this.group});

  final GroupDetailModel group;

  @override
  ConsumerState<GroupAdminTab> createState() => _GroupAdminTabState();
}

class _GroupAdminTabState extends ConsumerState<GroupAdminTab> {
  late String _statusFilter;
  InviteableFriend? _selectedFriend;
  var _inviteBusy = false;

  @override
  void initState() {
    super.initState();
    _statusFilter = 'active';
  }

  void _invalidateMembers() {
    ref.invalidate(
      groupMembersProvider((groupId: widget.group.id, status: _statusFilter)),
    );
    ref.invalidate(groupDetailProvider(widget.group.id));
    ref.invalidate(groupInviteableFriendsProvider(widget.group.id));
  }

  Future<void> _inviteFriend() async {
    final friend = _selectedFriend;
    if (friend == null) return;

    setState(() => _inviteBusy = true);
    try {
      await ref.read(apiServiceProvider).inviteGroupMember(
            widget.group.id,
            friend.id,
          );
      _selectedFriend = null;
      _invalidateMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite sent.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _inviteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(
      groupMembersProvider((groupId: widget.group.id, status: _statusFilter)),
    );
    final friendsAsync = ref.watch(
      groupInviteableFriendsProvider(widget.group.id),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Invite friend',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                friendsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(
                    'Could not load friends to invite.',
                    style: theme.textTheme.bodySmall,
                  ),
                  data: (friends) {
                    if (friends.isEmpty) {
                      return Text(
                        'No friends available to invite. Add friends on the website first.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }

                    return DropdownButtonFormField<InviteableFriend>(
                      initialValue: _selectedFriend,
                      decoration: const InputDecoration(
                        labelText: 'Friend',
                      ),
                      items: friends
                          .map(
                            (friend) => DropdownMenuItem(
                              value: friend,
                              child: Text(friend.name),
                            ),
                          )
                          .toList(),
                      onChanged: _inviteBusy
                          ? null
                          : (value) => setState(() => _selectedFriend = value),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _inviteBusy || _selectedFriend == null
                        ? null
                        : _inviteFriend,
                    child: _inviteBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send invite'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in const [
              ('active', 'Active'),
              ('invited', 'Invited'),
              ('banned', 'Banned'),
              ('all', 'All'),
            ])
              FilterChip(
                label: Text(entry.$2),
                selected: _statusFilter == entry.$1,
                onSelected: (_) => setState(() => _statusFilter = entry.$1),
              ),
          ],
        ),
        const SizedBox(height: 12),
        membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ErrorRetryView(
            message: 'Could not load members.',
            onRetry: _invalidateMembers,
          ),
          data: (members) {
            if (members.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No ${_statusFilter == 'all' ? '' : _statusFilter} members.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: members
                  .map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MemberAdminCard(
                        groupId: widget.group.id,
                        member: member,
                        isGroupOwner: widget.group.isOwner,
                        onChanged: _invalidateMembers,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => launchUrl(
            Uri.parse('${AppConfig.websiteBaseUrl}/groups/${widget.group.id}'),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Manage on web'),
        ),
      ],
    );
  }
}

class _MemberAdminCard extends ConsumerStatefulWidget {
  const _MemberAdminCard({
    required this.groupId,
    required this.member,
    required this.isGroupOwner,
    required this.onChanged,
  });

  final int groupId;
  final GroupMemberModel member;
  final bool isGroupOwner;
  final VoidCallback onChanged;

  @override
  ConsumerState<_MemberAdminCard> createState() => _MemberAdminCardState();
}

class _MemberAdminCardState extends ConsumerState<_MemberAdminCard> {
  var _busy = false;

  Future<void> _remove() async {
    final member = widget.member;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isInvited ? 'Cancel invite?' : 'Remove member?'),
        content: Text(
          member.isInvited
              ? 'Cancel the invite for ${member.name}?'
              : 'Remove ${member.name} from the group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(member.isInvited ? 'Cancel invite' : 'Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      if (member.isInvited) {
        await ref.read(apiServiceProvider).cancelGroupInvite(
              widget.groupId,
              member.id,
            );
      } else {
        await ref.read(apiServiceProvider).removeGroupMember(
              widget.groupId,
              member.id,
            );
      }
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

  Future<void> _ban() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).banGroupMember(
            widget.groupId,
            widget.member.id,
          );
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ban failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unban() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).unbanGroupMember(
            widget.groupId,
            widget.member.id,
          );
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unban failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _transferOwnership() async {
    final member = widget.member;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer ownership?'),
        content: Text(
          'Make ${member.name} the group owner? You will become an admin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).transferGroupOwnership(
            widget.groupId,
            member.id,
          );
      widget.onChanged();
      ref.invalidate(groupDetailProvider(widget.groupId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ownership transferred.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transfer failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeRole(String role) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).changeGroupMemberRole(
            widget.groupId,
            widget.member.id,
            role,
          );
      widget.onChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = widget.member;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(name: member.name, radius: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        member.statusLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.roleLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (member.canManage) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (member.isInvited)
                    OutlinedButton(
                      onPressed: _busy ? null : _remove,
                      child: const Text('Cancel invite'),
                    ),
                  if (!member.isInvited && member.status == 'banned')
                    FilledButton(
                      onPressed: _busy ? null : _unban,
                      child: const Text('Unban'),
                    ),
                  if (!member.isInvited &&
                      member.status == 'active' &&
                      widget.isGroupOwner &&
                      member.role != 'owner')
                    OutlinedButton(
                      onPressed: _busy ? null : _transferOwnership,
                      child: const Text('Make owner'),
                    ),
                  if (!member.isInvited &&
                      member.status == 'active' &&
                      member.canManage)
                    OutlinedButton(
                      onPressed: _busy ? null : _ban,
                      child: const Text('Ban'),
                    ),
                  if (!member.isInvited &&
                      member.status == 'active' &&
                      member.assignableRoles.isNotEmpty)
                    PopupMenuButton<String>(
                      enabled: !_busy,
                      onSelected: _changeRole,
                      itemBuilder: (context) => member.assignableRoles
                          .map(
                            (role) => PopupMenuItem(
                              value: role,
                              child: Text(formatGroupRole(role)),
                            ),
                          )
                          .toList(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.admin_panel_settings_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Change role'),
                          ],
                        ),
                      ),
                    ),
                  if (!member.isInvited && member.status == 'active')
                    TextButton(
                      onPressed: _busy ? null : _remove,
                      child: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
