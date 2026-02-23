import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// Advice card shown on the home screen.
class TodayFortuneCard extends StatelessWidget {
  final String advice;
  final String? aiAdvice;
  final String? luckyColor;
  final String? luckyTime;
  final String? luckySpot;
  final VoidCallback? onReadMore;
  final VoidCallback? onShare;

  const TodayFortuneCard({
    super.key,
    required this.advice,
    this.aiAdvice,
    this.luckyColor,
    this.luckyTime,
    this.luckySpot,
    this.onReadMore,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final displayAdvice = aiAdvice ?? advice;
    final isAi = aiAdvice != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                AppStrings.todayAdvice,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isAi) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayAdvice,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (luckyColor != null || luckyTime != null || luckySpot != null) ...[
            const SizedBox(height: 12),
            if (luckyColor != null && luckyColor!.isNotEmpty)
              _LuckyRow(
                icon: Icons.palette,
                label: '\u30E9\u30C3\u30AD\u30FC\u30AB\u30E9\u30FC',
                value: luckyColor!,
              ),
            if (luckyTime != null && luckyTime!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _LuckyRow(
                icon: Icons.access_time,
                label: '\u30E9\u30C3\u30AD\u30FC\u30BF\u30A4\u30E0',
                value: luckyTime!,
              ),
            ],
            if (luckySpot != null && luckySpot!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _LuckyRow(
                icon: Icons.place,
                label: '\u30E9\u30C3\u30AD\u30FC\u30B9\u30DD\u30C3\u30C8',
                value: luckySpot!,
              ),
            ],
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onReadMore,
                child: const Row(
                  children: [
                    Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                    Text(
                      AppStrings.readMore,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onShare,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '\u30B7\u30A7\u30A2',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LuckyRow extends StatelessWidget {
  const _LuckyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
