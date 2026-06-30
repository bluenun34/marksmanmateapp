import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/events/providers/events_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../../shared/models/notification_models.dart';
import 'app_screen_app_bar.dart';
import 'app_sync_panel.dart';
import 'connectivity_banner.dart';
import 'mobile_sync_inactive_banner.dart';
import 'user_avatar.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _mainNavItems = [
    ('/dashboard', Icons.home_outlined, Icons.home_rounded, 'Home'),
    ('/shoot-log', Icons.track_changes_outlined, Icons.track_changes, 'Shoot log'),
    ('/tools', Icons.build_outlined, Icons.build_rounded, 'Range tools'),
    ('/locker', Icons.lock_outline_rounded, Icons.lock_rounded, 'Locker'),
    ('/settings', Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  static const _communityNavItems = [
    ('/notifications', Icons.notifications_outlined, Icons.notifications, 'Notifications'),
    ('/messages', Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages'),
    ('/events', Icons.event_outlined, Icons.event, 'Events'),
    ('/clubs', Icons.groups_outlined, Icons.groups, 'My clubs'),
    ('/groups', Icons.group_work_outlined, Icons.group_work, 'My groups'),
    ('/friends', Icons.person_outline, Icons.person, 'Friends'),
  ];

  static const _quickActions = [
    ('/shoot-log/quick', Icons.flash_on_outlined, Icons.flash_on_rounded, 'Quick'),
    ('/shoot-log/new', Icons.add_outlined, Icons.add_rounded, 'New'),
    ('/tools/shot-timer', Icons.timer_outlined, Icons.timer, 'Timer'),
    (
      '/tools/round-counter',
      Icons.exposure_plus_1_outlined,
      Icons.exposure_plus_1,
      'Count',
    ),
    (
      '/tools/target-analyzer',
      Icons.center_focus_strong_outlined,
      Icons.center_focus_strong,
      'Target',
    ),
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isQuickActionRoute([String? location]) {
    final loc = location ?? widget.location;
    return _quickActions.any((action) => loc.startsWith(action.$1));
  }

  bool _isMainNavSelected(String path) {
    if (_isQuickActionRoute()) return false;
    if (path == '/shoot-log') {
      return widget.location == '/shoot-log';
    }
    if (path == '/tools') {
      return widget.location == '/tools';
    }
    return widget.location == path || widget.location.startsWith('$path/');
  }

  bool _isCommunityNavSelected(String path) {
    return widget.location == path || widget.location.startsWith('$path/');
  }

  int? _quickActionIndex() {
    for (var i = 0; i < _quickActions.length; i++) {
      if (widget.location.startsWith(_quickActions[i].$1)) return i;
    }
    return null;
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _go(String path) {
    Navigator.of(context).pop();
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider);
    final summaryAsync = ref.watch(notificationSummaryProvider);
    final badgeCount = summaryAsync.maybeWhen(
      data: (NotificationSummary summary) => summary.totalBadge,
      orElse: () => 0,
    );
    final activeQuickIndex = _quickActionIndex();

    return MainShellScope(
      onOpenDrawer: _openDrawer,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerProfileHeader(
                  name: auth.user?.name,
                  email: auth.user?.email,
                  avatarUrl: auth.user?.avatarUrl,
                  onTap: () => _go('/profile'),
                ),
                const AppSyncPanel(),
                const Divider(height: 1),
                const _DrawerSectionLabel('Main'),
                for (final item in _mainNavItems) ...[
                  _DrawerNavTile(
                    label: item.$4,
                    icon: item.$2,
                    selectedIcon: item.$3,
                    selected: _isMainNavSelected(item.$1),
                    onTap: () => _go(item.$1),
                  ),
                  if (item.$1 == '/shoot-log')
                    _PersonalShootLogsDrawerTile(
                      selected: widget.location == '/shoot-log/personal',
                      onTap: () => _go('/shoot-log/personal'),
                    ),
                ],
                const Divider(height: 1),
                const _DrawerSectionLabel('Community'),
                for (final item in _communityNavItems)
                  _DrawerNavTile(
                    label: item.$4,
                    icon: item.$2,
                    selectedIcon: item.$3,
                    selected: _isCommunityNavSelected(item.$1),
                    onTap: () => _go(item.$1),
                    badgeCount: item.$1 == '/notifications' ? badgeCount : null,
                  ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const ConnectivityBanner(),
            const MobileSyncInactiveBanner(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: Material(
          color: theme.colorScheme.surfaceContainer,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (var i = 0; i < _quickActions.length; i++)
                    Expanded(
                      child: _QuickActionDestination(
                        label: _quickActions[i].$4,
                        icon: _quickActions[i].$2,
                        selectedIcon: _quickActions[i].$3,
                        selected: activeQuickIndex == i,
                        onTap: () => context.go(_quickActions[i].$1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onTap,
  });

  final String? name;
  final String? email;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              UserAvatar(
                name: name,
                avatarUrl: avatarUrl,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'MarksmanMate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'View profile',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.badgeCount,
    this.dense = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    Widget leading = Icon(selected ? selectedIcon : icon, color: iconColor);
    if (badgeCount != null && badgeCount! > 0) {
      leading = Badge(
        isLabelVisible: true,
        label: Text('$badgeCount'),
        child: leading,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(12, dense ? 0 : 1, 12, dense ? 0 : 1),
      child: ListTile(
        dense: dense,
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: dense ? 20 : 12,
          vertical: dense ? 0 : 4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: selected,
        selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(120),
        leading: leading,
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? theme.colorScheme.primary : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PersonalShootLogsDrawerTile extends ConsumerWidget {
  const _PersonalShootLogsDrawerTile({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(structuredLogRemindersProvider).maybeWhen(
          data: (reminders) => reminders.length,
          orElse: () => 0,
        );

    return _DrawerNavTile(
      label: 'Personal reminders',
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      selected: selected,
      onTap: onTap,
      dense: true,
      badgeCount: count > 0 ? count : null,
    );
  }
}

class _QuickActionDestination extends StatelessWidget {
  const _QuickActionDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
