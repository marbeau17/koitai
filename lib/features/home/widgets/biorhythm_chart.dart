import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Biorhythm wave chart using fl_chart.
class BiorhythmChart extends StatelessWidget {
  final DateTime birthDate;
  final DateTime targetDate;
  final double height;

  const BiorhythmChart({
    super.key,
    required this.birthDate,
    required this.targetDate,
    this.height = 180,
  });

  int get _daysSinceBirth =>
      targetDate.difference(birthDate).inDays;

  List<FlSpot> _generateCurve(int cycleDays, int dayOffset) {
    const pointCount = 30;
    return List.generate(pointCount + 1, (i) {
      final day = _daysSinceBirth - 15 + i + dayOffset;
      final value = sin(2 * pi * day / cycleDays);
      return FlSpot(i.toDouble(), value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final physicalSpots = _generateCurve(23, 0);
    final emotionalSpots = _generateCurve(28, 0);
    final intellectualSpots = _generateCurve(33, 0);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: -1.2,
          maxY: 1.2,
          minX: 0,
          maxX: 30,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.disabledBg,
              strokeWidth: value == 0 ? 1 : 0.3,
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final dayOffset = value.toInt() - 15;
                  if (dayOffset == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '今日',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Physical (red-ish / accent)
            LineChartBarData(
              spots: physicalSpots,
              isCurved: true,
              color: AppColors.accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            // Emotional (primary)
            LineChartBarData(
              spots: emotionalSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
            // Intellectual (gold)
            LineChartBarData(
              spots: intellectualSpots,
              isCurved: true,
              color: AppColors.gold,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: 15,
                color: AppColors.accent.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
