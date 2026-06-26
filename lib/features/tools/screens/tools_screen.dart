import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_screen_app_bar.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppScreenAppBar.main(context, title: 'Range Tools'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Field tools for use at the range. Your shoot log syncs to the website when you are back online.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _ToolCard(
            icon: Icons.timer_outlined,
            title: 'Shot timer',
            subtitle: 'Par time, splits — manual tap or microphone shot detection',
            onTap: () => context.push('/tools/shot-timer'),
          ),
          const SizedBox(height: 12),
          _ToolCard(
            icon: Icons.exposure_plus_1_outlined,
            title: 'Round counter',
            subtitle: 'Manual tap or mic auto-count — send total to Quick Log',
            onTap: () => context.push('/tools/round-counter'),
          ),
          const SizedBox(height: 12),
          _ToolCard(
            icon: Icons.center_focus_strong_outlined,
            title: 'Target group analyzer',
            subtitle:
                'Photo your target, state the size, mark hits, log the group',
            onTap: () => context.push('/tools/target-analyzer'),
          ),
          const SizedBox(height: 12),
          _ToolCard(
            icon: Icons.straighten_rounded,
            title: 'Phone level',
            subtitle:
                'Cant, pitch & azimuth from your phone — calibrate zero, bubble overlay',
            onTap: () => context.push('/tools/rifle-level'),
          ),
          const SizedBox(height: 12),
          _ToolCard(
            icon: Icons.flash_on_rounded,
            title: 'Quick log',
            subtitle: 'Minimal session entry — rounds, hits, discipline',
            onTap: () => context.push('/shoot-log/quick'),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
