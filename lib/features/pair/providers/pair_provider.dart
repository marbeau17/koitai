import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/analytics_service.dart';
import '../../../domain/services/best_day_finder.dart';
import '../../../domain/services/love_timing_service.dart';
import '../../../domain/services/moon_phase_service.dart';
import '../../../domain/services/numerology_service.dart';
import '../../auth/providers/auth_provider.dart';

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

/// Default fallback birth date when user's own birthday is not available.
final _fallbackBirthDate = DateTime(1995, 6, 15);

class PairNotifier extends StateNotifier<PairState> {
  final Ref _ref;

  PairNotifier(this._ref) : super(const PairState()) {
    _loadHistory();
  }

  /// Returns the user's birth date from auth state, or the fallback.
  DateTime get _myBirthDate =>
      _ref.read(authProvider).birthDate ?? _fallbackBirthDate;

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
      final myBirth = _myBirthDate;
      final partnerBirth = state.partnerBirthDate!;
      final today = DateTime.now();

      // --- Core pair timing score (integrates numerology, moon, biorhythm) ---
      final pairTimingScore = LoveTimingService.calculatePairTimingScore(
        myBirth,
        partnerBirth,
        today,
      );

      // --- Base numerology compatibility ---
      final myLifePath =
          NumerologyService.calculateLifePathNumber(myBirth);
      final partnerLifePath =
          NumerologyService.calculateLifePathNumber(partnerBirth);
      final numerologyCompat =
          LoveTimingService.getCompatibilityScore(myLifePath, partnerLifePath);

      // --- Moon sync score (moon-based love score for today) ---
      final moonAge = MoonPhaseService.calculateMoonAge(today);
      final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
      int moonSyncScore = MoonPhaseService.calculateMoonLoveScore(moonFraction);
      moonSyncScore =
          MoonPhaseService.applyFullMoonBonus(moonSyncScore, moonFraction);

      // --- Biorhythm sync score between the pair ---
      final bioSyncScore = LoveTimingService.calculateBiorhythmSync(
        myBirth,
        partnerBirth,
        today,
      ).round().clamp(0, 100);

      // --- Recommended dates: confession + date days ---
      final searchEnd = today.add(const Duration(days: 90));

      final confessionDays = BestDayFinder.findBestConfessionDays(
        myBirth,
        today,
        searchEnd,
        partnerBirthDate: partnerBirth,
      );

      final dateDays = BestDayFinder.findBestDateDays(
        myBirth,
        today,
        searchEnd,
        partnerBirthDate: partnerBirth,
      );

      // Build recommended date list (up to 3 entries).
      final recommendedDates = <RecommendedDate>[];

      // Best confession day first (if any).
      if (confessionDays.isNotEmpty) {
        final best = confessionDays.first;
        recommendedDates.add(RecommendedDate(
          date: best.date,
          score: best.score,
          label: '\u544A\u767D\u306B\u6700\u9069\u306A\u65E5',
        ));
      }

      // Fill remaining slots with best date days (skip duplicates).
      for (final day in dateDays) {
        if (recommendedDates.length >= 3) break;
        final isDuplicate = recommendedDates.any(
          (r) =>
              r.date.year == day.date.year &&
              r.date.month == day.date.month &&
              r.date.day == day.date.day,
        );
        if (!isDuplicate) {
          final label = _dateDayLabel(day);
          recommendedDates.add(RecommendedDate(
            date: day.date,
            score: day.score,
            label: label,
          ));
        }
      }

      // Fallback if no ideal days were found at all.
      if (recommendedDates.isEmpty) {
        final tomorrow = today.add(const Duration(days: 1));
        final fallbackScore = LoveTimingService.calculatePairTimingScore(
          myBirth,
          partnerBirth,
          tomorrow,
        );
        recommendedDates.add(RecommendedDate(
          date: tomorrow,
          score: fallbackScore,
          label: '2\u4EBA\u306E\u6642\u9593\u3092\u697D\u3057\u3093\u3067',
        ));
      }

      final result = PairResult(
        compatibilityScore: pairTimingScore,
        numerologyScore: numerologyCompat,
        moonSyncScore: moonSyncScore,
        biorhythmScore: bioSyncScore,
        recommendedDates: recommendedDates,
      );

      // Add to history.
      final nickname = state.partnerNickname.isEmpty
          ? '\u304A\u76F8\u624B'
          : state.partnerNickname;
      final updatedHistory = [
        PairHistoryEntry(
          nickname: nickname,
          partnerBirthDate: partnerBirth,
          readingDate: today,
          compatibilityScore: pairTimingScore,
        ),
        ...state.history,
      ];

      state = state.copyWith(
        result: result,
        history: updatedHistory,
        isCalculating: false,
      );

      AnalyticsService().logViewPairResult(pairTimingScore);
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: e.toString());
    }
  }

  /// Returns a descriptive label for a recommended date day.
  String _dateDayLabel(DayResult day) {
    final phaseName = MoonPhaseService.getMoonPhaseName(day.moonPhase);
    if (day.starRating >= 5) {
      return '\u6700\u9AD8\u306E\u30C7\u30FC\u30C8\u65E5\uFF08$phaseName\uFF09';
    } else if (day.starRating >= 4) {
      return '\u81EA\u7136\u4F53\u3067\u3044\u3089\u308C\u308B\u65E5\uFF08$phaseName\uFF09';
    } else {
      return '\u3086\u3063\u305F\u308A\u904E\u3054\u305B\u308B\u65E5\uFF08$phaseName\uFF09';
    }
  }

  void clearResult() {
    state = state.copyWith(result: null);
  }
}

final pairProvider =
    StateNotifierProvider<PairNotifier, PairState>(
  (ref) => PairNotifier(ref),
);
