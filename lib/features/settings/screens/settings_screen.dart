import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/preferences/app_preferences.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/settings/providers/biometric_provider.dart';
import '../../../features/settings/providers/theme_provider.dart';
import '../../../features/settings/widgets/notification_preferences_section.dart';
import '../../../shared/shoot_log/shoot_log_constants.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.main(context, title: 'Settings'),
      body: ListView(
        children: [
          // Account section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Account',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(auth.user?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(auth.user?.email ?? ''),
                ),
                const Divider(height: 1),
                if (auth.user?.plan != null) ...[
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: const Text('Plan'),
                    trailing: Chip(label: Text(auth.user!.plan!)),
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text('Edit profile on website'),
                  subtitle: const Text('Name, password, and account settings'),
                  onTap: () => launchUrl(
                    Uri.parse(AppConfig.profileUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Refresh profile'),
                  subtitle: const Text(
                    'Update plan and subscription status from the server',
                  ),
                  trailing: auth.isRefreshingProfile
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: auth.isRefreshingProfile
                      ? null
                      : () => ref
                          .read(authStateProvider.notifier)
                          .refreshProfile(),
                ),
              ],
            ),
          ),

          // Units section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Units',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder(
              future: Future.wait([
                ref.read(appPreferencesProvider).distanceUnit(),
                ref.read(appPreferencesProvider).groupSizeUnit(),
              ]),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 96,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final distanceUnit = snap.data![0] as String;
                final groupUnit = snap.data![1] as String;
                return Column(
                  children: [
                    ListTile(
                      title: const Text('Default distance unit'),
                      trailing: DropdownButton<String>(
                        value: distanceUnit,
                        underline: const SizedBox(),
                        items: ShootLogConstants.distanceUnits
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          await ref
                              .read(appPreferencesProvider)
                              .setDistanceUnit(v);
                          if (context.mounted) {
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Default group size unit'),
                      trailing: DropdownButton<String>(
                        value: groupUnit,
                        underline: const SizedBox(),
                        items: ShootLogConstants.groupSizeUnits
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          await ref
                              .read(appPreferencesProvider)
                              .setGroupSizeUnit(v);
                          if (context.mounted) {
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Appearance',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Theme'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(
                          value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(
                          value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeModeProvider.notifier).set(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const NotificationPreferencesSection(),

          // Security section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Security',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ref.watch(biometricAvailableProvider).when(
                  loading: () => const ListTile(
                    title: Text('App lock'),
                    subtitle: Text('Checking biometrics…'),
                  ),
                  error: (_, __) => const ListTile(
                    title: Text('App lock'),
                    subtitle: Text('Biometrics unavailable on this device'),
                  ),
                  data: (available) {
                    if (!available) {
                      return const ListTile(
                        title: Text('App lock'),
                        subtitle: Text('Biometrics unavailable on this device'),
                      );
                    }
                    final enabled = ref.watch(biometricLockProvider);
                    return SwitchListTile(
                      title: const Text('Require unlock to open app'),
                      subtitle: const Text(
                        'Use fingerprint, Face ID, or device PIN after leaving the app',
                      ),
                      value: enabled,
                      onChanged: (value) => ref
                          .read(biometricLockProvider.notifier)
                          .setEnabled(value),
                    );
                  },
                ),
          ),

          // Sync section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Sync',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dns_outlined),
                  title: const Text('API server'),
                  subtitle: Text(AppConfig.apiBaseUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync_rounded),
                  title: const Text('Last synced'),
                  subtitle: Text(
                    syncStatus.lastSyncedAt != null
                        ? formatLastSync(syncStatus.lastSyncedAt!)
                        : 'Not synced yet',
                  ),
                ),
                if (syncStatus.lastError != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.error_outline_rounded,
                        color: theme.colorScheme.error),
                    title: Text(
                      syncStatus.lastError!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: syncStatus.isSyncing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.cloud_sync_rounded),
                  title: const Text('Sync now'),
                  subtitle: Text(
                    AppConfig.isProduction
                        ? 'Pull shoot log and locker from marksmanmate.com'
                        : 'Debug build uses local API — use prod env if data is on the website',
                  ),
                  enabled: !syncStatus.isSyncing,
                  onTap: () async {
                    final result = await ref
                        .read(syncStatusProvider.notifier)
                        .syncAllDetailed();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.ok
                              ? result.sessionCount > 0
                                  ? 'Synced ${result.sessionCount} session${result.sessionCount == 1 ? '' : 's'}'
                                  : 'Sync complete — no sessions on this API'
                              : result.error ?? 'Sync failed',
                        ),
                        duration: Duration(seconds: result.ok ? 3 : 5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // About section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('About',
                style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data == null
                        ? '…'
                        : '${snapshot.data!.version} (${snapshot.data!.buildNumber})';
                    return ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('Version'),
                      trailing: Text(version, style: const TextStyle(fontSize: 13)),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.my_location_rounded),
                  title: const Text('MarksmanMate'),
                  subtitle: const Text('UK Shooting Sports Platform'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    final uri = Uri.parse('https://marksmanmate.com');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            ),
          ),

          // Sign out
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(authStateProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
