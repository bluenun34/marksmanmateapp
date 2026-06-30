import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';

/// Tappable display name that opens the user's profile.
class UserProfileLink extends ConsumerWidget {
  const UserProfileLink({
    super.key,
    required this.userId,
    required this.name,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final int userId;
  final String name;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resolvedStyle = (style ?? theme.textTheme.bodyMedium)?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: () => openUserProfile(context, ref, userId),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          name,
          style: resolvedStyle,
          maxLines: maxLines,
          overflow: overflow,
          textAlign: textAlign,
        ),
      ),
    );
  }
}

void openUserProfile(BuildContext context, WidgetRef ref, int userId) {
  final currentUserId = ref.read(authStateProvider).user?.id;
  if (currentUserId != null && currentUserId == userId) {
    context.push('/profile');
    return;
  }
  context.push('/users/$userId');
}
