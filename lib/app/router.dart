import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/insights/recap_screens.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/you/appearance_screen.dart';
import '../features/you/debug_screen.dart';
import '../features/you/goal_screen.dart';
import '../features/you/health_screen.dart';
import '../features/you/notifications_screen.dart';
import '../features/you/paywall_screen.dart';
import '../features/you/privacy_screen.dart';
import '../features/you/routines_screen.dart';
import '../features/you/schedule_screen.dart';
import '../features/you/support_screen.dart';
import '../features/you/vessels_screen.dart';
import '../features/you/you_screen.dart';
import '../l10n/gen/app_localizations.dart';
import 'providers.dart';
import 'shell.dart';

/// Whether onboarding had been completed when the app started. Overridden in
/// `main()` from local storage so the first route is correct on frame one.
final initialOnboardedProvider = Provider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(profileProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final startOnboarded = ref.read(initialOnboardedProvider);
  final root = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: root,
    initialLocation: startOnboarded ? '/home' : '/onboarding',
    refreshListenable: refresh,
    redirect: (context, state) {
      final profile = ref.read(profileProvider).value;
      if (profile == null) return null; // still loading or being recreated
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (!profile.onboardingComplete && !onOnboarding) return '/onboarding';
      if (profile.onboardingComplete && onOnboarding) return '/home';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(AppLocalizations.of(context).routeNotFound)),
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/home'),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/pro',
        parentNavigatorKey: root,
        builder: (_, _) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/recap/weekly',
        parentNavigatorKey: root,
        builder: (_, _) => const WeeklyRecapScreen(),
      ),
      GoRoute(
        path: '/recap/monthly',
        parentNavigatorKey: root,
        builder: (_, _) => const MonthlyRecapScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HydraShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (_, _) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/insights',
                builder: (_, _) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/you',
                builder: (_, _) => const YouScreen(),
                routes: [
                  GoRoute(path: 'goal', builder: (_, _) => const GoalScreen()),
                  GoRoute(
                    path: 'schedule',
                    builder: (_, _) => const ScheduleScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (_, _) => const NotificationsScreen(),
                    routes: [
                      GoRoute(
                        path: 'help',
                        builder: (_, _) => const NotificationHelpScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'vessels',
                    builder: (_, _) => const VesselsScreen(),
                  ),
                  GoRoute(
                    path: 'routines',
                    builder: (_, _) => const RoutinesScreen(),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, s) => RoutineEditScreen(
                          routineId: s.uri.queryParameters['id'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'health',
                    builder: (_, _) => const HealthScreen(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (_, _) => const PrivacyScreen(),
                  ),
                  GoRoute(
                    path: 'appearance',
                    builder: (_, _) => const AppearanceScreen(),
                  ),
                  GoRoute(
                    path: 'support',
                    builder: (_, _) => const SupportScreen(),
                  ),
                  GoRoute(
                    path: 'debug',
                    builder: (_, _) => const DebugScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
