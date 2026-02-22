import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single pair reading history entry.
class PairHistoryEntry {
  final String nickname;
  final DateTime partnerBirthDate;
  final DateTime readingDate;
  final int compatibilityScore;

  const PairHistoryEntry({
    required this.nickname,
    required this.partnerBirthDate,
    required this.readingDate,
    required this.compatibilityScore,
  });
}

/// Result of a pair fortune reading.
class PairResult {
  final int compatibilityScore;
  final int numerologyScore;
  final int moonSyncScore;
  final int biorhythmScore;
  final List<RecommendedDate> recommendedDates;

  const PairResult({
    required this.compatibilityScore,
    required this.numerologyScore,
    required this.moonSyncScore,
    required this.biorhythmScore,
    required this.recommendedDates,
  });
}

class RecommendedDate {
  final DateTime date;
  final int score;
  final String label;

  const RecommendedDate({
    required this.date,
    required this.score,
    required this.label,
  });
}

/// State for pair fortune feature.
class PairState {
  final DateTime? partnerBirthDate;
  final String partnerNickname;
  final List<PairHistoryEntry> history;
  final PairResult? result;
  final bool isCalculating;
  final String? error;

  const PairState({
    this.partnerBirthDate,
    this.partnerNickname = '',
    this.history = const [],
    this.result,
    this.isCalculating = false,
    this.error,
  });

  PairState copyWith({
    DateTime? partnerBirthDate,
    String? partnerNickname,
    List<PairHistoryEntry>? history,
    PairResult? result,
    bool? isCalculating,
    String? error,
  }) {
    return PairState(
      partnerBirthDate: partnerBirthDate ?? this.partnerBirthDate,
      partnerNickname: partnerNickname ?? this.partnerNickname,
      history: history ?? this.history,
      result: result ?? this.result,
      isCalculating: isCalculating ?? this.isCalculating,
      error: error,
    );
  }
}

class PairNotifier extends StateNotifier<PairState> {
  PairNotifier() : super(const PairState()) {
    _loadHistory();
  }

  void setPartnerBirthDate(DateTime date) {
    state = state.copyWith(partnerBirthDate: date);
  }

  void setPartnerNickname(String name) {
    state = state.copyWith(partnerNickname: name);
  }

  Future<void> _loadHistory() async {
    // TODO: Load from Hive local storage
    state = state.copyWith(
      history: [
        PairHistoryEntry(
          nickname: 'A\u3055\u3093',
          partnerBirthDate: DateTime(1997, 5, 20),
          readingDate: DateTime.now().subtract(const Duration(days: 2)),
          compatibilityScore: 88,
        ),
        PairHistoryEntry(
          nickname: 'B\u3055\u3093',
          partnerBirthDate: DateTime(1999, 11, 8),
          readingDate: DateTime.now().subtract(const Duration(days: 4)),
          compatibilityScore: 72,
        ),
      ],
    );
  }

  Future<void> calculatePairFortune() async {
    if (state.partnerBirthDate == null) return;

    state = state.copyWith(isCalculating: true, error: null);
    try {
      // TODO: Replace with actual pair calculation
      await Future.delayed(const Duration(milliseconds: 800));

      final result = PairResult(
        compatibilityScore: 88,
        numerologyScore: 90,
        moonSyncScore: 82,
        biorhythmScore: 92,
        recommendedDates: [
          RecommendedDate(
            date: DateTime.now().add(const Duration(days: 2)),
            score: 98,
            label: '\u6700\u9AD8\u306E\u30C7\u30FC\u30C8\u65E5',
          ),
          RecommendedDate(
            date: DateTime.now().add(const Duration(days: 7)),
            score: 94,
            label: '\u81EA\u7136\u4F53\u3067\u3044\u3089\u308C\u308B',
          ),
          RecommendedDate(
            date: DateTime.now().add(const Duration(days: 11)),
            score: 91,
            label: '\u672C\u97F3\u3067\u8A9E\u308C\u308B\u65E5',
          ),
        ],
      );

      state = state.copyWith(
        result: result,
        isCalculating: false,
      );
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: e.toString());
    }
  }

  void clearResult() {
    state = state.copyWith(result: null);
  }
}

final pairProvider =
    StateNotifierProvider<PairNotifier, PairState>(
  (ref) => PairNotifier(),
);
