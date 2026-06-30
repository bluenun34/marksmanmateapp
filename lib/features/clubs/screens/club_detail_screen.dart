import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/club_models.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/clubs_provider.dart';
import '../widgets/club_admin_tab.dart';
import '../widgets/club_avatar.dart';
import '../../events/widgets/event_status_chip.dart';

class ClubDetailScreen extends ConsumerStatefulWidget {
  const ClubDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends ConsumerState<ClubDetailScreen>
    with SingleTickerProviderStateMixin {
  String _eventFilter = 'upcoming';
  var _membershipBusy = false;

  Future<void> _joinOrLeave(bool join) async {
    setState(() => _membershipBusy = true);
    try {
      final api = ref.read(apiServiceProvider);
      if (join) {
        await api.joinClub(widget.slug);
      } else {
        await api.leaveClub(widget.slug);
      }
      ref.invalidate(clubDetailProvider(widget.slug));
      ref.invalidate(myClubsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(join ? 'Join request sent.' : 'You left the club.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update membership: $e')),
      );
    } finally {
      if (mounted) setState(() => _membershipBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detailAsync = ref.watch(clubDetailProvider(widget.slug));

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Club'),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ErrorRetryView(
          message: 'Could not load this club.',
          onRetry: () => ref.invalidate(clubDetailProvider(widget.slug)),
        ),
        data: (club) {
          final tabCount = club.canModerate ? 4 : 3;
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
                    ClubAvatar(
                      name: club.name,
                      logoUrl: club.logoUrl,
                      radius: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (club.region != null || club.location != null)
                            Text(
                              [club.location, club.region]
                                  .whereType<String>()
                                  .where((v) => v.isNotEmpty)
                                  .join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (club.myMembership != null) ...[
                            const SizedBox(height: 8),
                            ClubMembershipChip(membership: club.myMembership!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (club.description?.trim().isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(
                    club.description!.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (club.websiteUrl?.isNotEmpty == true)
                      OutlinedButton.icon(
                        onPressed: () => launchUrl(
                          Uri.parse(club.websiteUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        icon: const Icon(Icons.language_outlined, size: 18),
                        label: const Text('Website'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('${AppConfig.websiteBaseUrl}/clubs/${club.slug}'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Open on web'),
                    ),
                    if (club.myMembership == null)
                      FilledButton(
                        onPressed: _membershipBusy ? null : () => _joinOrLeave(true),
                        child: _membershipBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Join club'),
                      ),
                    if (club.myMembership?.isActive == true)
                      OutlinedButton(
                        onPressed: _membershipBusy ? null : () => _joinOrLeave(false),
                        child: const Text('Leave'),
                      ),
                  ],
                ),
              ),
              TabBar(
                tabs: [
                  const Tab(text: 'Overview'),
                  const Tab(text: 'Events'),
                  const Tab(text: 'Leagues'),
                  if (club.canModerate) const Tab(text: 'Admin'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(club: club),
                    _EventsTab(
                      slug: club.slug,
                      clubId: club.id,
                      filter: _eventFilter,
                      onFilter: (f) => setState(() => _eventFilter = f),
                    ),
                    _LeaguesTab(slug: club.slug),
                    if (club.canModerate) ClubAdminTab(club: club),
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
  const _OverviewTab({required this.club});

  final ClubDetailModel club;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (club.upcomingEventsCount != null)
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Upcoming events'),
              trailing: Text('${club.upcomingEventsCount}'),
            ),
          ),
        if (club.canModerate && club.adminSummary != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Club admin',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${club.adminSummary!.pendingMembersCount} pending · '
                    '${club.adminSummary!.activeMembersCount} active · '
                    '${club.adminSummary!.probationMembersCount} on probation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open the Admin tab to approve requests, invite members, '
                    'and manage roles.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
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
    required this.slug,
    required this.clubId,
    required this.filter,
    required this.onFilter,
  });

  final String slug;
  final int clubId;
  final String filter;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnline = ref.watch(isOnlineProvider);
    final eventsAsync = ref.watch(
      clubEventsProvider((slug: slug, clubId: clubId, statusFilter: filter)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isOnline)
          Material(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Connect to load club events.',
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
                clubEventsProvider(
                  (slug: slug, clubId: clubId, statusFilter: filter),
                ),
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    'No $filter events for this club.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
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
    );
  }
}

class _LeaguesTab extends ConsumerWidget {
  const _LeaguesTab({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final leaguesAsync = ref.watch(clubLeaguesProvider(slug));

    return leaguesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => ErrorRetryView(
        message: 'Could not load leagues.',
        onRetry: () => ref.invalidate(clubLeaguesProvider(slug)),
      ),
      data: (leagues) {
        if (leagues.isEmpty) {
          return Center(
            child: Text(
              'No leagues for this club yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leagues.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final league = leagues[index];
            return AppCard(
              onTap: () => context.push(league.standingsPath(slug)),
              child: ListTile(
                title: Text(league.name),
                subtitle: league.disciplineName != null
                    ? Text(league.disciplineName!)
                    : null,
                trailing: league.isActive
                    ? const Icon(Icons.chevron_right)
                    : Text(
                        'Inactive',
                        style: theme.textTheme.labelSmall,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
