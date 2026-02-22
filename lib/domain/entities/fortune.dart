enum FortuneRank {
  S(85, 100, '今月最高の日！'),
  A(70, 84, 'かなり良い日'),
  B(50, 69, 'まずまずの日'),
  C(30, 49, '控えめな日'),
  D(0, 29, '充電期間');

  final int minScore;
  final int maxScore;
  final String label;

  const FortuneRank(this.minScore, this.maxScore, this.label);

  static FortuneRank fromScore(int score) {
    if (score >= S.minScore) return S;
    if (score >= A.minScore) return A;
    if (score >= B.minScore) return B;
    if (score >= C.minScore) return C;
    return D;
  }

  static FortuneRank fromString(String value) {
    return FortuneRank.values.firstWhere(
      (r) => r.name == value,
      orElse: () => FortuneRank.C,
    );
  }
}

class DailyFortune {
  final String date;
  final int overallScore;
  final FortuneRank rank;
  final int numerologyScore;
  final int moonPhaseScore;
  final int biorhythmScore;
  final String advice;
  final String luckyTime;
  final String luckyColor;
  final bool isTopDay;

  const DailyFortune({
    required this.date,
    required this.overallScore,
    required this.rank,
    required this.numerologyScore,
    required this.moonPhaseScore,
    required this.biorhythmScore,
    required this.advice,
    required this.luckyTime,
    required this.luckyColor,
    this.isTopDay = false,
  });
}

class PairCompatibility {
  final String partnerName;
  final DateTime partnerBirthDate;
  final int compatibilityScore;
  final int numerologyScore;
  final int emotionalSync;
  final List<PairBestDate> bestDates;
  final String? nextBestDate;
  final String advice;

  const PairCompatibility({
    required this.partnerName,
    required this.partnerBirthDate,
    required this.compatibilityScore,
    required this.numerologyScore,
    required this.emotionalSync,
    required this.bestDates,
    this.nextBestDate,
    required this.advice,
  });
}

class PairBestDate {
  final String date;
  final int score;
  final String reason;

  const PairBestDate({
    required this.date,
    required this.score,
    required this.reason,
  });
}
