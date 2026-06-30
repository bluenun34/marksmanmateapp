import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../shoot_log/providers/shoot_log_provider.dart';
import '../services/shoot_log_analytics_service.dart';

class ShootLogAnalyticsScreen extends ConsumerWidget {
  const ShootLogAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final sessionsAsync = ref.watch(shootLogProvider);
    final hasPremium = auth.user?.plan != null &&
        auth.user!.plan!.isNotEmpty &&
        auth.user!.plan != 'free';

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Shoot log analytics'),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load sessions.')),
        data: (sessions) {
          final analytics = buildShootLogAnalytics(sessions);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!hasPremium)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic analytics on device',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full charts and club comparisons are available on '
                          'marksmanmate.com with a premium plan.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Sessions',
                      value: '${analytics.totalSessions}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Total rounds',
                      value: '${analytics.totalRounds}',
                      accent: ColorTokens.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'This month',
                      value: '${analytics.roundsThisMonth} rds',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Hit rate',
                      value: analytics.hitRatePercent != null
                          ? '${analytics.hitRatePercent}%'
                          : '—',
                    ),
                  ),
                ],
              ),
              if (analytics.avgRating != null) ...[
                const SizedBox(height: 12),
                _StatCard(
                  label: 'Average rating',
                  value: analytics.avgRating!.toStringAsFixed(1),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Rounds by discipline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (analytics.roundsByDiscipline.isEmpty)
                Text(
                  'Log sessions to see discipline breakdown.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final row in analytics.roundsByDiscipline)
                  _BarRow(label: row.label, value: row.rounds, max: analytics.totalRounds),
              const SizedBox(height: 24),
              Text(
                'Recent months',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              for (final row in analytics.roundsByMonth)
                _BarRow(
                  label: row.label,
                  value: row.rounds,
                  max: analytics.totalRounds,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

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
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.max,
  });

  final String label;
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = max > 0 ? value / max : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$value'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
