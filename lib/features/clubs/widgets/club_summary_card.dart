import 'package:flutter/material.dart';

import '../../../shared/models/club_models.dart';
import 'club_avatar.dart';
import 'club_ui_helpers.dart';

/// Compact club tile for horizontal lists (e.g. home dashboard).
class ClubSummaryCard extends StatelessWidget {
  const ClubSummaryCard({
    super.key,
    required this.club,
    required this.onTap,
    this.width = 132,
  });

  final ClubListItem club;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = clubStatusNeedsAttention(club.status);
    final statusLabel = formatClubStatus(club.status);
    final roleLabel = formatClubRole(club.role);

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
                    ClubAvatar(
                      name: club.name,
                      logoUrl: club.logoUrl,
                      radius: 20,
                      showRing: true,
                    ),
                    const Spacer(),
                    if (needsAttention)
                      Icon(
                        Icons.hourglass_top_rounded,
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
                      club.name,
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
                  label: club.status == 'active' ? roleLabel : statusLabel,
                  color: needsAttention
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width club row for the clubs list screen.
class ClubListCard extends StatelessWidget {
  const ClubListCard({
    super.key,
    required this.club,
    required this.onTap,
  });

  final ClubListItem club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = clubStatusNeedsAttention(club.status);
    final statusLabel = formatClubStatus(club.status);
    final roleLabel = formatClubRole(club.role);

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
              ClubAvatar(
                name: club.name,
                logoUrl: club.logoUrl,
                radius: 26,
                showRing: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.status == 'active'
                          ? '$roleLabel · $statusLabel'
                          : statusLabel,
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
                    Icons.hourglass_top_rounded,
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
