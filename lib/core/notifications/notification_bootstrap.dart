import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import 'local_notifications_service.dart';

class NotificationBootstrap extends ConsumerStatefulWidget {
  const NotificationBootstrap({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<NotificationBootstrap> createState() =>
      _NotificationBootstrapState();
}

class _NotificationBootstrapState extends ConsumerState<NotificationBootstrap> {
  @override
  void initState() {
    super.initState();
    LocalNotificationsService.instance.onPayload = _onNotificationTap;
    unawaited(LocalNotificationsService.instance.requestPermissions());
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapInbox());
  }

  void _bootstrapInbox() {
    final auth = ref.read(authStateProvider);
    if (!auth.canUseApp) return;
    ref.read(notificationPollerProvider).start();
    unawaited(ref.read(notificationSummaryProvider.notifier).refresh());
  }

  void _onNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    widget.router.go(payload);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.canUseApp && previous?.canUseApp != true) {
        ref.read(notificationPollerProvider).start();
        unawaited(ref.read(notificationSummaryProvider.notifier).refresh());
      }
    });

    return widget.child;
  }
}
