import 'package:flutter/material.dart';

import '../../core/network/media_url.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.name,
    this.avatarUrl,
    this.radius = 20,
    this.backgroundColor,
  });

  final String? name;
  final String? avatarUrl;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = resolveMediaUrl(avatarUrl);
    final initial = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primaryContainer,
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
  }
}
