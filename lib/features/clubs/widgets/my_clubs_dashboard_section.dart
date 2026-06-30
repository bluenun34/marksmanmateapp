import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/club_models.dart';
import 'club_summary_card.dart';

class MyClubsDashboardSection extends StatelessWidget {
  const MyClubsDashboardSection({
    super.key,
    required this.clubs,
  });

  final List<ClubListItem> clubs;

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final preview = clubs.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My clubs',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CountBadge(count: clubs.length),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/clubs'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap a club for events, leagues, and membership.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final club = preview[index];
              return ClubSummaryCard(
                club: club,
                onTap: () => context.push(club.detailPath),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
