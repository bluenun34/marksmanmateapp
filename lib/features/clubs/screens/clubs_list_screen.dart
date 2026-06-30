import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/error_retry_view.dart';
import '../providers/clubs_provider.dart';
import '../widgets/club_summary_card.dart';
import '../widgets/club_ui_helpers.dart';

class ClubsListScreen extends ConsumerWidget {
  const ClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnline = ref.watch(isOnlineProvider);
    final clubsAsync = ref.watch(myClubsProvider);

    return Scaffold(
      appBar: AppScreenAppBar.main(context, title: 'My clubs'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isOnline)
            Material(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Connect to the internet to view your clubs.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          Expanded(
            child: clubsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => ErrorRetryView(
                message: 'Could not load your clubs.',
                onRetry: () => ref.invalidate(myClubsProvider),
              ),
              data: (clubs) {
                if (clubs.isEmpty) {
                  return _EmptyClubsState();
                }

                final pendingCount = clubs
                    .where((c) => clubStatusNeedsAttention(c.status))
                    .length;

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(myClubsProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Text(
                        '${clubs.length} club${clubs.length == 1 ? '' : 's'}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pendingCount > 0) ...[
                        const SizedBox(height: 8),
                        Material(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '$pendingCount membership request'
                                    '${pendingCount == 1 ? '' : 's'} awaiting approval.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (final club in clubs) ...[
                        ClubListCard(
                          club: club,
                          onTap: () => context.push(club.detailPath),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyClubsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No clubs yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join your shooting club on MarksmanMate to see events, leagues, and club activity here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => launchUrl(
                Uri.parse('${AppConfig.websiteBaseUrl}/clubs'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Browse clubs'),
            ),
          ],
        ),
      ),
    );
  }
}
