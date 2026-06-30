import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/deep_links/deep_link_handler.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/notifications/notification_bootstrap.dart';
import 'core/widgets/home_widget_service.dart';
import 'core/sync/background_sync.dart';
import 'core/sync/sync_on_reconnect.dart';
import 'core/sync/sync_on_resume.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/shoot_log/providers/shoot_log_provider.dart';
import 'router.dart';
import 'shared/widgets/app_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initBackgroundSync();
  await LocalNotificationsService.instance.initialize();
  await HomeWidgetService.init();
  runApp(
    const ProviderScope(
      child: SyncOnResume(
        child: MarksmanMateApp(),
      ),
    ),
  );
}

class MarksmanMateApp extends ConsumerWidget {
  const MarksmanMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncOnReconnectProvider);
    final auth = ref.watch(authStateProvider);
    if (auth.canEnterApp) {
      ref.watch(shootLogProvider);
    }
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (auth.isInitializing) {
      return MaterialApp(
        title: 'MarksmanMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        builder: (context, child) =>
            AppSafeArea(child: child ?? const SizedBox.shrink()),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return DeepLinkListener(
      router: router,
      child: NotificationBootstrap(
        router: router,
        child: MaterialApp.router(
          title: 'MarksmanMate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          builder: (context, child) =>
              AppSafeArea(child: child ?? const SizedBox.shrink()),
          routerConfig: router,
        ),
      ),
    );
  }
}
