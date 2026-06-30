import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../models/user_access.dart';

class MobileSyncInactiveBanner extends ConsumerWidget {
  const MobileSyncInactiveBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    if (!auth.showMobileSyncInactiveBanner) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.sync_disabled_rounded,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mobileSyncInactiveMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (auth.isRefreshingProfile)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              )
            else
              TextButton(
                onPressed: () =>
                    ref.read(authStateProvider.notifier).refreshProfile(),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Refresh'),
              ),
          ],
        ),
      ),
    );
  }
}
