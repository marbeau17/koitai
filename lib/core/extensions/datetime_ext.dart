import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Utility extensions on [DateTime] for date formatting and
/// fortune-related calculations.
extension DateTimeExt on DateTime {
  // ── Formatting ─────────────────────────────────────────────

  /// "2026-02-22"
  String toIso8601Date() => DateFormat('yyyy-MM-dd').format(this);

  /// "2月22日"
  String toJaMonthDay() => DateFormat('M月d日', 'ja').format(this);

  /// "2月22日(日)"
  String toJaMonthDayWeekday() {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final wd = weekdays[weekday - 1];
    return '$month月$day日($wd)';
  }

  /// "2026年2月"
  String toJaYearMonth() => DateFormat('yyyy年M月', 'ja').format(this);

  // ── Comparison helpers ─────────────────────────────────────

  /// Returns true when year, month and day match [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Number of whole days from [birthDate] to this date.
  int daysSince(DateTime birthDate) {
    final a = DateTime.utc(year, month, day);
    final b = DateTime.utc(birthDate.year, birthDate.month, birthDate.day);
    return a.difference(b).inDays;
  }

  /// The date with time stripped (midnight UTC).
  DateTime get dateOnly => DateTime.utc(year, month, day);

  // ── Moon-age approximation ─────────────────────────────────

  /// Approximate moon age (synodic days 0-29.53) for a given date
  /// using a simplified version of Conway's method.
  /// For production accuracy, a proper astronomical library is used on
  /// the server side; this is a lightweight client-side approximation.
  double get approximateMoonAge {
    // Known new-moon reference: 2000-01-06 18:14 UTC (Julian 2451550.26)
    const knownNewMoonJd = 2451550.26;
    const synodicMonth = 29.53058867;
    final jd = _julianDay;
    final daysSinceNew = jd - knownNewMoonJd;
    final age = daysSinceNew % synodicMonth;
    return age < 0 ? age + synodicMonth : age;
  }

  /// Approximate illumination fraction 0.0 - 1.0
  double get approximateIllumination {
    final age = approximateMoonAge;
    // Simple cosine approximation
    return (1 - math.cos(2 * math.pi * age / 29.53058867)) / 2;
  }

  /// Julian Day Number for this date (noon UTC).
  double get _julianDay {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + (a ~/ 4);
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  // ── Age helper ─────────────────────────────────────────────

  /// Returns the person's age in full years as of this date
  /// given their [birthDate].
  int ageFrom(DateTime birthDate) {
    int age = year - birthDate.year;
    if (month < birthDate.month ||
        (month == birthDate.month && day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
