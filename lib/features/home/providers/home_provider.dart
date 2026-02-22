import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class HomeFortuneNotifier extends StateNotifier<HomeFortuneState> {
  HomeFortuneNotifier() : super(const HomeFortuneState()) {
    loadFortune();
  }

  Future<void> loadFortune() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Replace with actual fortune calculation from repositories
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        overallScore: 82,
        numerologyScore: 78,
        moonScore: 85,
        biorhythmScore: 83,
        advice:
            '今日は満月に近い月齢。感情が高まりやすく、素直な気持ちを伝えるのに最適な日です。',
        weekBestDays: [
          WeekBestDay(
            date: DateTime.now().add(const Duration(days: 2)),
            score: 95,
            label: '最高の告白日和',
          ),
          WeekBestDay(
            date: DateTime.now().add(const Duration(days: 4)),
            score: 88,
            label: '自然体でいられる日',
          ),
          WeekBestDay(
            date: DateTime.now().add(const Duration(days: 6)),
            score: 85,
            label: '感情が安定する日',
          ),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => loadFortune();
}

final homeFortuneProvider =
    StateNotifierProvider<HomeFortuneNotifier, HomeFortuneState>(
  (ref) => HomeFortuneNotifier(),
);
