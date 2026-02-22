import 'biorhythm_service.dart';
import 'moon_phase_service.dart';
import 'numerology_service.dart';

/// Love actions that can be recommended based on timing.
enum LoveAction {
  confession, // 告白
  proposal, // プロポーズ
  askForDate, // デート誘い
  sendMessage, // メッセージ送信
  exchangeContact, // 連絡先交換
  reviewRelation, // 関係見直し
  selfImprovement, // 自分磨き
}

/// Comprehensive love timing calculation service.
///
/// Integrates numerology (40%), moon phase (30%), and biorhythm (30%)
/// to produce a total love score and actionable recommendations.
class LoveTimingService {
  static const double weightNumerology = 0.40;
  static const double weightMoon = 0.30;
  static const double weightBiorhythm = 0.30;

  /// Numerology compatibility table (life path number pairs -> score 0-100).
  static const Map<int, Map<int, int>> _compatibilityTable = {
    1: {
      1: 65, 2: 55, 3: 85, 4: 50, 5: 90, 6: 60,
      7: 80, 8: 55, 9: 70, 11: 60, 22: 55, 33: 65,
    },
    2: {
      1: 55, 2: 70, 3: 65, 4: 80, 5: 45, 6: 95,
      7: 60, 8: 85, 9: 75, 11: 90, 22: 80, 33: 90,
    },
    3: {
      1: 85, 2: 65, 3: 75, 4: 40, 5: 90, 6: 85,
      7: 55, 8: 50, 9: 80, 11: 70, 22: 45, 33: 80,
    },
    4: {
      1: 50, 2: 80, 3: 40, 4: 65, 5: 35, 6: 75,
      7: 70, 8: 85, 9: 55, 11: 60, 22: 95, 33: 70,
    },
    5: {
      1: 90, 2: 45, 3: 90, 4: 35, 5: 70, 6: 50,
      7: 85, 8: 55, 9: 80, 11: 55, 22: 40, 33: 60,
    },
    6: {
      1: 60, 2: 95, 3: 85, 4: 75, 5: 50, 6: 80,
      7: 45, 8: 65, 9: 90, 11: 85, 22: 75, 33: 95,
    },
    7: {
      1: 80, 2: 60, 3: 55, 4: 70, 5: 85, 6: 45,
      7: 75, 8: 50, 9: 65, 11: 85, 22: 65, 33: 55,
    },
    8: {
      1: 55, 2: 85, 3: 50, 4: 85, 5: 55, 6: 65,
      7: 50, 8: 70, 9: 60, 11: 65, 22: 90, 33: 70,
    },
    9: {
      1: 70, 2: 75, 3: 80, 4: 55, 5: 80, 6: 90,
      7: 65, 8: 60, 9: 55, 11: 80, 22: 60, 33: 85,
    },
    11: {
      1: 60, 2: 90, 3: 70, 4: 60, 5: 55, 6: 85,
      7: 85, 8: 65, 9: 80, 11: 75, 22: 70, 33: 90,
    },
    22: {
      1: 55, 2: 80, 3: 45, 4: 95, 5: 40, 6: 75,
      7: 65, 8: 90, 9: 60, 11: 70, 22: 75, 33: 80,
    },
    33: {
      1: 65, 2: 90, 3: 80, 4: 70, 5: 60, 6: 95,
      7: 55, 8: 70, 9: 85, 11: 90, 22: 80, 33: 85,
    },
  };

  /// Calculates the total love score (0-100) for [birthDate] on [targetDate].
  ///
  /// Integrates numerology (40%), moon phase (30%), and biorhythm (30%).
  static int calculateTotalLoveScore(
    DateTime birthDate,
    DateTime targetDate,
  ) {
    // 1. Numerology score
    final numerologyScore =
        NumerologyService.calculateNumerologyLoveScore(birthDate, targetDate);

    // 2. Moon score
    final moonAge = MoonPhaseService.calculateMoonAge(targetDate);
    final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
    int moonScore = MoonPhaseService.calculateMoonLoveScore(moonFraction);
    moonScore = MoonPhaseService.applyFullMoonBonus(moonScore, moonFraction);

    // 3. Biorhythm score
    int bioScore =
        BiorhythmService.calculateLoveBiorhythmScore(birthDate, targetDate);
    final criticalInfo =
        BiorhythmService.checkCriticalDay(birthDate, targetDate);
    bioScore = BiorhythmService.applyCriticalDayPenalty(bioScore, criticalInfo);

    // 4. Weighted total
    double totalScore = numerologyScore * weightNumerology +
        moonScore * weightMoon +
        bioScore * weightBiorhythm;

    // 5. Special adjustments
    final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
    if (moonPhase == MoonPhase.fullMoon && !criticalInfo.isLoveCritical) {
      totalScore += 5;
    }
    if (criticalInfo.isTripleCritical) {
      totalScore -= 10;
    }

    return totalScore.round().clamp(0, 100);
  }

  /// Returns the star rating (1-5) for a given [score].
  static int getStarRating(int score) {
    if (score >= 85) return 5;
    if (score >= 70) return 4;
    if (score >= 50) return 3;
    if (score >= 30) return 2;
    return 1;
  }

  /// Calculates the pair timing score (0-100) for two people.
  ///
  /// Combines individual scores (60%), compatibility (25%),
  /// and biorhythm synchronization (15%).
  static int calculatePairTimingScore(
    DateTime birthDateA,
    DateTime birthDateB,
    DateTime targetDate,
  ) {
    final scoreA = calculateTotalLoveScore(birthDateA, targetDate);
    final scoreB = calculateTotalLoveScore(birthDateB, targetDate);
    final averageScore = (scoreA + scoreB) / 2;

    final lifePathA = NumerologyService.calculateLifePathNumber(birthDateA);
    final lifePathB = NumerologyService.calculateLifePathNumber(birthDateB);
    final compatibilityBonus = getCompatibilityScore(lifePathA, lifePathB);

    final syncBonus =
        calculateBiorhythmSync(birthDateA, birthDateB, targetDate);

    final pairScore = averageScore * 0.60 +
        compatibilityBonus * 0.25 +
        syncBonus * 0.15;

    return pairScore.round().clamp(0, 100);
  }

  /// Returns the compatibility score (0-100) for two life path numbers.
  static int getCompatibilityScore(int lifePathA, int lifePathB) {
    return _compatibilityTable[lifePathA]?[lifePathB] ?? 50;
  }

  /// Calculates biorhythm synchronization rate (0-100) between two people.
  ///
  /// Emotional sync is weighted at 50%, physical and intellectual at 25% each.
  static double calculateBiorhythmSync(
    DateTime birthDateA,
    DateTime birthDateB,
    DateTime targetDate,
  ) {
    final bioA =
        BiorhythmService.calculateBiorhythm(birthDateA, targetDate);
    final bioB =
        BiorhythmService.calculateBiorhythm(birthDateB, targetDate);

    final emotionalSync =
        1.0 - (bioA.emotional - bioB.emotional).abs() / 2.0;
    final physicalSync =
        1.0 - (bioA.physical - bioB.physical).abs() / 2.0;
    final intellectualSync =
        1.0 - (bioA.intellectual - bioB.intellectual).abs() / 2.0;

    final syncRate = emotionalSync * 0.50 +
        physicalSync * 0.25 +
        intellectualSync * 0.25;

    return (syncRate * 100).clamp(0.0, 100.0);
  }

  /// Returns a list of recommended love actions based on current conditions.
  static List<LoveAction> getRecommendedActions(
    int totalScore,
    double moonFraction,
    BiorhythmValues biorhythm,
  ) {
    final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
    final actions = <LoveAction>[];

    // Confession: score >= 80, within ~3 days of full moon, high emotional
    final distanceFromFull = (moonFraction - 0.5).abs();
    if (totalScore >= 80 &&
        distanceFromFull < 0.1 &&
        biorhythm.emotional > 0.3) {
      actions.add(LoveAction.confession);
    }

    // Proposal: score >= 90, full moon, all biorhythms positive
    if (totalScore >= 90 &&
        moonPhase == MoonPhase.fullMoon &&
        biorhythm.physical > 0 &&
        biorhythm.emotional > 0 &&
        biorhythm.intellectual > 0) {
      actions.add(LoveAction.proposal);
    }

    // Ask for date: score >= 60, not last quarter or waning crescent
    if (totalScore >= 60 &&
        moonPhase != MoonPhase.lastQuarter &&
        moonPhase != MoonPhase.waningCrescent) {
      actions.add(LoveAction.askForDate);
    }

    // Send message: score >= 40
    if (totalScore >= 40) {
      actions.add(LoveAction.sendMessage);
    }

    // Exchange contact: score >= 55, first quarter or waxing crescent
    if (totalScore >= 55 &&
        (moonPhase == MoonPhase.firstQuarter ||
            moonPhase == MoonPhase.waxingCrescent)) {
      actions.add(LoveAction.exchangeContact);
    }

    // Review relation: last quarter or waning crescent with negative emotion
    if (moonPhase == MoonPhase.lastQuarter ||
        moonPhase == MoonPhase.waningCrescent) {
      if (biorhythm.emotional < 0) {
        actions.add(LoveAction.reviewRelation);
      }
    }

    // Self improvement: new moon or waning crescent
    if (moonPhase == MoonPhase.newMoon ||
        moonPhase == MoonPhase.waningCrescent) {
      actions.add(LoveAction.selfImprovement);
    }

    // Default action if nothing else applies
    if (actions.isEmpty) {
      actions.add(LoveAction.selfImprovement);
    }

    return actions;
  }
}
