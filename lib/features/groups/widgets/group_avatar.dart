import 'package:flutter/material.dart';

import '../../../shared/models/group_models.dart';
import 'group_ui_helpers.dart';

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.showRing = false,
  });

  final String name;
  final double radius;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.secondaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );

    if (!showRing) return avatar;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: avatar,
    );
  }
}

class GroupMembershipChip extends StatelessWidget {
  const GroupMembershipChip({super.key, required this.membership});

  final GroupMembershipRef membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = groupStatusNeedsAttention(membership.status);
    final label = membership.status == 'active'
        ? formatGroupRole(membership.role)
        : formatGroupStatus(membership.status);
    final color = needsAttention
        ? theme.colorScheme.tertiary
        : theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
