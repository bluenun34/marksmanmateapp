import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/notification_models.dart';

class GroupInvitesBanner extends StatelessWidget {
  const GroupInvitesBanner({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/groups'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.group_add_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$count group invite${count == 1 ? '' : 's'} waiting',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PendingGroupInvitesBanner extends StatelessWidget {
  const PendingGroupInvitesBanner({
    super.key,
    required this.summary,
  });

  final NotificationSummary summary;

  @override
  Widget build(BuildContext context) {
    return GroupInvitesBanner(count: summary.pendingGroupInvites);
  }
}
