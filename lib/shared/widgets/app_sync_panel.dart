import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/sync/sync_service.dart';
import '../../core/sync/sync_status_provider.dart';
import '../../core/theme/color_tokens.dart';
import '../../features/shoot_log/providers/shoot_log_provider.dart';

/// Online/offline and sync controls shown inside the navigation drawer.
class AppSyncPanel extends ConsumerWidget {
  const AppSyncPanel({super.key});

  Future<void> _handleTap(WidgetRef ref, BuildContext context) async {
    final sync = ref.read(syncStatusProvider);
    if (sync.isSyncing) return;

    final result =
        await ref.read(syncStatusProvider.notifier).syncAllDetailed();
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (result.ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.sessionCount > 0
                ? 'Synced ${result.sessionCount} session${result.sessionCount == 1 ? '' : 's'}'
                : 'Sync complete — no sessions found on server',
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Sync failed'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectivity = ref.watch(connectivityProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final sessions = ref.watch(shootLogProvider).value ?? const [];
    final pending =
        sessions.where((s) => s.syncStatus == 'pending').length;
    final errors =
        sessions.where((s) => s.syncStatus == 'error').length;

    final connectivityLoading = connectivity.isLoading;
    final statusColor = connectivityLoading
        ? theme.colorScheme.onSurfaceVariant
        : isOnline
            ? ColorTokens.accentGreen
            : ColorTokens.accentBrass;
    final statusIcon = connectivityLoading
        ? Icons.wifi_find_rounded
        : isOnline
            ? Icons.wifi_rounded
            : Icons.wifi_off_rounded;
    final statusLabel = connectivityLoading
        ? 'Checking connection…'
        : isOnline
            ? 'Online'
            : 'Offline';

    final syncLabel = syncStatus.isSyncing
        ? 'Syncing shoot log & locker…'
        : syncStatus.lastError != null
            ? syncStatus.lastError!
            : syncStatus.lastSyncedAt == null
                ? 'Tap to sync with ${AppConfig.isProduction ? 'marksmanmate.com' : 'dev API'}'
                : '${sessions.length} session${sessions.length == 1 ? '' : 's'} · ${formatLastSync(syncStatus.lastSyncedAt!)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: syncStatus.isSyncing ? null : () => _handleTap(ref, context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (syncStatus.lastError != null
                            ? ColorTokens.danger
                            : statusColor)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: syncStatus.isSyncing
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: statusColor,
                          ),
                        )
                      : Icon(
                          syncStatus.lastError != null
                              ? Icons.error_outline_rounded
                              : statusIcon,
                          size: 18,
                          color: syncStatus.lastError != null
                              ? ColorTokens.danger
                              : statusColor,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            statusLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                          if (pending > 0) ...[
                            const SizedBox(width: 8),
                            _Chip(
                              label: '$pending pending',
                              color: ColorTokens.accentBrass,
                            ),
                          ],
                          if (errors > 0) ...[
                            const SizedBox(width: 8),
                            _Chip(
                              label: '$errors failed',
                              color: ColorTokens.danger,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        syncLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: syncStatus.lastError != null
                              ? ColorTokens.danger
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!syncStatus.isSyncing)
                  Icon(
                    Icons.sync_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
