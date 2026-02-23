import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/calendar_provider.dart';
import '../widgets/fortune_calendar.dart';
import '../widgets/day_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    final focusedMonth = ref.read(calendarProvider).focusedMonth;
    final monthStr =
        '${focusedMonth.year}-${focusedMonth.month.toString().padLeft(2, '0')}';
    AnalyticsService().logViewCalendar(monthStr);
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calendarProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                AppStrings.tabCalendar,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${calState.focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        body: calState.isLoading
            ? const Center(child: LoadingIndicator())
            : calState.error != null
                ? ErrorView(
                    message: calState.error,
                    onRetry: () => ref
                        .read(calendarProvider.notifier)
                        .loadMonth(calState.focusedMonth),
                  )
                : Column(
                    children: [
                      // Calendar
                      TableCalendar(
                        firstDay: DateTime(2020, 1, 1),
                        lastDay: DateTime(2030, 12, 31),
                        focusedDay: calState.focusedMonth,
                        selectedDayPredicate: (day) =>
                            calState.selectedDay != null &&
                            isSameDay(calState.selectedDay!, day),
                        onDaySelected: (selected, focused) {
                          ref
                              .read(calendarProvider.notifier)
                              .selectDay(selected);
                          final normalDay = DateTime(
                            selected.year,
                            selected.month,
                            selected.day,
                          );
                          final score =
                              calState.dailyScores[normalDay] ?? 50;
                          final detail = ref.read(calendarProvider).selectedDayDetail;
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => DayDetailSheet(
                              day: selected,
                              score: score,
                              detail: detail,
                              onDetail: () {
                                Navigator.pop(context);
                                final dateStr = DateFormat('yyyy-MM-dd')
                                    .format(selected);
                                context.push(
                                    AppRoutes.detailPath(dateStr));
                              },
                            ),
                          );
                        },
                        onPageChanged: (focused) {
                          ref
                              .read(calendarProvider.notifier)
                              .changeMonth(focused);
                          final monthStr =
                              '${focused.year}-${focused.month.toString().padLeft(2, '0')}';
                          AnalyticsService().logViewCalendar(monthStr);
                        },
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: 'ja_JP',
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: AppColors.textSecondary,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focused) {
                            final normalDay =
                                DateTime(day.year, day.month, day.day);
                            final score =
                                calState.dailyScores[normalDay];
                            return FortuneCalendarCell(
                              day: day,
                              score: score,
                              isToday: isSameDay(day, DateTime.now()),
                            );
                          },
                          todayBuilder: (context, day, focused) {
                            final normalDay =
                                DateTime(day.year, day.month, day.day);
                            final score =
                                calState.dailyScores[normalDay];
                            return FortuneCalendarCell(
                              day: day,
                              score: score,
                              isToday: true,
                            );
                          },
                          selectedBuilder: (context, day, focused) {
                            final normalDay =
                                DateTime(day.year, day.month, day.day);
                            final score =
                                calState.dailyScores[normalDay];
                            return FortuneCalendarCell(
                              day: day,
                              score: score,
                              isToday: isSameDay(day, DateTime.now()),
                              isSelected: true,
                            );
                          },
                          outsideBuilder: (context, day, focused) {
                            return FortuneCalendarCell(
                              day: day,
                              isOutsideMonth: true,
                            );
                          },
                        ),
                        calendarStyle: const CalendarStyle(
                          outsideDaysVisible: true,
                          cellMargin: EdgeInsets.all(2),
                        ),
                      ),
                      // Legend
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(
                                color: AppColors.gold,
                                label: '\u6700\u9AD8(90+)'),
                            const SizedBox(width: 12),
                            _LegendItem(
                                color: AppColors.primary,
                                label: '\u826F\u3044(70+)'),
                            const SizedBox(width: 12),
                            _LegendItem(
                                color: AppColors.textSecondary,
                                label: '\u666E\u901A(50+)'),
                            const SizedBox(width: 12),
                            _LegendItem(
                                color: AppColors.normalDay,
                                label: '\u63A7\u3048\u3081'),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
