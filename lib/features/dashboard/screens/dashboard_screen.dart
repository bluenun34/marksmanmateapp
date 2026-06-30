import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_service.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/clubs/providers/clubs_provider.dart';
import '../../../features/clubs/widgets/my_clubs_dashboard_section.dart';
import '../../../features/groups/providers/groups_provider.dart';
import '../../../features/groups/widgets/my_groups_dashboard_section.dart';
import '../../../features/events/providers/events_provider.dart';
import '../../../features/events/widgets/event_status_chip.dart';
import '../../../features/friends/widgets/friend_requests_banner.dart';
import '../../../features/groups/widgets/group_invites_banner.dart';
import '../../../shared/models/notification_models.dart';
import '../../../features/notifications/providers/notifications_provider.dart';
import '../../../features/settings/providers/notification_preferences_provider.dart';
import '../../../core/notifications/notification_preference_catalog.dart';
import '../../../features/onboarding/onboarding_dialog.dart';
import '../../../features/shoot_log/providers/shoot_log_provider.dart';
import '../../../features/shoot_log/widgets/structured_log_reminders_section.dart';
import '../../../shared/models/event_models.dart';
import '../../../shared/shoot_log/shoot_log_labels.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_retry_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOnboarding();
      _scheduleEventReminders();
    });
  }

  Future<void> _scheduleEventReminders() async {
    if (!ref.read(isOnlineProvider)) return;
    if (!ref
        .read(notificationPreferencesProvider)
        .isOn(NotificationPreferenceKey.upcomingEvents)) {
      return;
    }
    try {
      final events = await ref.read(apiServiceProvider).getUpcomingEvents(limit: 5);
      final prefs = ref.read(appPreferencesProvider);
      final scheduled = await prefs.scheduledEventReminderIds();
      final now = DateTime.now();
      for (final event in events) {
        if (scheduled.contains(event.id) || event.eventDate == null) continue;
        final start = event.eventDate!;
        final diff = start.difference(now);
        if (diff.inHours > 0 && diff.inHours <= 24) {
          await LocalNotificationsService.instance.showEventReminder(
            eventId: event.id,
            title: 'Upcoming: ${event.name}',
            body: event.startTime != null
                ? 'Starts at ${event.startTime}'
                : 'Check in from the MarksmanMate app',
          );
          await prefs.markEventReminderScheduled(event.id);
        }
      }
    } catch (_) {}
  }

  Future<void> _maybeShowOnboarding() async {
    final prefs = ref.read(appPreferencesProvider);
    final complete = await prefs.isOnboardingComplete();
    if (!mounted) return;
    await OnboardingDialog.showIfNeeded(
      context,
      onboardingComplete: complete,
      onComplete: () => prefs.setOnboardingComplete(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final sessionsAsync = ref.watch(shootLogProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final clubsAsync = ref.watch(myClubsProvider);
    final groupsAsync = ref.watch(myGroupsProvider);
    final summaryAsync = ref.watch(notificationSummaryProvider);
    final theme = Theme.of(context);
    final badgeCount = summaryAsync.maybeWhen(
      data: (NotificationSummary summary) => summary.totalBadge,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppScreenAppBar.main(
        context,
        title: 'MarksmanMate',
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorRetryView(
          message: 'Could not load your sessions.',
          onRetry: () => ref.read(shootLogProvider.notifier).reloadLocal(),
        ),
        data: (sessions) {
          final pending =
              sessions.where((s) => s.syncStatus == 'pending').length;
          final conflicts =
              sessions.where((s) => s.syncStatus == 'conflict').length;
          final totalHits = sessions.fold<int>(
            0,
            (acc, s) => acc + (s.local.totalHits ?? 0),
          );
          final totalMisses = sessions.fold<int>(
            0,
            (acc, s) => acc + (s.local.totalMisses ?? 0),
          );
          final hitAttempts = totalHits + totalMisses;
          final hitRate = hitAttempts > 0
              ? (100 * totalHits / hitAttempts).round()
              : null;
          final now = DateTime.now();
          final thisMonth = sessions
              .where((s) => s.date.year == now.year && s.date.month == now.month)
              .fold(0, (acc, s) => acc + (s.totalRounds ?? 0));

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${auth.user?.name.split(' ').first ?? 'Shooter'} 👋',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _connectivityLabel(
                          isOnline,
                          syncStatus.lastSyncedAt,
                          syncStatus.isSyncing,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOnline
                              ? ColorTokens.accentGreen
                              : ColorTokens.accentBrass,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Sessions',
                              value: '${sessions.length}',
                              icon: Icons.format_list_bulleted_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Rounds this month',
                              value: '$thisMonth',
                              icon: Icons.my_location_rounded,
                              accent: ColorTokens.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      if (hitRate != null) ...[
                        const SizedBox(height: 12),
                        StatCard(
                          label: 'Hit rate (all sessions)',
                          value: '$hitRate%',
                          icon: Icons.track_changes_outlined,
                          accent: ColorTokens.accentGreen,
                        ),
                      ],
                      if (pending > 0) ...[
                        const SizedBox(height: 12),
                        StatCard(
                          label: 'Pending sync',
                          value: '$pending session${pending > 1 ? 's' : ''}',
                          icon: Icons.cloud_upload_outlined,
                          accent: ColorTokens.accentBrass,
                          onTap: () => ref
                              .read(syncStatusProvider.notifier)
                              .syncAllDetailed(),
                        ),
                      ],
                      if (conflicts > 0) ...[
                        const SizedBox(height: 12),
                        StatCard(
                          label: 'Sync conflicts',
                          value: '$conflicts session${conflicts > 1 ? 's' : ''}',
                          icon: Icons.warning_amber_rounded,
                          accent: ColorTokens.danger,
                          onTap: () => context.go('/shoot-log'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      summaryAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (summary) => Column(
                          children: [
                            PendingFriendRequestsBanner(summary: summary),
                            PendingGroupInvitesBanner(summary: summary),
                          ],
                        ),
                      ),
                      clubsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (clubs) => MyClubsDashboardSection(clubs: clubs),
                      ),
                      groupsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (groups) => MyGroupsDashboardSection(groups: groups),
                      ),
                      const StructuredLogRemindersSection(
                        compact: true,
                        maxItems: 2,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/shoot-log/analytics'),
                        icon: const Icon(Icons.insights_outlined),
                        label: const Text('Shoot log analytics'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sessions & events',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/shoot-log'),
                                child: const Text('Log'),
                              ),
                              TextButton(
                                onPressed: () => context.push('/events'),
                                child: const Text('Events'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SessionsAndEventsFeed(
                        theme: theme,
                        sessions: sessions,
                        eventsAsync: eventsAsync,
                      ),
                      const SizedBox(height: 24),
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

  String _connectivityLabel(
    bool isOnline,
    DateTime? lastSyncedAt,
    bool isSyncing,
  ) {
    if (isSyncing) return 'Syncing…';
    if (!isOnline) return 'Offline mode';
    if (lastSyncedAt == null) return 'Connected';
    return 'Connected · Last sync ${formatLastSync(lastSyncedAt)}';
  }
}

class _SessionsAndEventsFeed extends StatelessWidget {
  const _SessionsAndEventsFeed({
    required this.theme,
    required this.sessions,
    required this.eventsAsync,
  });

  final ThemeData theme;
  final List<SessionItem> sessions;
  final AsyncValue<List<EventModel>> eventsAsync;

  @override
  Widget build(BuildContext context) {
    final recentSessions = sessions.take(5).toList();

    return eventsAsync.when(
      loading: () => _buildFeed(
        context,
        upcomingEvents: const [],
        recentSessions: recentSessions,
      ),
      error: (_, __) => _buildFeed(
        context,
        upcomingEvents: const [],
        recentSessions: recentSessions,
      ),
      data: (events) => _buildFeed(
        context,
        upcomingEvents: events.take(3).toList(),
        recentSessions: recentSessions,
      ),
    );
  }

  Widget _buildFeed(
    BuildContext context, {
    required List<EventModel> upcomingEvents,
    required List<SessionItem> recentSessions,
  }) {
    if (upcomingEvents.isEmpty && recentSessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text('Nothing here yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Logged sessions and club events you are invited to will show up here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcomingEvents.isNotEmpty) ...[
          Text(
            'Upcoming',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...upcomingEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => context.push(event.detailPath),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (event.clubName?.isNotEmpty == true)
                            Text(
                              event.clubName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (event.eventDate != null)
                            Text(
                              _formatEventDate(event),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    EventStatusChip.fromEvent(event, compact: true),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (upcomingEvents.isNotEmpty && recentSessions.isNotEmpty)
          const SizedBox(height: 12),
        if (recentSessions.isNotEmpty) ...[
          Text(
            'Recent sessions',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...recentSessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                onTap: () => context.push(session.detailPath),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disciplineLabel(session.discipline),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sessionTypeLabel(session.sessionType)} • ${session.rangeName.isNotEmpty ? session.rangeName : 'No range name'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatSessionDate(session.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SyncBadge(status: session.syncStatus),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatEventDate(EventModel event) {
    final date = event.eventDate!;
    final dateText =
        '${date.day}/${date.month}/${date.year}${event.startTime != null ? ' • ${event.startTime}' : ''}';
    return dateText;
  }

  String _formatSessionDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
