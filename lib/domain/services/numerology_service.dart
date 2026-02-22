/// Numerology calculation service for love timing fortune.
///
/// Based on Pythagorean numerology with master number support (11, 22, 33).
class NumerologyService {
  /// Personal day number base love scores (0-100).
  static const Map<int, int> _dayScoreTable = {
    1: 70,
    2: 85,
    3: 80,
    4: 50,
    5: 75,
    6: 95,
    7: 45,
    8: 65,
    9: 60,
    11: 90,
    22: 70,
    33: 88,
  };

  /// Life path number love score multipliers.
  static const Map<int, double> _lifePathMultiplierTable = {
    1: 1.0,
    2: 1.15,
    3: 1.10,
    4: 0.95,
    5: 1.05,
    6: 1.20,
    7: 0.90,
    8: 1.00,
    9: 1.10,
    11: 1.15,
    22: 1.05,
    33: 1.20,
  };

  /// Reduces a number to a single digit, preserving master numbers (11, 22, 33).
  static int reduceToSingleDigit(int n) {
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      int sum = 0;
      while (n > 0) {
        sum += n % 10;
        n ~/= 10;
      }
      n = sum;
    }
    return n;
  }

  /// Sums the digits of a number.
  static int _digitSum(int n) {
    int sum = 0;
    int abs = n.abs();
    while (abs > 0) {
      sum += abs % 10;
      abs ~/= 10;
    }
    return sum;
  }

  /// Calculates the Life Path Number from a birth date.
  ///
  /// Each component (year, month, day) is reduced independently,
  /// then summed and reduced again. Master numbers are preserved.
  static int calculateLifePathNumber(DateTime birthDate) {
    final yearReduced = reduceToSingleDigit(_digitSum(birthDate.year));
    final monthReduced = reduceToSingleDigit(_digitSum(birthDate.month));
    final dayReduced = reduceToSingleDigit(_digitSum(birthDate.day));

    final total = yearReduced + monthReduced + dayReduced;
    return reduceToSingleDigit(total);
  }

  /// Calculates the Personal Year Number.
  ///
  /// Reflects the individual's fortune cycle for [targetYear].
  static int calculatePersonalYear(DateTime birthDate, int targetYear) {
    final monthReduced = reduceToSingleDigit(_digitSum(birthDate.month));
    final dayReduced = reduceToSingleDigit(_digitSum(birthDate.day));
    final yearReduced = reduceToSingleDigit(_digitSum(targetYear));

    final total = monthReduced + dayReduced + yearReduced;
    return reduceToSingleDigit(total);
  }

  /// Calculates the Personal Month Number.
  static int calculatePersonalMonth(int personalYear, int targetMonth) {
    final monthReduced = reduceToSingleDigit(_digitSum(targetMonth));
    final total = personalYear + monthReduced;
    return reduceToSingleDigit(total);
  }

  /// Calculates the Personal Day Number.
  static int calculatePersonalDay(
    int personalYear,
    int targetMonth,
    int targetDay,
  ) {
    final monthReduced = reduceToSingleDigit(_digitSum(targetMonth));
    final dayReduced = reduceToSingleDigit(_digitSum(targetDay));
    final total = personalYear + monthReduced + dayReduced;
    return reduceToSingleDigit(total);
  }

  /// Calculates the numerology-based love score (0-100).
  ///
  /// Combines personal day base score, life path multiplier,
  /// and personal year bonus.
  static int calculateNumerologyLoveScore(
    DateTime birthDate,
    DateTime targetDate,
  ) {
    final lifePathNumber = calculateLifePathNumber(birthDate);
    final personalYear = calculatePersonalYear(birthDate, targetDate.year);
    final personalDay = calculatePersonalDay(
      personalYear,
      targetDate.month,
      targetDate.day,
    );

    final baseScore = _dayScoreTable[personalDay] ?? 50;
    final multiplier = _lifePathMultiplierTable[lifePathNumber] ?? 1.0;

    int yearBonus = 0;
    if (personalYear == 2) yearBonus = 5;
    if (personalYear == 6) yearBonus = 10;
    if (personalYear == 9) yearBonus = -5;

    final score = (baseScore * multiplier + yearBonus).round();
    return score.clamp(0, 100);
  }
}
