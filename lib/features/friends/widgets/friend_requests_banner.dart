import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/notification_models.dart';

class PendingFriendRequestsBanner extends StatelessWidget {
  const PendingFriendRequestsBanner({
    super.key,
    required this.summary,
  });

  final NotificationSummary summary;

  @override
  Widget build(BuildContext context) {
    final count = summary.pendingFriendRequests;
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/friends'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$count friend request${count == 1 ? '' : 's'} waiting',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
