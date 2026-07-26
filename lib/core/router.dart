import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/about_screen.dart';
import '../screens/almanac_screen.dart';
import '../screens/clock_screen.dart';
import '../screens/help_screen.dart';
import '../screens/help_topic_screen.dart';
import '../screens/home_shell.dart';
import '../screens/hora_screen.dart';
import '../screens/location_settings_screen.dart';
import '../screens/muhurta_screen.dart';
import '../screens/panchang_screen.dart';
import '../screens/permissions_screen.dart';
import '../screens/settings_screen.dart';

/// The app's navigation table (architecture §13).
///
/// The five main tabs — `/` (the clock), `/muhurta` (Muhurta & Kalas),
/// `/hora` (planetary hours), `/panchang`, and `/almanac` (the yearly
/// view) — live inside a [StatefulShellRoute], so a bottom [NavigationBar]
/// switches between them while each keeps its own state.
/// `/settings` and `/about` sit outside the shell and open full-screen (no tab
/// bar). No auth, no deep links.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _clockNavigatorKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const ClockScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _muhurtaNavigatorKey,
          routes: [
            GoRoute(
              path: '/muhurta',
              builder: (context, state) => const MuhurtaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _horaNavigatorKey,
          routes: [
            GoRoute(
              path: '/hora',
              builder: (context, state) => const HoraScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _panchangNavigatorKey,
          routes: [
            GoRoute(
              path: '/panchang',
              builder: (context, state) => const PanchangScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _almanacNavigatorKey,
          routes: [
            GoRoute(
              path: '/almanac',
              builder: (context, state) => const AlmanacScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/location',
      builder: (context, state) => const LocationSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/permissions',
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/settings/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/settings/help/:index',
      builder: (context, state) => HelpTopicScreen(
        index: int.tryParse(state.pathParameters['index'] ?? '') ?? 0,
      ),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);

final GlobalKey<NavigatorState> _clockNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'clock',
);
final GlobalKey<NavigatorState> _muhurtaNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'muhurta');
final GlobalKey<NavigatorState> _horaNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'hora',
);
final GlobalKey<NavigatorState> _panchangNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'panchang');
final GlobalKey<NavigatorState> _almanacNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'almanac');
