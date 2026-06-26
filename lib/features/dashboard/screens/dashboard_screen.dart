import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/events/providers/events_provider.dart';
import '../../../features/onboarding/onboarding_dialog.dart';
import '../../../features/shoot_log/providers/shoot_log_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.main(
        context,
        title: 'MarksmanMate',
        actions: [
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'quick_log',
            onPressed: () => context.push('/shoot-log/quick'),
            icon: const Icon(Icons.flash_on_rounded),
            label: const Text('Quick Log'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'full_log',
            onPressed: () => context.go('/shoot-log/new'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Full Log'),
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
                      Row(children: [
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
                      ]),
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
                      eventsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (events) {
                          if (events.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming events',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              ...events.take(3).map(
                                    (event) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: AppCard(
                                        onTap: () => context.go(event.logPath),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event.name,
                                                    style: theme
                                                        .textTheme.titleSmall
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (event.eventDate != null)
                                                    Text(
                                                      '${event.eventDate!.day}/${event.eventDate!.month}/${event.eventDate!.year}${event.startTime != null ? ' • ${event.startTime}' : ''}',
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: theme.colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  if (event.location
                                                          ?.isNotEmpty ==
                                                      true)
                                                    Text(
                                                      event.location!,
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: theme.colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
                      Text(
                        'At the range',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickActionChip(
                            icon: Icons.flash_on_rounded,
                            label: 'Quick log',
                            onTap: () => context.push('/shoot-log/quick'),
                          ),
                          _QuickActionChip(
                            icon: Icons.timer_outlined,
                            label: 'Shot timer',
                            onTap: () => context.push('/tools/shot-timer'),
                          ),
                          _QuickActionChip(
                            icon: Icons.exposure_plus_1_outlined,
                            label: 'Round counter',
                            onTap: () => context.push('/tools/round-counter'),
                          ),
                          _QuickActionChip(
                            icon: Icons.open_in_browser_rounded,
                            label: 'Open website',
                            onTap: () async {
                              final uri = Uri.parse('https://marksmanmate.com');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Recent Sessions',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (sessions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.track_changes_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No sessions yet',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                            'Tap "New Session" to log your first shoot',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList.builder(
                    itemCount: sessions.take(5).length,
                    itemBuilder: (ctx, i) {
                      final s = sessions[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          onTap: () => context.push(s.detailPath),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(disciplineLabel(s.discipline),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${sessionTypeLabel(s.sessionType)} • ${s.rangeName.isNotEmpty ? s.rangeName : 'No range name'}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              SyncBadge(status: s.syncStatus),
                            ],
                          ),
                        ),
                      );
                    },
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

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
