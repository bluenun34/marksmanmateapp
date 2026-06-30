import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../providers/auth_provider.dart';

class ProRequiredScreen extends ConsumerWidget {
  const ProRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final user = auth.user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.workspace_premium_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Pro subscription required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'The MarksmanMate mobile app is included with Pro User. '
                'Upgrade on the website, then refresh your profile here.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (user != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      user.plan != null
                          ? '${user.email}\nPlan: ${user.plan}'
                          : user.email,
                    ),
                    isThreeLine: user.plan != null,
                  ),
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: auth.isRefreshingProfile
                    ? null
                    : () => ref.read(authStateProvider.notifier).refreshProfile(),
                icon: auth.isRefreshingProfile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(
                  auth.isRefreshingProfile
                      ? 'Checking subscription…'
                      : 'Refresh profile',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(AppConfig.billingUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Upgrade on website'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () => ref.read(authStateProvider.notifier).logout(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
