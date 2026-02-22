import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/star_rating.dart';

/// Bottom sheet showing details for a selected calendar day.
class DayDetailSheet extends StatelessWidget {
  final DateTime day;
  final int score;
  final VoidCallback? onDetail;

  const DayDetailSheet({
    super.key,
    required this.day,
    required this.score,
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
