import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../providers/locker_provider.dart';

class LockerScreen extends ConsumerWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locker = ref.watch(lockerProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          primary: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => MainShellScope.openDrawer(context),
          ),
          title: const Text('My Locker'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Firearms'),
              Tab(text: 'Ammo Loads'),
              Tab(text: 'Equipment'),
            ],
          ),
          actions: [
            if (isOnline)
              IconButton(
                icon: locker.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                tooltip: 'Sync from server',
                onPressed: locker.isLoading
                    ? null
                    : () async {
                        await ref.read(lockerProvider.notifier).refresh();
                        if (!context.mounted) return;
                        final updated = ref.read(lockerProvider);
                        if (updated.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(updated.error!)),
                          );
                        } else if (updated.firearms.isEmpty &&
                            updated.ammoLoads.isEmpty &&
                            updated.equipment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sync complete — no locker items on your account yet',
                              ),
                            ),
                          );
                        }
                      },
              ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (syncStatus.lastSyncedAt != null)
              Material(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Last synced ${formatLastSync(syncStatus.lastSyncedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: locker.error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: ColorTokens.danger, size: 40),
                      const SizedBox(height: 12),
                      Text(locker.error!, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            : TabBarView(
                children: [
                  // Firearms tab
                  locker.firearms.isEmpty
                      ? _emptyState(theme, 'No firearms cached',
                          'Sync to pull your locker from the server')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: locker.firearms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final f = locker.firearms[i];
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.settings_outlined,
                                      color: theme.colorScheme.primary,
                                      size: 20),
                                ),
                                title: Text(f.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${f.make ?? ''} ${f.model ?? ''}'
                                    '${f.calibre != null ? ' • ${f.calibre}' : ''}'.trim()),
                              ),
                            );
                          },
                        ),

                  // Ammo tab
                  locker.ammoLoads.isEmpty
                      ? _emptyState(theme, 'No ammo loads cached',
                          'Sync to pull your locker from the server')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: locker.ammoLoads.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final a = locker.ammoLoads[i];
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorTokens.accentBrass
                                        .withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.linear_scale_rounded,
                                      color: ColorTokens.accentBrass,
                                      size: 20),
                                ),
                                title: Text(a.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${a.calibre ?? ''}${a.manufacturer != null ? ' • ${a.manufacturer}' : ''}'),
                              ),
                            );
                          },
                        ),

                  // Equipment tab
                  locker.equipment.isEmpty
                      ? _emptyState(theme, 'No equipment cached',
                          'Sync to pull your locker from the server')
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: locker.equipment.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final e = locker.equipment[i];
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.build_outlined,
                                      color: theme.colorScheme.secondary,
                                      size: 20),
                                ),
                                title: Text(e.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  [
                                    if (e.category != null) e.category,
                                    if (e.brand != null) e.brand,
                                  ].join(' • '),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme, String title, String subtitle) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      );
}
