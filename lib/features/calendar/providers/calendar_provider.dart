import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for the calendar screen.
class CalendarState {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final Map<DateTime, int> dailyScores;
  final bool isLoading;
  final String? error;

  const CalendarState({
    required this.focusedMonth,
    this.selectedDay,
    this.dailyScores = const {},
    this.isLoading = true,
    this.error,
  });

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
    Map<DateTime, int>? dailyScores,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: selectedDay ?? this.selectedDay,
      dailyScores: dailyScores ?? this.dailyScores,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier()
      : super(CalendarState(focusedMonth: DateTime.now())) {
    loadMonth(DateTime.now());
  }

  Future<void> loadMonth(DateTime month) async {
    state = state.copyWith(
      focusedMonth: month,
      isLoading: true,
      error: null,
    );
    try {
      // TODO: Replace with actual fortune calculation from repositories
      await Future.delayed(const Duration(milliseconds: 300));

      final scores = <DateTime, int>{};
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final pseudoRandom = month.year * 1000 + month.month;
      for (var d = firstDay;
          !d.isAfter(lastDay);
          d = d.add(const Duration(days: 1))) {
        final seed = (pseudoRandom + d.day * 17) % 100;
        scores[DateTime(d.year, d.month, d.day)] = (seed % 60) + 40;
      }

      state = state.copyWith(
        dailyScores: scores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  void changeMonth(DateTime month) {
    loadMonth(month);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) => CalendarNotifier(),
);
