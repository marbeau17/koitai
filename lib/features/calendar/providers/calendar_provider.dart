import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/services/love_timing_service.dart';
import '../../../domain/services/numerology_service.dart';
import '../../../domain/services/moon_phase_service.dart';
import '../../../domain/services/biorhythm_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Detail breakdown for a single selected day.
class DayDetailData {
  final DateTime date;
  final int totalScore;
  final int numerologyScore;
  final int moonScore;
  final int biorhythmScore;
  final MoonPhase moonPhase;
  final String moonPhaseName;
  final BiorhythmValues biorhythm;
  final int starRating;

  const DayDetailData({
    required this.date,
    required this.totalScore,
    required this.numerologyScore,
    required this.moonScore,
    required this.biorhythmScore,
    required this.moonPhase,
    required this.moonPhaseName,
    required this.biorhythm,
    required this.starRating,
  });
}

/// State for the calendar screen.
class CalendarState {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Map<DateTime, int> dailyScores;
  final DayDetailData? selectedDayDetail;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.focusedMonth,
    this.selectedDay,
    this.dailyScores = const {},
    this.selectedDayDetail,
    this.isLoading = true,
    this.error,
  });

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
    Map<DateTime, int>? dailyScores,
    DayDetailData? selectedDayDetail,
    bool? isLoading,
    String? error,
    bool clearSelectedDay = false,
    bool clearSelectedDayDetail = false,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      dailyScores: dailyScores ?? this.dailyScores,
      selectedDayDetail: clearSelectedDayDetail
          ? null
          : (selectedDayDetail ?? this.selectedDayDetail),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final Ref _ref;

  /// Default birthDate used as fallback when auth has no birthDate.
  static final DateTime _defaultBirthDate = DateTime(1995, 6, 15);

  /// Cache of calculated month scores keyed by "year-month".
  final Map<String, Map<DateTime, int>> _monthCache = {};

  CalendarNotifier(this._ref)
      : super(CalendarState(focusedMonth: DateTime.now())) {
    loadMonth(DateTime.now());
  }

  /// Retrieves the user's birth date from auth state, or uses the default.
  DateTime get _birthDate {
    final authState = _ref.read(authProvider);
    return authState.birthDate ?? _defaultBirthDate;
  }

  /// Returns a cache key for the given month and birth date combination.
  String _cacheKey(DateTime month, DateTime birthDate) {
    return '${month.year}-${month.month}-${birthDate.year}-${birthDate.month}-${birthDate.day}';
  }

  Future<void> loadMonth(DateTime month) async {
    state = state.copyWith(
      focusedMonth: month,
      isLoading: true,
      error: null,
    );
    try {
      final birthDate = _birthDate;
      final key = _cacheKey(month, birthDate);

      // Return cached scores if available.
      if (_monthCache.containsKey(key)) {
        state = state.copyWith(
          dailyScores: _monthCache[key]!,
          isLoading: false,
        );
        return;
      }

      // Calculate fortune scores for each day of the month.
      final scores = <DateTime, int>{};
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      for (var d = firstDay;
          !d.isAfter(lastDay);
          d = d.add(const Duration(days: 1))) {
        final normalDay = DateTime(d.year, d.month, d.day);
        scores[normalDay] = LoveTimingService.calculateTotalLoveScore(
          birthDate,
          normalDay,
        );
      }

      // Store in cache.
      _monthCache[key] = scores;

      state = state.copyWith(
        dailyScores: scores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectDay(DateTime day) {
    final normalDay = DateTime(day.year, day.month, day.day);
    final birthDate = _birthDate;

    // Calculate individual component scores for the detail view.
    final numerologyScore =
        NumerologyService.calculateNumerologyLoveScore(birthDate, normalDay);

    final moonAge = MoonPhaseService.calculateMoonAge(normalDay);
    final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
    int moonScore = MoonPhaseService.calculateMoonLoveScore(moonFraction);
    moonScore = MoonPhaseService.applyFullMoonBonus(moonScore, moonFraction);
    final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
    final moonPhaseName = MoonPhaseService.getMoonPhaseName(moonPhase);

    int biorhythmScore =
        BiorhythmService.calculateLoveBiorhythmScore(birthDate, normalDay);
    final criticalInfo =
        BiorhythmService.checkCriticalDay(birthDate, normalDay);
    biorhythmScore =
        BiorhythmService.applyCriticalDayPenalty(biorhythmScore, criticalInfo);
    final biorhythm =
        BiorhythmService.calculateBiorhythm(birthDate, normalDay);

    final totalScore =
        LoveTimingService.calculateTotalLoveScore(birthDate, normalDay);
    final starRating = LoveTimingService.getStarRating(totalScore);

    final detail = DayDetailData(
      date: normalDay,
      totalScore: totalScore,
      numerologyScore: numerologyScore,
      moonScore: moonScore,
      biorhythmScore: biorhythmScore,
      moonPhase: moonPhase,
      moonPhaseName: moonPhaseName,
      biorhythm: biorhythm,
      starRating: starRating,
    );

    state = state.copyWith(selectedDay: normalDay, selectedDayDetail: detail);
  }

  void changeMonth(DateTime month) {
    loadMonth(month);
  }

  /// Clears the month cache (e.g., when birth date changes).
  void clearCache() {
    _monthCache.clear();
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) => CalendarNotifier(ref),
);
