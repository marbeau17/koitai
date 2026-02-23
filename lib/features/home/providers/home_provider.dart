import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/analytics_service.dart';
import '../../../domain/services/best_day_finder.dart';
import '../../../domain/services/biorhythm_service.dart';
import '../../../domain/services/fortune_text_service.dart';
import '../../../domain/services/love_timing_service.dart';
import '../../../domain/services/moon_phase_service.dart';
import '../../../domain/services/numerology_service.dart';
import '../../auth/providers/auth_provider.dart';

/// State for the home screen fortune data.
class HomeFortuneState {
  final int overallScore;
  final int numerologyScore;
  final int moonScore;
  final int biorhythmScore;
  final String advice;
  final List<WeekBestDay> weekBestDays;
  final bool isLoading;
  final String? error;

  const HomeFortuneState({
    this.overallScore = 0,
    this.numerologyScore = 0,
    this.moonScore = 0,
    this.biorhythmScore = 0,
    this.advice = '',
    this.weekBestDays = const [],
    this.isLoading = true,
    this.error,
  });

  HomeFortuneState copyWith({
    int? overallScore,
    int? numerologyScore,
    int? moonScore,
    int? biorhythmScore,
    String? advice,
    List<WeekBestDay>? weekBestDays,
    bool? isLoading,
    String? error,
  }) {
    return HomeFortuneState(
      overallScore: overallScore ?? this.overallScore,
      numerologyScore: numerologyScore ?? this.numerologyScore,
      moonScore: moonScore ?? this.moonScore,
      biorhythmScore: biorhythmScore ?? this.biorhythmScore,
      advice: advice ?? this.advice,
      weekBestDays: weekBestDays ?? this.weekBestDays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WeekBestDay {
  final DateTime date;
  final int score;
  final String label;

  const WeekBestDay({
    required this.date,
    required this.score,
    required this.label,
  });
}

/// Default birth date used as fallback when the user hasn't set one yet.
final _defaultBirthDate = DateTime(1995, 6, 15);

class HomeFortuneNotifier extends StateNotifier<HomeFortuneState> {
  final Ref _ref;

  HomeFortuneNotifier(this._ref) : super(const HomeFortuneState()) {
    loadFortune();
  }

  Future<void> loadFortune() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authState = _ref.read(authProvider);
      final birthDate = authState.birthDate ?? _defaultBirthDate;
      final today = DateTime.now();

      // Calculate individual scores
      final numerologyScore =
          NumerologyService.calculateNumerologyLoveScore(birthDate, today);

      final moonAge = MoonPhaseService.calculateMoonAge(today);
      final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
      int moonScore = MoonPhaseService.calculateMoonLoveScore(moonFraction);
      moonScore = MoonPhaseService.applyFullMoonBonus(moonScore, moonFraction);

      int biorhythmScore =
          BiorhythmService.calculateLoveBiorhythmScore(birthDate, today);
      final criticalInfo = BiorhythmService.checkCriticalDay(birthDate, today);
      biorhythmScore =
          BiorhythmService.applyCriticalDayPenalty(biorhythmScore, criticalInfo);

      // Calculate overall score
      final overallScore =
          LoveTimingService.calculateTotalLoveScore(birthDate, today);

      // Generate advice text
      final dailyAdvice = FortuneTextService.generateDailyAdvice(
        birthDate: birthDate,
        targetDate: today,
        userName: 'あなた',
      );

      // Find best days for the upcoming week
      final weekStart = today.add(const Duration(days: 1));
      final weekEnd = today.add(const Duration(days: 7));
      final bestDayResults = BestDayFinder.findBestDays(
        birthDate,
        weekStart,
        weekEnd,
        LoveAction.askForDate,
      );

      // Convert DayResult list to WeekBestDay list
      final weekBestDays = bestDayResults.map((dayResult) {
        final moonAge = MoonPhaseService.calculateMoonAge(dayResult.date);
        final fraction = MoonPhaseService.calculateMoonFraction(moonAge);
        final phase = MoonPhaseService.getMoonPhase(fraction);
        final phaseName = MoonPhaseService.getMoonPhaseName(phase);
        final stars = LoveTimingService.getStarRating(dayResult.score);
        final label = _generateDayLabel(dayResult.score, phaseName, stars);
        return WeekBestDay(
          date: dayResult.date,
          score: dayResult.score,
          label: label,
        );
      }).toList();

      // If no best days found for askForDate, fall back to scoring each day
      final effectiveWeekBestDays =
          weekBestDays.isNotEmpty ? weekBestDays : _fallbackWeekDays(birthDate, weekStart, weekEnd);

      final starRating = LoveTimingService.getStarRating(overallScore);

      state = state.copyWith(
        overallScore: overallScore,
        numerologyScore: numerologyScore,
        moonScore: moonScore,
        biorhythmScore: biorhythmScore,
        advice: dailyAdvice.mainText,
        weekBestDays: effectiveWeekBestDays,
        isLoading: false,
      );

      AnalyticsService().logViewFortune(overallScore, starRating);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Generates a short label for a week best day card.
  String _generateDayLabel(int score, String moonPhaseName, int stars) {
    if (stars >= 5) return '最高の告白日和';
    if (stars >= 4) return '$moonPhaseNameの好タイミング';
    if (stars >= 3) return '自然体でいられる日';
    if (stars >= 2) return '穏やかに過ごす日';
    return '充電の日';
  }

  /// Fallback: score every day in the range and return top 3.
  List<WeekBestDay> _fallbackWeekDays(
    DateTime birthDate,
    DateTime start,
    DateTime end,
  ) {
    final days = <WeekBestDay>[];
    for (var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      final score =
          LoveTimingService.calculateTotalLoveScore(birthDate, date);
      final moonAge = MoonPhaseService.calculateMoonAge(date);
      final fraction = MoonPhaseService.calculateMoonFraction(moonAge);
      final phase = MoonPhaseService.getMoonPhase(fraction);
      final phaseName = MoonPhaseService.getMoonPhaseName(phase);
      final stars = LoveTimingService.getStarRating(score);
      days.add(WeekBestDay(
        date: date,
        score: score,
        label: _generateDayLabel(score, phaseName, stars),
      ));
    }
    days.sort((a, b) => b.score.compareTo(a.score));
    return days.take(3).toList();
  }

  Future<void> refresh() => loadFortune();
}

final homeFortuneProvider =
    StateNotifierProvider<HomeFortuneNotifier, HomeFortuneState>(
  (ref) => HomeFortuneNotifier(ref),
);
