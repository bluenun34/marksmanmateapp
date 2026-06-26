import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'app_screen_app_bar.dart';
import '../../core/sync/sync_service.dart';
import 'app_sync_panel.dart';
import 'connectivity_banner.dart';

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
  static const _tabs = [
    ('/dashboard', Icons.home_outlined, Icons.home_rounded, 'Home'),
    ('/shoot-log', Icons.track_changes_outlined, Icons.track_changes, 'Log'),
    ('/tools', Icons.build_outlined, Icons.build_rounded, 'Tools'),
    ('/locker', Icons.lock_outline_rounded, Icons.lock_rounded, 'Locker'),
    ('/settings', Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex() {
    for (var i = 0; i < _tabs.length; i++) {
      if (widget.location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
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
                for (final tab in _tabs)
                  ListTile(
                    leading: Icon(tab.$3),
                    title: Text(tab.$4),
                    selected: widget.location.startsWith(tab.$1),
                    onTap: () => _go(tab.$1),
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flash_on_rounded),
                  title: const Text('Quick Log'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/shoot-log/quick');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('New Session'),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/shoot-log/new');
                  },
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex(),
          onDestinationSelected: (i) => context.go(_tabs[i].$1),
          destinations: _tabs
              .map(
                (t) => NavigationDestination(
                  icon: Icon(t.$2),
                  selectedIcon: Icon(t.$3),
                  label: t.$4,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
