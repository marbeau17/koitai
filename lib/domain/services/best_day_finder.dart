import 'package:koitai/domain/services/biorhythm_service.dart';
import 'package:koitai/domain/services/love_timing_service.dart';
import 'package:koitai/domain/services/moon_phase_service.dart';

/// A single day result from a best-day search.
class DayResult {
  final DateTime date;
  final int score;
  final MoonPhase moonPhase;
  final int starRating;

  const DayResult({
    required this.date,
    required this.score,
    required this.moonPhase,
    required this.starRating,
  });
}

/// Finds the best days for specific love actions within a date range.
///
/// Search range is capped at 90 days for performance.
class BestDayFinder {
  /// Maximum search range in days.
  static const int maxSearchDays = 90;

  /// Finds the best days for a given [action] within [startDate] to [endDate].
  ///
  /// Returns up to 5 results sorted by score descending.
  static List<DayResult> findBestDays(
    DateTime birthDate,
    DateTime startDate,
    DateTime endDate,
    LoveAction action,
  ) {
    final effectiveEnd = _capEndDate(startDate, endDate);
    final candidates = <DayResult>[];

    for (var date = startDate;
        !date.isAfter(effectiveEnd);
        date = date.add(const Duration(days: 1))) {
      final totalScore =
          LoveTimingService.calculateTotalLoveScore(birthDate, date);
      final moonAge = MoonPhaseService.calculateMoonAge(date);
      final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
      final biorhythm =
          BiorhythmService.calculateBiorhythm(birthDate, date);
      final recommendedActions = LoveTimingService.getRecommendedActions(
          totalScore, moonFraction, biorhythm);

      if (recommendedActions.contains(action)) {
        final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
        candidates.add(DayResult(
          date: date,
          score: totalScore,
          moonPhase: moonPhase,
          starRating: LoveTimingService.getStarRating(totalScore),
        ));
      }
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.take(5).toList();
  }

  /// Finds the best confession days within a date range.
  ///
  /// Confession requires: score >= 80, near full moon (fraction distance < 0.1),
  /// emotional biorhythm > 0.3, and no love critical day.
  static List<DayResult> findBestConfessionDays(
    DateTime birthDate,
    DateTime startDate,
    DateTime endDate, {
    DateTime? partnerBirthDate,
  }) {
    final effectiveEnd = _capEndDate(startDate, endDate);
    final results = <DayResult>[];

    for (var date = startDate;
        !date.isAfter(effectiveEnd);
        date = date.add(const Duration(days: 1))) {
      final score = partnerBirthDate != null
          ? LoveTimingService.calculatePairTimingScore(
              birthDate, partnerBirthDate, date)
          : LoveTimingService.calculateTotalLoveScore(birthDate, date);

      final moonAge = MoonPhaseService.calculateMoonAge(date);
      final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
      final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
      final bio = BiorhythmService.calculateBiorhythm(birthDate, date);
      final critical = BiorhythmService.checkCriticalDay(birthDate, date);

      // Confession criteria
      final distanceFromFull = (moonFraction - 0.5).abs();
      final isIdeal = score >= 80 &&
          distanceFromFull < 0.1 &&
          bio.emotional > 0.3 &&
          !critical.isLoveCritical;

      if (isIdeal) {
        results.add(DayResult(
          date: date,
          score: score,
          moonPhase: moonPhase,
          starRating: LoveTimingService.getStarRating(score),
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(5).toList();
  }

  /// Finds the best date days within a date range.
  ///
  /// Date requires: score >= 60, moon phase not last quarter or waning crescent,
  /// and not both partners having love critical days.
  static List<DayResult> findBestDateDays(
    DateTime birthDate,
    DateTime startDate,
    DateTime endDate, {
    DateTime? partnerBirthDate,
  }) {
    final effectiveEnd = _capEndDate(startDate, endDate);
    final results = <DayResult>[];

    for (var date = startDate;
        !date.isAfter(effectiveEnd);
        date = date.add(const Duration(days: 1))) {
      final score = partnerBirthDate != null
          ? LoveTimingService.calculatePairTimingScore(
              birthDate, partnerBirthDate, date)
          : LoveTimingService.calculateTotalLoveScore(birthDate, date);

      final moonAge = MoonPhaseService.calculateMoonAge(date);
      final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
      final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);

      // Date criteria
      final criticalA = BiorhythmService.checkCriticalDay(birthDate, date);
      final criticalB = partnerBirthDate != null
          ? BiorhythmService.checkCriticalDay(partnerBirthDate, date)
          : null;

      final moonOk = moonPhase != MoonPhase.waningCrescent &&
          moonPhase != MoonPhase.lastQuarter;
      final noCriticalBoth = criticalB == null ||
          !(criticalA.isLoveCritical && criticalB.isLoveCritical);

      final isIdeal = score >= 60 && moonOk && noCriticalBoth;

      if (isIdeal) {
        results.add(DayResult(
          date: date,
          score: score,
          moonPhase: moonPhase,
          starRating: LoveTimingService.getStarRating(score),
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(5).toList();
  }

  /// Caps the end date to [maxSearchDays] from [startDate].
  static DateTime _capEndDate(DateTime startDate, DateTime endDate) {
    final maxEnd = startDate.add(const Duration(days: maxSearchDays));
    return endDate.isAfter(maxEnd) ? maxEnd : endDate;
  }
}
