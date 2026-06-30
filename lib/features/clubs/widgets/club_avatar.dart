import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';
import '../../../shared/models/club_models.dart';
import 'club_ui_helpers.dart';

class ClubAvatar extends StatelessWidget {
  const ClubAvatar({
    super.key,
    required this.name,
    this.logoUrl,
    this.radius = 24,
    this.showRing = false,
  });

  final String name;
  final String? logoUrl;
  final double radius;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = resolveMediaUrl(logoUrl);
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: resolved != null ? NetworkImage(resolved) : null,
      child: resolved == null
          ? Text(
              initial,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.85,
              ),
            )
          : null,
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

class ClubMembershipChip extends StatelessWidget {
  const ClubMembershipChip({super.key, required this.membership});

  final ClubMembershipRef membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final needsAttention = clubStatusNeedsAttention(membership.status);
    final label = membership.status == 'active'
        ? formatClubRole(membership.role)
        : formatClubStatus(membership.status);
    final color = needsAttention
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

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
