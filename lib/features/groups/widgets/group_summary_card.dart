import 'package:flutter/material.dart';

import '../../../shared/models/group_models.dart';
import 'group_avatar.dart';
import 'group_ui_helpers.dart';

class GroupSummaryCard extends StatelessWidget {
  const GroupSummaryCard({
    super.key,
    required this.group,
    required this.onTap,
    this.width = 132,
  });

  final GroupListItem group;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = groupStatusNeedsAttention(group.status);
    final statusLabel = formatGroupStatus(group.status);
    final roleLabel = formatGroupRole(group.role);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: needsAttention
              ? theme.colorScheme.tertiary.withValues(alpha: 0.45)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GroupAvatar(name: group.name, radius: 20, showRing: true),
                    const Spacer(),
                    if (needsAttention)
                      Icon(
                        Icons.mail_outline,
                        size: 16,
                        color: theme.colorScheme.tertiary,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      group.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _MetaChip(
                  label: group.status == 'active' ? roleLabel : statusLabel,
                  color: needsAttention
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupListCard extends StatelessWidget {
  const GroupListCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  final GroupListItem group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = groupStatusNeedsAttention(group.status);
    final statusLabel = formatGroupStatus(group.status);
    final roleLabel = formatGroupRole(group.role);
    final memberLabel = group.memberCount != null
        ? '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}'
        : null;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              GroupAvatar(name: group.name, radius: 26, showRing: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        group.status == 'active'
                            ? '$roleLabel · $statusLabel'
                            : statusLabel,
                        memberLabel,
                      ].whereType<String>().join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (needsAttention)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
