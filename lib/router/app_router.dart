import 'package:go_router/go_router.dart';

import '../features/backup/backup_screen.dart';
import '../features/counters/archived_screen.dart';
import '../features/counters/counter_edit_screen.dart';
import '../features/counters/counters_screen.dart';
import '../features/history/history_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/tally/number_position_screen.dart';
import '../features/tally/western_tally_screen.dart';
import '../features/widgets_service/widget_config_screen.dart';
import 'launch_state.dart';
import 'spring_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: LaunchState.initialLocation,
  redirect: (context, state) {
    // One-time onboarding: fresh installs (no counters, flag unset) start there;
    // everyone else — and anyone returning — never sees it again.
    if (!LaunchState.onboardingDone && state.matchedLocation == '/') {
      return '/onboarding';
    }
    if (LaunchState.onboardingDone && state.matchedLocation == '/onboarding') {
      return '/';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => springPage(
        name: 'onboarding',
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/',
      name: 'counters',
      pageBuilder: (context, state) => springPage(
        name: 'counters',
        child: const CountersScreen(),
      ),
    ),
    GoRoute(
      path: '/archived',
      name: 'archived',
      pageBuilder: (context, state) => springPage(
        name: 'archived',
        child: const ArchivedScreen(),
      ),
    ),
    GoRoute(
      path: '/counter/new',
      name: 'counter_new',
      pageBuilder: (context, state) => springPage(
        name: 'counter_new',
        child: const CounterEditScreen(),
      ),
    ),
    GoRoute(
      path: '/counter/:id/edit',
      name: 'counter_edit',
      pageBuilder: (context, state) => springPage(
        name: 'counter_edit',
        child: CounterEditScreen(counterId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: '/counter/:id',
      name: 'counter',
      pageBuilder: (context, state) => springPage(
        name: 'counter',
        child: WesternTallyScreen(counterId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/counter/:id/number',
      name: 'counter_number',
      pageBuilder: (context, state) => springPage(
        name: 'counter_number',
        child: NumberPositionScreen(counterId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/stats',
      name: 'stats',
      pageBuilder: (context, state) => springPage(
        name: 'stats',
        child: const StatsScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      pageBuilder: (context, state) => springPage(
        name: 'history',
        child: const HistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => springPage(
        name: 'settings',
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/backup',
      name: 'backup',
      pageBuilder: (context, state) => springPage(
        name: 'backup',
        child: const BackupScreen(),
      ),
    ),
    GoRoute(
      path: '/widget-config',
      name: 'widget_config',
      pageBuilder: (context, state) => springPage(
        name: 'widget_config',
        child: WidgetConfigScreen(
          appWidgetId: int.tryParse(state.uri.queryParameters['id'] ?? '') ?? 0,
        ),
      ),
    ),
  ],
);
