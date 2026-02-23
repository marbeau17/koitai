import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/services/love_timing_service.dart';
import '../../../shared/widgets/star_rating.dart';
import '../providers/calendar_provider.dart';

/// Bottom sheet showing details for a selected calendar day.
class DayDetailSheet extends StatelessWidget {
  final DateTime day;
  final int score;
  final DayDetailData? detail;
  final VoidCallback? onDetail;

  const DayDetailSheet({
    super.key,
    required this.day,
    required this.score,
    this.detail,
    this.onDetail,
  });

  String get _summary {
    if (score >= 90) return '\u611F\u60C5\u304C\u6700\u9AD8\u6F6E\u306E\u65E5';
    if (score >= 70) return '\u611F\u60C5\u304C\u9AD8\u307E\u308B\u65E5';
    if (score >= 50) return '\u5B89\u5B9A\u3057\u305F\u65E5';
    return '\u5145\u96FB\u306B\u9069\u3057\u305F\u65E5';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.disabledBg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat('M/d(E)', 'ja').format(day),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '\u30B9\u30B3\u30A2: $score/100',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          StarRating(score: score),
          const SizedBox(height: 12),
          Text(
            '\u300C$_summary\u300D',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          // Individual score breakdown
          if (detail != null) ...[
            const SizedBox(height: 16),
            _ScoreBreakdownRow(
              label: '\u6570\u79D8\u8853',
              score: detail!.numerologyScore,
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: 8),
            _ScoreBreakdownRow(
              label: detail!.moonPhaseName,
              score: detail!.moonScore,
              icon: Icons.nightlight_round,
            ),
            const SizedBox(height: 8),
            _ScoreBreakdownRow(
              label: '\u30D0\u30A4\u30AA\u30EA\u30BA\u30E0',
              score: detail!.biorhythmScore,
              icon: Icons.waves,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final stars = LoveTimingService.getStarRating(score);
                    final starStr = '\u2605' * stars;
                    final dateStr =
                        DateFormat('M/d(E)', 'ja').format(day);
                    final text = '\uD83C\uDF19 \u30B3\u30A4\u30BF\u30A4'
                        ' - \u604B\u306E\u30BF\u30A4\u30DF\u30F3\u30B0\u5360\u3044\n'
                        '\n'
                        '\u3010$dateStr\u306E\u604B\u611B\u904B\u3011\n'
                        '\u30B9\u30B3\u30A2: $score\u70B9'
                        ' $starStr\n'
                        '\u300C$_summary\u300D\n'
                        '\n'
                        '\u30A2\u30D7\u30EA\u3067\u8A73\u3057\u304F\u898B\u308B'
                        ' \u25B6 https://koitai-prod.web.app\n'
                        '#\u30B3\u30A4\u30BF\u30A4 #\u604B\u611B\u904B';
                    Share.share(text);
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('\u30B7\u30A7\u30A2'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('\u8A73\u7D30'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// A row displaying a single score component with icon, label, and bar.
class _ScoreBreakdownRow extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;

  const _ScoreBreakdownRow({
    required this.label,
    required this.score,
    required this.icon,
  });

  Color get _barColor {
    if (score >= 80) return AppColors.gold;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.textSecondary;
    return AppColors.normalDay;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: AppColors.disabledBg,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
