import 'package:flutter/material.dart';
import '../../core/theme/color_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final labelLineHeight =
        (labelStyle?.fontSize ?? 11) * (labelStyle?.height ?? 1.2);
    final labelBoxHeight =
        MediaQuery.textScalerOf(context).scale(labelLineHeight * 2);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: labelBoxHeight,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );

    return AppCard(
      onTap: onTap,
      child: content,
    );
  }
}

class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'synced':
        color = ColorTokens.accentGreen;
        label = 'Synced';
      case 'error':
        color = ColorTokens.danger;
        label = 'Error';
      case 'conflict':
        color = Colors.deepOrange;
        label = 'Conflict';
      default:
        color = ColorTokens.accentBrass;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
