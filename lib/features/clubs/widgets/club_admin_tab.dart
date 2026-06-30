import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/club_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../providers/clubs_provider.dart';
import '../widgets/club_ui_helpers.dart';

class ClubAdminTab extends ConsumerStatefulWidget {
  const ClubAdminTab({super.key, required this.club});

  final ClubDetailModel club;

  @override
  ConsumerState<ClubAdminTab> createState() => _ClubAdminTabState();
}

class _ClubAdminTabState extends ConsumerState<ClubAdminTab> {
  late String _statusFilter;
  final _inviteEmailCtrl = TextEditingController();
  var _inviteBusy = false;

  @override
  void initState() {
    super.initState();
    final pending = widget.club.adminSummary?.pendingMembersCount ?? 0;
    _statusFilter = pending > 0 ? 'pending' : 'active';
  }

  @override
  void dispose() {
    _inviteEmailCtrl.dispose();
    super.dispose();
  }

  void _invalidateMembers() {
    ref.invalidate(
      clubMembersProvider((slug: widget.club.slug, status: _statusFilter)),
    );
    ref.invalidate(clubDetailProvider(widget.club.slug));
  }

  Future<void> _inviteMember() async {
    final email = _inviteEmailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() => _inviteBusy = true);
    try {
      await ref.read(apiServiceProvider).inviteClubMember(widget.club.slug, email);
      _inviteEmailCtrl.clear();
      _invalidateMembers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member invited.')),
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
    final summary = widget.club.adminSummary;
    final membersAsync = ref.watch(
      clubMembersProvider((slug: widget.club.slug, status: _statusFilter)),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (summary != null) ...[
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: 'Active',
                  value: '${summary.activeMembersCount}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStat(
                  label: 'Pending',
                  value: '${summary.pendingMembersCount}',
                  highlight: summary.pendingMembersCount > 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryStat(
                  label: 'Probation',
                  value: '${summary.probationMembersCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Invite member',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _inviteEmailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'MarksmanMate email',
                    hintText: 'shooter@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _inviteBusy ? null : _inviteMember(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _inviteBusy ? null : _inviteMember,
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
              ('pending', 'Pending'),
              ('active', 'Active'),
              ('probation', 'Probation'),
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
                        clubSlug: widget.club.slug,
                        member: member,
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
            Uri.parse(
              '${AppConfig.websiteBaseUrl}/clubs/${widget.club.slug}/secretary',
            ),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Full secretary dashboard on web'),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? theme.colorScheme.tertiary.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAdminCard extends ConsumerStatefulWidget {
  const _MemberAdminCard({
    required this.clubSlug,
    required this.member,
    required this.onChanged,
  });

  final String clubSlug;
  final ClubMemberModel member;
  final VoidCallback onChanged;

  @override
  ConsumerState<_MemberAdminCard> createState() => _MemberAdminCardState();
}

class _MemberAdminCardState extends ConsumerState<_MemberAdminCard> {
  var _busy = false;

  Future<void> _approve() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(apiServiceProvider)
          .approveClubMember(widget.clubSlug, widget.member.id);
      widget.onChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member approved.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approve failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.member.isPending ? 'Decline request?' : 'Remove member?'),
        content: Text(
          widget.member.isPending
              ? 'Decline ${widget.member.name}\'s join request?'
              : 'Remove ${widget.member.name} from the club?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.member.isPending ? 'Decline' : 'Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(apiServiceProvider)
          .removeClubMember(widget.clubSlug, widget.member.id);
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

  Future<void> _changeRole(String role) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiServiceProvider).changeClubMemberRole(
            widget.clubSlug,
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
    final subtitle = [
      member.email,
      member.statusLabel,
      member.membershipCategoryLabel,
    ].whereType<String>().where((v) => v.isNotEmpty).join(' · ');

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  name: member.name,
                  avatarUrl: member.avatarUrl,
                  radius: 22,
                ),
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
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        member.roleLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
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
                  if (member.isPending)
                    FilledButton(
                      onPressed: _busy ? null : _approve,
                      child: const Text('Approve'),
                    ),
                  if (member.isPending)
                    OutlinedButton(
                      onPressed: _busy ? null : _remove,
                      child: const Text('Decline'),
                    ),
                  if (!member.isPending && member.assignableRoles.isNotEmpty)
                    PopupMenuButton<String>(
                      enabled: !_busy,
                      onSelected: _changeRole,
                      itemBuilder: (context) => member.assignableRoles
                          .map(
                            (role) => PopupMenuItem(
                              value: role,
                              child: Text(formatClubRole(role)),
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
                  if (!member.isPending)
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
