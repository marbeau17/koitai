import 'dart:math';

/// Holds the three biorhythm values (-1.0 to +1.0 each).
class BiorhythmValues {
  final double physical;
  final double emotional;
  final double intellectual;

  const BiorhythmValues({
    required this.physical,
    required this.emotional,
    required this.intellectual,
  });
}

/// Information about critical day status.
class CriticalDayInfo {
  final bool isPhysicalCritical;
  final bool isEmotionalCritical;
  final bool isIntellectualCritical;

  /// True when the emotional cycle is at a critical point (most impactful for love).
  final bool isLoveCritical;

  /// True when any two cycles are critical simultaneously.
  final bool isDoubleCritical;

  /// True when all three cycles are critical simultaneously (very rare).
  final bool isTripleCritical;

  const CriticalDayInfo({
    required this.isPhysicalCritical,
    required this.isEmotionalCritical,
    required this.isIntellectualCritical,
    required this.isLoveCritical,
    required this.isDoubleCritical,
    required this.isTripleCritical,
  });
}

/// Biorhythm calculation service for love timing fortune.
///
/// Uses classical biorhythm theory with three sine-wave cycles:
/// physical (23 days), emotional (28 days), intellectual (33 days).
class BiorhythmService {
  static const int physicalCycle = 23;
  static const int emotionalCycle = 28;
  static const int intellectualCycle = 33;

  /// Love-focused weight distribution.
  static const double weightPhysical = 0.20;
  static const double weightEmotional = 0.55;
  static const double weightIntellectual = 0.25;

  /// Calculates days elapsed since birth.
  static int daysSinceBirth(DateTime birthDate, DateTime targetDate) {
    return targetDate.difference(birthDate).inDays;
  }

  /// Calculates the three biorhythm values (-1.0 to +1.0).
  static BiorhythmValues calculateBiorhythm(
    DateTime birthDate,
    DateTime targetDate,
  ) {
    final days = daysSinceBirth(birthDate, targetDate);
    return BiorhythmValues(
      physical: sin(2 * pi * days / physicalCycle),
      emotional: sin(2 * pi * days / emotionalCycle),
      intellectual: sin(2 * pi * days / intellectualCycle),
    );
  }

  /// Calculates the love-focused biorhythm score (0-100).
  ///
  /// Emotional rhythm is weighted at 55%, physical at 20%, intellectual at 25%.
  static int calculateLoveBiorhythmScore(
    DateTime birthDate,
    DateTime targetDate,
  ) {
    final bio = calculateBiorhythm(birthDate, targetDate);

    final composite = bio.physical * weightPhysical +
        bio.emotional * weightEmotional +
        bio.intellectual * weightIntellectual;

    final score = ((composite + 1.0) / 2.0 * 100).round();
    return score.clamp(0, 100);
  }

  /// Checks whether [targetDate] is a critical day for any biorhythm cycle.
  ///
  /// A critical day occurs when a cycle crosses zero (days since birth
  /// is a multiple of the cycle length).
  static CriticalDayInfo checkCriticalDay(
    DateTime birthDate,
    DateTime targetDate,
  ) {
    final days = daysSinceBirth(birthDate, targetDate);

    final pCritical = days % physicalCycle == 0;
    final eCritical = days % emotionalCycle == 0;
    final iCritical = days % intellectualCycle == 0;

    return CriticalDayInfo(
      isPhysicalCritical: pCritical,
      isEmotionalCritical: eCritical,
      isIntellectualCritical: iCritical,
      isLoveCritical: eCritical,
      isDoubleCritical: (pCritical && eCritical) ||
          (eCritical && iCritical) ||
          (pCritical && iCritical),
      isTripleCritical: pCritical && eCritical && iCritical,
    );
  }

  /// Applies score penalties for critical days.
  ///
  /// - Triple critical: -30
  /// - Double critical: -20
  /// - Love (emotional) critical: -15
  /// - Single physical or intellectual critical: -5
  static int applyCriticalDayPenalty(int score, CriticalDayInfo info) {
    if (info.isTripleCritical) return max(0, score - 30);
    if (info.isDoubleCritical) return max(0, score - 20);
    if (info.isLoveCritical) return max(0, score - 15);
    if (info.isPhysicalCritical || info.isIntellectualCritical) {
      return max(0, score - 5);
    }
    return score;
  }

  /// Returns a human-readable phase label for a biorhythm value.
  static String getBiorhythmPhase(double value) {
    if (value > 0.7) return '高潮期';
    if (value > 0.3) return '上昇期';
    if (value > -0.3) return '変動期';
    if (value > -0.7) return '下降期';
    return '低迷期';
  }
}
