import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Top-level function for handling background FCM messages.
///
/// Must be a top-level function (not a class method) so the Flutter engine
/// can call it in a separate isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[NotificationService] Background message: ${message.messageId}');
}

/// Singleton service that manages push notifications (FCM) and local
/// scheduled notifications via flutter_local_notifications.
///
/// Usage:
/// ```dart
/// await NotificationService().init();
/// ```
class NotificationService {
  // ── Singleton ────────────────────────────────────────────
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  // ── Instance members ─────────────────────────────────────
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialised = false;

  // ── Channel constants ────────────────────────────────────
  static const String _channelId = 'koitai_daily_fortune';
  static const String _channelName = '毎日の恋愛運';
  static const String _channelDescription = '毎朝の恋愛運勢通知';

  // ── Public API ───────────────────────────────────────────

  /// Initialise the notification service.
  ///
  /// * Configures flutter_local_notifications for Android and iOS.
  /// * Requests notification permissions on iOS.
  /// * Retrieves the FCM token.
  /// * Sets up foreground and background message listeners.
  ///
  /// This is a no-op when running on Web.
  Future<void> init() async {
    if (kIsWeb || _initialised) return;

    // ── Timezone database (required by zonedSchedule) ────
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback to Asia/Tokyo since the app targets Japanese users.
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    }

    // ── Platform-specific init settings ──────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // ── Create Android notification channel ──────────────
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
    }

    // ── iOS permission request ───────────────────────────
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── FCM token ────────────────────────────────────────
    final token = await _messaging.getToken();
    debugPrint('[NotificationService] FCM Token: $token');

    // ── Foreground messages ──────────────────────────────
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ── Background messages ──────────────────────────────
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _initialised = true;
  }

  /// Show a local notification for the daily fortune result.
  Future<void> showDailyFortuneNotification({
    required int score,
    required String advice,
  }) async {
    if (kIsWeb) return;

    final String title = '\u4eca\u65e5\u306e\u604b\u611b\u904b: $score\u70b9';
    final String body = advice;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      0, // notification id
      title,
      body,
      details,
    );
  }

  /// Schedule a daily repeating notification at the given [hour] and [minute].
  ///
  /// Uses `zonedSchedule` with `matchDateTimeComponents` set to
  /// [DateTimeComponents.time] so it repeats every day.
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;

    // Cancel previous scheduled notification before setting a new one.
    await _localNotifications.cancel(1);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.zonedSchedule(
      1, // notification id for daily schedule
      '\u30b3\u30a4\u30bf\u30a4',
      '\u4eca\u65e5\u306e\u604b\u611b\u904b\u3092\u30c1\u30a7\u30c3\u30af\u3057\u307e\u3057\u3087\u3046\uff01',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
        '[NotificationService] Daily notification scheduled at $hour:$minute');
  }

  /// Cancel all pending notifications (both local and scheduled).
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _localNotifications.cancelAll();
    debugPrint('[NotificationService] All notifications cancelled');
  }

  /// Retrieve the current FCM registration token.
  ///
  /// Returns `null` on Web or if the token is unavailable.
  Future<String?> getFcmToken() async {
    if (kIsWeb) return null;
    return _messaging.getToken();
  }

  // ── Private helpers ──────────────────────────────────────

  /// Handle FCM messages received while the app is in the foreground.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
        '[NotificationService] Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  /// Called when the user taps on a notification.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        '[NotificationService] Notification tapped: ${response.payload}');
    // Navigation can be handled here via a global navigator key if needed.
  }
}
