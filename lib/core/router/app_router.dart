import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/pair/screens/pair_input_screen.dart';
import '../../features/pair/screens/pair_result_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/subscription/screens/paywall_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Named route paths.
abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String calendar = '/calendar';
  static const String pair = '/pair';
  static const String pairResult = '/pair/result';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String detail = '/detail/:date';

  /// Generates the detail path for a given [date] string ("2026-02-22").
  static String detailPath(String date) => '/detail/$date';
}

// Shell navigator key for the bottom-tab layout.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    // ── Onboarding (outside shell) ─────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Subscription modal (outside shell) ─────────────────
    GoRoute(
      path: AppRoutes.subscription,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => MaterialPage<void>(
        fullscreenDialog: true,
        child: const PaywallScreen(),
      ),
    ),

    // ── Detail page (outside shell) ────────────────────────
    GoRoute(
      path: AppRoutes.detail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final date = state.pathParameters['date'] ?? '';
        return DetailPlaceholderScreen(date: date);
      },
    ),

    // ── Pair result (outside shell) ────────────────────────
    GoRoute(
      path: AppRoutes.pairResult,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PairResultScreen(),
    ),

    // ── Main Shell with Bottom Navigation ──────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: AppRoutes.pair,
          builder: (context, state) => const PairInputScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

/// Temporary placeholder until the real detail screen is built.
class DetailPlaceholderScreen extends StatelessWidget {
  const DetailPlaceholderScreen({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$dateの占い結果')),
      body: Center(child: Text('占い結果詳細: $date')),
    );
  }
}
