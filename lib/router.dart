import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/widgets/app_lock_gate.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/locker/screens/locker_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/shoot_log/providers/shoot_log_provider.dart';
import 'features/shoot_log/screens/create_session_screen.dart';
import 'features/shoot_log/screens/edit_session_screen.dart';
import 'features/shoot_log/screens/quick_log_screen.dart';
import 'features/shoot_log/screens/session_detail_screen.dart';
import 'features/shoot_log/screens/shoot_log_list_screen.dart';
import 'features/tools/screens/rifle_level_screen.dart';
import 'features/tools/screens/round_counter_screen.dart';
import 'features/tools/screens/shot_timer_screen.dart';
import 'features/tools/screens/target_analyzer_screen.dart';
import 'features/tools/screens/tools_screen.dart';
import 'shared/widgets/main_shell.dart';

final _routerRefreshNotifier = ValueNotifier<int>(0);

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen(authStateProvider, (_, __) {
    _routerRefreshNotifier.value++;
  });

  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: _routerRefreshNotifier,
    redirect: (context, state) {
      if (authState.isInitializing) return null;

      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/shoot-log/quick',
        builder: (_, state) {
          final eventId =
              int.tryParse(state.uri.queryParameters['event_id'] ?? '');
          final rounds =
              int.tryParse(state.uri.queryParameters['rounds'] ?? '');
          final hits = int.tryParse(state.uri.queryParameters['hits'] ?? '');
          return QuickLogScreen(
            eventId: eventId,
            initialRounds: rounds,
            initialHits: hits,
          );
        },
      ),
      GoRoute(
        path: '/shoot-log/new',
        builder: (_, state) {
          final qp = state.uri.queryParameters;
          final eventId = int.tryParse(qp['event_id'] ?? '');
          final groupSize = double.tryParse(qp['group_size'] ?? '');
          final groupSizeUnit = qp['group_size_unit'];
          final hits = int.tryParse(qp['hits'] ?? '');
          final targetType = qp['target_type'];
          return CreateSessionScreen(
            linkedEventId: eventId,
            initialGroupSize: groupSize,
            initialGroupSizeUnit: groupSizeUnit,
            initialHits: hits,
            initialTargetType: targetType,
          );
        },
      ),
      GoRoute(
        path: '/shoot-log/:id/edit',
        builder: (_, state) => EditSessionScreen(
          localId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shoot-log/:id',
        builder: (_, state) {
          final sourceParam = state.uri.queryParameters['source'];
          final source = sourceParam == 'local'
              ? SessionDetailSource.local
              : SessionDetailSource.remote;
          return SessionDetailScreen(
            sessionId: int.parse(state.pathParameters['id']!),
            source: source,
          );
        },
      ),
      GoRoute(
        path: '/tools/shot-timer',
        builder: (_, _) => const ShotTimerScreen(),
      ),
      GoRoute(
        path: '/tools/rifle-level',
        builder: (_, _) => const RifleLevelScreen(),
      ),
      GoRoute(
        path: '/tools/round-counter',
        builder: (_, _) => const RoundCounterScreen(),
      ),
      GoRoute(
        path: '/tools/target-analyzer',
        builder: (_, _) => const TargetAnalyzerScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) => AppLockGate(
          child: MainShell(
            location: state.matchedLocation,
            child: child,
          ),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/shoot-log',
            builder: (_, _) => const ShootLogListScreen(),
          ),
          GoRoute(
            path: '/tools',
            builder: (_, _) => const ToolsScreen(),
          ),
          GoRoute(
            path: '/locker',
            builder: (_, _) => const LockerScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
