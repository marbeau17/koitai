import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Singleton service that wraps [FirebaseAnalytics] for event tracking.
///
/// All public methods are guarded with try-catch so analytics failures
/// never crash the app.
class AnalyticsService {
  // -- Singleton -----------------------------------------------------------
  AnalyticsService._internal();
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // -- Sign-in / Sign-up --------------------------------------------------

  /// Log a successful sign-in. [method] should be `'google'` or `'apple'`.
  Future<void> logSignIn(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('[AnalyticsService] logSignIn error: $e');
    }
  }

  /// Log a first-time sign-up. [method] should be `'google'` or `'apple'`.
  Future<void> logSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('[AnalyticsService] logSignUp error: $e');
    }
  }

  // -- Fortune -------------------------------------------------------------

  /// Log when the user views the daily fortune result.
  Future<void> logViewFortune(int score, int starRating) async {
    try {
      await _analytics.logEvent(
        name: 'view_fortune',
        parameters: {
          'score': score,
          'star_rating': starRating,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logViewFortune error: $e');
    }
  }

  // -- Calendar ------------------------------------------------------------

  /// Log when the user views a calendar month. [month] is `'2026-02'` etc.
  Future<void> logViewCalendar(String month) async {
    try {
      await _analytics.logEvent(
        name: 'view_calendar',
        parameters: {
          'month': month,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logViewCalendar error: $e');
    }
  }

  // -- Pair ----------------------------------------------------------------

  /// Log when the user views a pair compatibility result.
  Future<void> logViewPairResult(int score) async {
    try {
      await _analytics.logEvent(
        name: 'view_pair_result',
        parameters: {
          'score': score,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logViewPairResult error: $e');
    }
  }

  // -- Share ---------------------------------------------------------------

  /// Log a share action. [contentType] is e.g. `'fortune'` or `'pair_result'`.
  Future<void> logShare(String contentType) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: contentType,
        method: 'system_share',
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logShare error: $e');
    }
  }

  // -- Subscription --------------------------------------------------------

  /// Log a subscription purchase. [productId] is `'monthly'` or `'yearly'`.
  Future<void> logSubscribe(String productId) async {
    try {
      await _analytics.logEvent(
        name: 'subscribe',
        parameters: {
          'product_id': productId,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logSubscribe error: $e');
    }
  }

  /// Log when the user views the paywall screen.
  Future<void> logViewPaywall() async {
    try {
      await _analytics.logEvent(name: 'view_paywall');
    } catch (e) {
      debugPrint('[AnalyticsService] logViewPaywall error: $e');
    }
  }

  // -- Onboarding ----------------------------------------------------------

  /// Log when the user completes onboarding.
  Future<void> logCompleteOnboarding() async {
    try {
      await _analytics.logEvent(name: 'complete_onboarding');
    } catch (e) {
      debugPrint('[AnalyticsService] logCompleteOnboarding error: $e');
    }
  }

  // -- Notifications -------------------------------------------------------

  /// Log when the user toggles notification settings.
  Future<void> logSetNotification(bool enabled, String time) async {
    try {
      await _analytics.logEvent(
        name: 'set_notification',
        parameters: {
          'enabled': enabled.toString(),
          'time': time,
        },
      );
    } catch (e) {
      debugPrint('[AnalyticsService] logSetNotification error: $e');
    }
  }

  // -- User properties -----------------------------------------------------

  /// Set the authentication method as a user property.
  Future<void> setUserAuthMethod(String method) async {
    try {
      await _analytics.setUserProperty(
        name: 'auth_method',
        value: method,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] setUserAuthMethod error: $e');
    }
  }

  /// Set the user's birth year as a user property.
  Future<void> setUserBirthYear(int year) async {
    try {
      await _analytics.setUserProperty(
        name: 'birth_year',
        value: year.toString(),
      );
    } catch (e) {
      debugPrint('[AnalyticsService] setUserBirthYear error: $e');
    }
  }

  /// Set the user's gender as a user property.
  Future<void> setUserGender(String gender) async {
    try {
      await _analytics.setUserProperty(
        name: 'gender',
        value: gender,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] setUserGender error: $e');
    }
  }
}
