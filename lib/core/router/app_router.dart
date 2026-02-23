import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/pair/screens/pair_input_screen.dart';
import '../../features/pair/screens/pair_result_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/subscription/screens/paywall_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Named route paths.
abstract final class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String calendar = '/calendar';
  static const String pair = '/pair';
  static const String pairResult = '/pair/result';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String subscription = '/subscription';
  static const String detail = '/detail/:date';

  /// Generates the detail path for a given [date] string ("2026-02-22").
  static String detailPath(String date) => '/detail/$date';

  /// Routes that unauthenticated users are allowed to visit.
  static const Set<String> publicPaths = {login, onboarding};
}

// Shell navigator key for the bottom-tab layout.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Riverpod provider that exposes a [GoRouter] with auth-aware redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, routerState) {
      // While the auth state is still initializing, don't redirect at all so
      // the router waits until we know whether the user is signed in.
      if (authState.isInitializing) return null;

      final isAuthenticated = authState.isAuthenticated;
      final currentPath = routerState.matchedLocation;
      final isOnPublicPage = AppRoutes.publicPaths.contains(currentPath);

      // Not authenticated and trying to reach a protected page -> login
      if (!isAuthenticated && !isOnPublicPage) {
        return AppRoutes.login;
      }

      // Authenticated and sitting on the login page -> go home
      if (isAuthenticated && currentPath == AppRoutes.login) {
        return AppRoutes.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ── Login (outside shell) ────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

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

      // ── Settings (outside shell) ────────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
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
});

/// A [ChangeNotifier] that fires whenever the auth state changes so that
/// [GoRouter.refreshListenable] triggers a re-evaluation of redirects.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _sub = _ref.listen<AuthState>(authProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

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
