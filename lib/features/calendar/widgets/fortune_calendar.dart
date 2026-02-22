import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Custom calendar cell builder for the fortune heatmap.
class FortuneCalendarCell extends StatelessWidget {
  final DateTime day;
  final int? score;
  final bool isToday;
  final bool isSelected;
  final bool isOutsideMonth;

  const FortuneCalendarCell({
    super.key,
    required this.day,
    this.score,
    this.isToday = false,
    this.isSelected = false,
    this.isOutsideMonth = false,
  });

  Color get _dotColor {
    if (score == null) return Colors.transparent;
    if (score! >= 90) return AppColors.gold;
    if (score! >= 70) return AppColors.primary;
    if (score! >= 50) return AppColors.textSecondary;
    return AppColors.normalDay;
  }

  String get _symbol {
    if (score == null) return '';
    if (score! >= 90) return '\u2605'; // filled star
    if (score! >= 70) return '\u25CF'; // filled circle
    if (score! >= 50) return '\u25D0'; // half circle
    return '\u25CB'; // empty circle
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: isToday
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isOutsideMonth
                  ? AppColors.disabledBg
                  : isSelected
                      ? Colors.white
                      : isToday
                          ? AppColors.accent
                          : AppColors.textPrimary,
            ),
          ),
          if (!isOutsideMonth && score != null)
            Text(
              _symbol,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : _dotColor,
              ),
            ),
        ],
      ),
    );
  }
}
