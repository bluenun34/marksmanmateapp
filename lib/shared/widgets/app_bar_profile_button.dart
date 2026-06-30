import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'user_avatar.dart';

/// Profile avatar for main tab app bars; opens the profile screen on tap.
class AppBarProfileButton extends ConsumerWidget {
  const AppBarProfileButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: 'Profile',
        onPressed: () => context.push('/profile'),
        icon: UserAvatar(
          name: auth.user?.name,
          avatarUrl: auth.user?.avatarUrl,
          radius: 16,
        ),
      ),
    );
  }
}
