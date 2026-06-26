import 'package:flutter/material.dart';

/// Keeps app content below the OS status bar (time, battery, signal).
///
/// Used once at the root so individual screens do not each fight edge-to-edge
/// insets. Pair with [AppBar.primary] set to false on screen app bars.
class AppSafeArea extends StatelessWidget {
  const AppSafeArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      left: false,
      right: false,
      child: child,
    );
  }
}
