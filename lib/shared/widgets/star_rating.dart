import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 5-star rating display based on a 0-100 score.
class StarRating extends StatelessWidget {
  final int score;
  final double starSize;

  const StarRating({
    super.key,
    required this.score,
    this.starSize = 20,
  });

  int get _filledStars {
    if (score >= 90) return 5;
    if (score >= 70) return 4;
    if (score >= 50) return 3;
    if (score >= 30) return 2;
    return 1;
  }

  String get label {
    if (score >= 90) return '最高の日！';
    if (score >= 70) return 'とても良い';
    if (score >= 50) return 'まずまずの日';
    if (score >= 30) return '控えめな日';
    return '充電期間';
  }

  @override
  Widget build(BuildContext context) {
    final filled = _filledStars;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < filled ? AppColors.gold : AppColors.normalDay,
            size: starSize,
          ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: starSize * 0.7,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
