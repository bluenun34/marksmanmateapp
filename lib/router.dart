import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/pro_required_screen.dart';
import 'features/auth/widgets/app_lock_gate.dart';
import 'features/clubs/screens/club_detail_screen.dart';
import 'features/clubs/screens/club_league_screen.dart';
import 'features/clubs/screens/clubs_list_screen.dart';
import 'features/friends/screens/friends_list_screen.dart';
import 'features/groups/screens/create_group_event_screen.dart';
import 'features/groups/screens/create_group_screen.dart';
import 'features/groups/screens/group_detail_screen.dart';
import 'features/groups/screens/groups_list_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/locker/screens/locker_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/shoot_log/providers/shoot_log_provider.dart';
import 'features/shoot_log/screens/create_session_screen.dart';
import 'features/shoot_log/screens/edit_session_screen.dart';
import 'features/shoot_log/screens/quick_log_screen.dart';
import 'features/shoot_log/screens/session_detail_screen.dart';
import 'features/shoot_log/screens/shoot_log_list_screen.dart';
import 'features/events/screens/event_checkin_desk_screen.dart';
import 'features/events/screens/event_detail_screen.dart';
import 'features/events/screens/event_live_scores_screen.dart';
import 'features/events/screens/events_list_screen.dart';
import 'features/events/screens/shoot_live_screen.dart';
import 'features/notifications/screens/conversation_screen.dart';
import 'features/notifications/screens/messages_list_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/shoot_log/screens/personal_shoot_logs_screen.dart';
import 'features/shoot_log/screens/shoot_log_analytics_screen.dart';
import 'features/tools/screens/ballistics_calculator_screen.dart';
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

      final location = state.matchedLocation;
      final isLoginRoute = location == '/login';
      final isProRequiredRoute = location == '/pro-required';

      if (!authState.isAuthenticated) {
        return isLoginRoute ? null : '/login';
      }

      if (!authState.canEnterApp) {
        return isProRequiredRoute ? null : '/pro-required';
      }

      if (isLoginRoute || isProRequiredRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/pro-required',
        builder: (_, _) => const ProRequiredScreen(),
      ),
      GoRoute(
        path: '/shoot-log/analytics',
        builder: (_, _) => const ShootLogAnalyticsScreen(),
      ),
      GoRoute(
        path: '/shoot-log/personal',
        builder: (_, _) => const PersonalShootLogsScreen(),
      ),
      GoRoute(
        path: '/shoot-log/:id([0-9]+)/edit',
        builder: (_, state) => EditSessionScreen(
          localId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shoot-log/:id([0-9]+)',
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
        path: '/tools/rifle-level',
        builder: (_, _) => const RifleLevelScreen(),
      ),
      GoRoute(
        path: '/clubs',
        builder: (_, _) => const ClubsListScreen(),
      ),
      GoRoute(
        path: '/clubs/:slug',
        builder: (_, state) => ClubDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/clubs/:slug/leagues/:leagueId',
        builder: (_, state) => ClubLeagueScreen(
          clubSlug: state.pathParameters['slug']!,
          leagueId: int.parse(state.pathParameters['leagueId']!),
        ),
      ),
      GoRoute(
        path: '/friends',
        builder: (_, _) => const FriendsListScreen(),
      ),
      GoRoute(
        path: '/groups',
        builder: (_, _) => const GroupsListScreen(),
      ),
      GoRoute(
        path: '/groups/new',
        builder: (_, _) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/:id([0-9]+)',
        builder: (_, state) => GroupDetailScreen(
          groupId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/groups/:id([0-9]+)/events/new',
        builder: (_, state) => CreateGroupEventScreen(
          groupId: int.parse(state.pathParameters['id']!),
          groupName: state.uri.queryParameters['name'],
        ),
      ),
      GoRoute(
        path: '/events',
        builder: (_, _) => const EventsListScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (_, state) => EventDetailScreen(
          eventId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/events/:id/checkin-desk',
        builder: (_, state) => EventCheckinDeskScreen(
          eventId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/events/:id/live-scores',
        builder: (_, state) => EventLiveScoresScreen(
          eventId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shoots/:id/live',
        builder: (_, state) => ShootLiveScreen(
          shootId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/messages',
        builder: (_, _) => const MessagesListScreen(),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) => ConversationScreen(
          conversationId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/tools/calculators/:id',
        builder: (_, state) => BallisticsCalculatorScreen(
          calculatorId: state.pathParameters['id']!,
        ),
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
              final discipline = qp['discipline'];
              final location = qp['location'];
              return CreateSessionScreen(
                linkedEventId: eventId,
                initialGroupSize: groupSize,
                initialGroupSizeUnit: groupSizeUnit,
                initialHits: hits,
                initialTargetType: targetType,
                initialDiscipline: discipline,
                initialLocation: location,
              );
            },
          ),
          GoRoute(
            path: '/tools/shot-timer',
            builder: (_, _) => const ShotTimerScreen(),
          ),
          GoRoute(
            path: '/tools/round-counter',
            builder: (_, _) => const RoundCounterScreen(),
          ),
          GoRoute(
            path: '/tools/target-analyzer',
            builder: (_, _) => const TargetAnalyzerScreen(),
          ),
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
