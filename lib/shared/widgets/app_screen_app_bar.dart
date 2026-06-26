import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Consistent top app bars: hamburger on main tabs, back on pushed screens.
abstract class AppScreenAppBar {
  static void popOrGo(BuildContext context, {String fallbackRoute = '/dashboard'}) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  static AppBar back(
    BuildContext context, {
    required String title,
    String fallbackRoute = '/dashboard',
    List<Widget>? actions,
    IconData leadingIcon = Icons.arrow_back_rounded,
    String leadingLabel = 'Back',
  }) {
    return AppBar(
      primary: false,
      automaticallyImplyLeading: false,
      leadingWidth: 92,
      leading: TextButton.icon(
        onPressed: () => popOrGo(context, fallbackRoute: fallbackRoute),
        icon: Icon(leadingIcon, size: 20),
        label: Text(leadingLabel),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 4),
        ),
      ),
      title: Text(title),
      actions: actions,
    );
  }

  static AppBar main(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    VoidCallback? onMenuPressed,
  }) {
    return AppBar(
      primary: false,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        tooltip: 'Menu',
        onPressed: onMenuPressed ?? () => MainShellScope.openDrawer(context),
      ),
      title: Text(title),
      actions: actions,
    );
  }
}

/// Lets tab screens open the [MainShell] navigation drawer.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.onOpenDrawer,
    required super.child,
  });

  final VoidCallback onOpenDrawer;

  static MainShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>();
  }

  static void openDrawer(BuildContext context) {
    maybeOf(context)?.onOpenDrawer();
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}
