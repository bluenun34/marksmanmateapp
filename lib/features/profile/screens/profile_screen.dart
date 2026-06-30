import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';
import '../../../shared/widgets/user_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppScreenAppBar.back(context, title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  UserAvatar(
                    name: user?.name,
                    avatarUrl: user?.avatarUrl,
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Unknown',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (user?.plan != null) ...[
                    const SizedBox(height: 12),
                    Chip(
                      avatar: const Icon(Icons.workspace_premium_outlined, size: 18),
                      label: Text(user!.plan!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_browser),
                  title: const Text('Edit profile on website'),
                  subtitle: const Text('Name, password, and account settings'),
                  onTap: () => launchUrl(
                    Uri.parse(AppConfig.profileUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1),
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
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('App settings'),
                  subtitle: const Text('Units, theme, sync, and security'),
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
