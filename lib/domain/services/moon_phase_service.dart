import 'dart:math';

/// Represents the 8 phases of the lunar cycle.
enum MoonPhase {
  newMoon, // 新月
  waxingCrescent, // 三日月
  firstQuarter, // 上弦の月
  waxingGibbous, // 十三夜月
  fullMoon, // 満月
  waningGibbous, // 十八夜月
  lastQuarter, // 下弦の月
  waningCrescent, // 二十六夜月
}

/// Moon phase calculation service for love timing fortune.
///
/// Uses a fixed synodic period of ~29.53 days with a reference new moon
/// of January 6, 2000 18:14 UTC.
class MoonPhaseService {
  /// Synodic lunar cycle in days.
  static const double lunarCycle = 29.53058770576;

  /// Reference new moon: January 6, 2000 18:14 UTC.
  static final DateTime referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14, 0);

  /// Calculates the moon age (days since last new moon) for [targetDate].
  ///
  /// Returns a value between 0.0 and ~29.53.
  static double calculateMoonAge(DateTime targetDate) {
    final utcTarget = targetDate.toUtc();
    final elapsed = utcTarget.difference(referenceNewMoon);
    final elapsedDays = elapsed.inMilliseconds / (1000.0 * 60 * 60 * 24);

    double moonAge = elapsedDays % lunarCycle;
    if (moonAge < 0) moonAge += lunarCycle;
    return moonAge;
  }

  /// Converts moon age to a fraction of the lunar cycle (0.0 - 1.0).
  static double calculateMoonFraction(double moonAge) {
    return moonAge / lunarCycle;
  }

  /// Determines the moon phase from a cycle fraction (0.0 - 1.0).
  static MoonPhase getMoonPhase(double fraction) {
    if (fraction < 0.034 || fraction >= 0.966) return MoonPhase.newMoon;
    if (fraction < 0.216) return MoonPhase.waxingCrescent;
    if (fraction < 0.284) return MoonPhase.firstQuarter;
    if (fraction < 0.466) return MoonPhase.waxingGibbous;
    if (fraction < 0.534) return MoonPhase.fullMoon;
    if (fraction < 0.716) return MoonPhase.waningGibbous;
    if (fraction < 0.784) return MoonPhase.lastQuarter;
    return MoonPhase.waningCrescent;
  }

  /// Returns the Japanese name for a moon phase.
  static String getMoonPhaseName(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return '新月';
      case MoonPhase.waxingCrescent:
        return '三日月';
      case MoonPhase.firstQuarter:
        return '上弦の月';
      case MoonPhase.waxingGibbous:
        return '十三夜月';
      case MoonPhase.fullMoon:
        return '満月';
      case MoonPhase.waningGibbous:
        return '十八夜月';
      case MoonPhase.lastQuarter:
        return '下弦の月';
      case MoonPhase.waningCrescent:
        return '二十六夜月';
    }
  }

  /// Calculates the moon-based love score (0-100) from [moonFraction].
  ///
  /// Uses a cosine-based function with a peak at the full moon (0.5)
  /// and a sub-peak at the new moon (0.0/1.0).
  static int calculateMoonLoveScore(double moonFraction) {
    // Main score: full moon peak
    final mainScore = 50 + 45 * cos(2 * pi * (moonFraction - 0.5));
    // Sub score: new moon peak
    final subScore = 15 * cos(2 * pi * moonFraction);
    // First quarter bonus
    double quarterBonus = 0;
    if (moonFraction >= 0.2 && moonFraction <= 0.3) {
      quarterBonus = 10;
    }

    final rawScore = mainScore + subScore + quarterBonus;
    return rawScore.round().clamp(0, 100);
  }

  /// Applies a full moon bonus: guarantees a minimum score of 85
  /// when the moon is within ~3 days of full (fraction distance < 0.1).
  static int applyFullMoonBonus(int score, double moonFraction) {
    final distanceFromFull = (moonFraction - 0.5).abs();
    if (distanceFromFull < 0.1) {
      return max(score, 85);
    }
    return score;
  }
}
