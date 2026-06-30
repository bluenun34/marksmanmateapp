import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/group_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../../events/widgets/event_status_chip.dart';
import '../providers/groups_provider.dart';
import '../widgets/group_admin_tab.dart';
import '../widgets/group_avatar.dart';
import '../widgets/group_posts_tab.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final int groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  String _eventFilter = 'upcoming';
  var _leaveBusy = false;

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text('You will need a new invite to rejoin this group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _leaveBusy = true);
    try {
      await ref.read(apiServiceProvider).leaveGroup(widget.groupId);
      ref.invalidate(myGroupsProvider);
      if (!mounted) return;
      context.go('/groups');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You left the group.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not leave group: $e')),
      );
    } finally {
      if (mounted) setState(() => _leaveBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(groupDetailProvider(widget.groupId));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Group'),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load this group.',
          onRetry: () => ref.invalidate(groupDetailProvider(widget.groupId)),
        ),
        data: (group) {
          final tabCount = group.canManage ? 4 : 3;
          return DefaultTabController(
            length: tabCount,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GroupAvatar(name: group.name, radius: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (group.ownerName != null)
                              Text(
                                'Owner · ${group.ownerName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (group.memberCount != null)
                              Text(
                                '${group.memberCount} members',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (group.myMembership != null) ...[
                              const SizedBox(height: 8),
                              GroupMembershipChip(
                                membership: group.myMembership!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (group.description?.trim().isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      group.description!.trim(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (group.conversationPath != null)
                        OutlinedButton.icon(
                          onPressed: () => context.push(group.conversationPath!),
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Group chat'),
                        ),
                      if (group.clubPath != null)
                        OutlinedButton.icon(
                          onPressed: () => context.push(group.clubPath!),
                          icon: const Icon(Icons.groups_outlined, size: 18),
                          label: Text(group.clubName ?? 'Club'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(
                            '${AppConfig.websiteBaseUrl}/groups/${group.id}',
                          ),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open on web'),
                      ),
                      if (group.myMembership?.isActive == true)
                        OutlinedButton(
                          onPressed: _leaveBusy ? null : _leaveGroup,
                          child: _leaveBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Leave'),
                        ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: [
                    const Tab(text: 'Overview'),
                    const Tab(text: 'Posts'),
                    const Tab(text: 'Events'),
                    if (group.canManage) const Tab(text: 'Admin'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(group: group),
                      GroupPostsTab(group: group),
                      _EventsTab(
                        groupId: group.id,
                        groupName: group.name,
                        canCreateEvents: group.myMembership?.isActive == true,
                        filter: _eventFilter,
                        onFilter: (f) => setState(() => _eventFilter = f),
                      ),
                      if (group.canManage) GroupAdminTab(group: group),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.group});

  final GroupDetailModel group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (group.upcomingEventsCount != null)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Upcoming events'),
              trailing: Text('${group.upcomingEventsCount}'),
            ),
          ),
        if (group.postsCount != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Group posts'),
              trailing: Text('${group.postsCount}'),
              subtitle: const Text('View the full feed on the website.'),
            ),
          ),
        ],
        if (group.canManage) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Open the Admin tab to invite friends and manage members.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EventsTab extends ConsumerWidget {
  const _EventsTab({
    required this.groupId,
    required this.groupName,
    required this.canCreateEvents,
    required this.filter,
    required this.onFilter,
  });

  final int groupId;
  final String groupName;
  final bool canCreateEvents;
  final String filter;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnline = ref.watch(isOnlineProvider);
    final eventsAsync = ref.watch(
      groupEventsProvider((groupId: groupId, statusFilter: filter)),
    );

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isOnline)
              Material(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Connect to load group events.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  for (final entry in const [
                    ('upcoming', 'Upcoming'),
                    ('live', 'Live'),
                    ('ended', 'Past'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(entry.$2),
                        selected: filter == entry.$1,
                        onSelected: (_) => onFilter(entry.$1),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => ErrorRetryView(
                  message: 'Could not load events.',
                  onRetry: () => ref.invalidate(
                    groupEventsProvider((groupId: groupId, statusFilter: filter)),
                  ),
                ),
                data: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Text(
                        'No $filter events for this group.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return AppCard(
                        onTap: () => context.push(event.detailPath),
                        child: ListTile(
                          title: Text(event.name),
                          subtitle: Text(
                            [
                              event.eventDate?.toLocal().toString().split(' ').first,
                              event.startTime,
                              event.location,
                            ].whereType<String>().where((v) => v.isNotEmpty).join(' · '),
                          ),
                          trailing: EventStatusChip.fromEvent(event, compact: true),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (canCreateEvents && isOnline)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => context.push(
                '/groups/$groupId/events/new?name=${Uri.encodeComponent(groupName)}',
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create event'),
            ),
          ),
      ],
    );
  }
}
