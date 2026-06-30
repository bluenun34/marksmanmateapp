import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/group_models.dart';
import 'group_summary_card.dart';

class MyGroupsDashboardSection extends StatelessWidget {
  const MyGroupsDashboardSection({
    super.key,
    required this.groups,
  });

  final List<GroupListItem> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final preview = groups.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.group_work_outlined,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My groups',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CountBadge(count: groups.length),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/groups'),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Private shooting groups for friends and practice mates.',
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
              final group = preview[index];
              return GroupSummaryCard(
                group: group,
                onTap: () => context.push(group.detailPath),
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
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
