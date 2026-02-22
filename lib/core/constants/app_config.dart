/// Application-wide configuration constants.
abstract final class AppConfig {
  // ── General ──────────────────────────────────────────────
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.lovetiming.koitai';
  static const String firebaseProjectId = 'love-timing-fortune';
  static const String region = 'asia-northeast1';

  // ── Cache TTL (milliseconds) ─────────────────────────────
  static const int fortuneCacheTtlMs = 24 * 60 * 60 * 1000; // 24 hours
  static const int profileCacheTtlMs = 0; // never expires locally
  static const int calendarCacheTtlMs = 24 * 60 * 60 * 1000; // 24 hours
  static const int backgroundRefreshThresholdMs = 60 * 60 * 1000; // 1 hour

  // ── Hive Box Names ───────────────────────────────────────
  static const String hiveBoxFortune = 'fortune_cache';
  static const String hiveBoxProfile = 'user_profile';
  static const String hiveBoxPair = 'pair_readings';
  static const String hiveBoxSettings = 'app_settings';

  // ── Onboarding Defaults ──────────────────────────────────
  static const int defaultBirthYear = 2000;
  static const int defaultBirthMonth = 1;
  static const int defaultBirthDay = 1;
  static const int minimumAge = 13;

  // ── Subscription (RevenueCat) ────────────────────────────
  static const String revenueCatEntitlement = 'premium';
  static const String revenueCatOffering = 'default';
  static const String monthlyProductId = 'love_timing_premium_monthly';
  static const String yearlyProductId = 'love_timing_premium_yearly';
  static const int monthlyPriceYen = 680;
  static const int yearlyPriceYen = 5400;

  // ── Rate Limits ──────────────────────────────────────────
  static const int dailyFortuneMaxRequests = 30;
  static const int pairReadingFreeMaxPerMonth = 1;
  static const int pairReadingPremiumMaxPerMonth = 30;
  static const int monthlyCalendarMaxRequestsPerDay = 60;

  // ── Fortune Score Thresholds ─────────────────────────────
  static const int rankSThreshold = 85;
  static const int rankAThreshold = 70;
  static const int rankBThreshold = 50;
  static const int rankCThreshold = 30;

  // ── Notification ─────────────────────────────────────────
  static const String defaultNotificationTime = '08:00';
  static const int morningNotificationStartHour = 6;
  static const int morningNotificationEndHour = 9;

  // ── Biorhythm Cycles ─────────────────────────────────────
  static const int physicalCycleDays = 23;
  static const int emotionalCycleDays = 28;
  static const int intellectualCycleDays = 33;

  // ── Fortune Weights ──────────────────────────────────────
  static const double numerologyWeight = 0.35;
  static const double moonPhaseWeight = 0.30;
  static const double biorhythmWeight = 0.35;
}
