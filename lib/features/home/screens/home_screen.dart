import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/fortune_score_badge.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/score_bar.dart';
import '../../../shared/widgets/star_rating.dart';
import '../providers/home_provider.dart';
import '../widgets/today_fortune_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortune = ref.watch(homeFortuneProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('M/d(E)', 'ja').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.nightlight_round,
                color: AppColors.primaryLight,
                size: 20,
              ),
            ],
          ),
        ),
        body: fortune.isLoading
            ? const Center(child: LoadingIndicator())
            : fortune.error != null
                ? ErrorView(
                    message: fortune.error,
                    onRetry: () =>
                        ref.read(homeFortuneProvider.notifier).refresh(),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.bgCard,
                    onRefresh: () =>
                        ref.read(homeFortuneProvider.notifier).refresh(),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              AppStrings.todayFortune,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: FortuneScoreBadge(
                            score: fortune.overallScore,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: StarRating(score: fortune.overallScore),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              ScoreBar(
                                label: AppStrings.numerology,
                                score: fortune.numerologyScore,
                              ),
                              ScoreBar(
                                label: AppStrings.moonPhase,
                                score: fortune.moonScore,
                              ),
                              ScoreBar(
                                label: AppStrings.biorhythm,
                                score: fortune.biorhythmScore,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        TodayFortuneCard(
                          advice: fortune.advice,
                          onReadMore: () {
                            // TODO: Navigate to detail screen
                          },
                          onShare: () {
                            // TODO: Navigate to share screen
                          },
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            AppStrings.weekBestTiming,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: fortune.weekBestDays.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final day = fortune.weekBestDays[index];
                              return _WeekBestDayCard(day: day);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _WeekBestDayCard extends StatelessWidget {
  final WeekBestDay day;

  const _WeekBestDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: day.score >= 90
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('M/d(E)', 'ja').format(day.date),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          StarRating(score: day.score, starSize: 14),
          const SizedBox(height: 4),
          Text(
            '\u300C${day.label}\u300D',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
