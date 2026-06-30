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
  static const _navItems = [
    ('/dashboard', Icons.home_outlined, Icons.home_rounded, 'Home'),
    ('/shoot-log', Icons.track_changes_outlined, Icons.track_changes, 'Shoot log'),
    ('/tools', Icons.build_outlined, Icons.build_rounded, 'Range tools'),
    ('/locker', Icons.lock_outline_rounded, Icons.lock_rounded, 'Locker'),
    ('/settings', Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
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

  bool _isNavSelected(String path) {
    if (_isQuickActionRoute()) return false;
    if (path == '/shoot-log') {
      return widget.location == '/shoot-log';
    }
    return widget.location.startsWith(path);
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
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'MarksmanMate',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (auth.user?.name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          auth.user!.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const AppSyncPanel(),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Navigate',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final item in _navItems)
                  ListTile(
                    leading: Icon(
                      _isNavSelected(item.$1) ? item.$3 : item.$2,
                    ),
                    title: Text(item.$4),
                    selected: _isNavSelected(item.$1),
                    onTap: () => _go(item.$1),
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Activity',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListTile(
                  leading: Badge(
                    isLabelVisible: badgeCount > 0,
                    label: Text('$badgeCount'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  title: const Text('Notifications'),
                  selected: widget.location.startsWith('/notifications'),
                  onTap: () => _go('/notifications'),
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Messages'),
                  selected: widget.location.startsWith('/messages'),
                  onTap: () => _go('/messages'),
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('My clubs'),
                  selected: widget.location.startsWith('/clubs'),
                  onTap: () => _go('/clubs'),
                ),
                ListTile(
                  leading: const Icon(Icons.group_work_outlined),
                  title: const Text('My groups'),
                  selected: widget.location.startsWith('/groups'),
                  onTap: () => _go('/groups'),
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Friends'),
                  selected: widget.location.startsWith('/friends'),
                  onTap: () => _go('/friends'),
                ),
                ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Events'),
                  selected: widget.location.startsWith('/events'),
                  onTap: () => _go('/events'),
                ),
                _PersonalShootLogsDrawerTile(
                  selected: widget.location == '/shoot-log/personal',
                  onTap: () => _go('/shoot-log/personal'),
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

    return ListTile(
      leading: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.assignment_outlined),
      ),
      title: const Text('Personal shoot logs'),
      selected: selected,
      onTap: onTap,
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
