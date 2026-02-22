import 'dart:math';

enum BiorhythmPhase {
  peak('ピーク'),
  rising('上昇中'),
  falling('下降中'),
  trough('低迷期'),
  critical('転換日');

  final String label;
  const BiorhythmPhase(this.label);

  static BiorhythmPhase fromValue(double value, double previousValue) {
    if (value.abs() < 5) return BiorhythmPhase.critical;
    if (value > 80) return BiorhythmPhase.peak;
    if (value < -80) return BiorhythmPhase.trough;
    if (value > previousValue) return BiorhythmPhase.rising;
    return BiorhythmPhase.falling;
  }
}

class BiorhythmData {
  final double physical;
  final double emotional;
  final double intellectual;
  final DateTime date;

  const BiorhythmData({
    required this.physical,
    required this.emotional,
    required this.intellectual,
    required this.date,
  });

  factory BiorhythmData.calculate({
    required DateTime birthDate,
    required DateTime targetDate,
  }) {
    final days = targetDate.difference(birthDate).inDays;
    return BiorhythmData(
      physical: sin(2 * pi * days / 23) * 100,
      emotional: sin(2 * pi * days / 28) * 100,
      intellectual: sin(2 * pi * days / 33) * 100,
      date: targetDate,
    );
  }

  /// Love fortune weighted score: emotional 50%, physical 30%, intellectual 20%
  /// Mapped from [-100, 100] to [0, 100]
  double get loveScore {
    final weighted = emotional * 0.50 + physical * 0.30 + intellectual * 0.20;
    return ((weighted + 100) / 2).clamp(0, 100);
  }
}
