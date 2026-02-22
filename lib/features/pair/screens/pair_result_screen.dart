import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/score_bar.dart';
import '../providers/pair_provider.dart';
import '../widgets/compatibility_gauge.dart';

class PairResultScreen extends ConsumerWidget {
  const PairResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pair = ref.watch(pairProvider);
    final result = pair.result;

    if (result == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Text(
            '\u7D50\u679C\u304C\u3042\u308A\u307E\u305B\u3093',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            '\u30DA\u30A2\u5360\u3044\u7D50\u679C',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Names row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.pairYou,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\u2661\u2661\u2661',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pair.partnerNickname.isEmpty
                      ? '\u304A\u76F8\u624B'
                      : pair.partnerNickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Compatibility gauge
            Center(
              child: CompatibilityGauge(
                score: result.compatibilityScore,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '2\u4EBA\u306E\u76F8\u6027\u30BF\u30A4\u30DF\u30F3\u30B0',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Score breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ScoreBar(
                    label: '\u6570\u79D8\u8853\u76F8\u6027',
                    score: result.numerologyScore,
                  ),
                  ScoreBar(
                    label: '\u6708\u9F62\u30B7\u30F3\u30AF\u30ED',
                    score: result.moonSyncScore,
                  ),
                  ScoreBar(
                    label: '\u30D0\u30A4\u30AA\u30EA\u30BA\u30E0',
                    score: result.biorhythmScore,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommended dates
            const Text(
              AppStrings.recommendedDates,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(result.recommendedDates.length, (index) {
              final date = result.recommendedDates[index];
              final medals = [
                '\uD83E\uDD47',
                '\uD83E\uDD48',
                '\uD83E\uDD49'
              ];
              final medal = index < medals.length ? medals[index] : '\u2B50';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: index == 0
                      ? Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      medal,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateFormat('M/d(E)', 'ja').format(date.date)} ${date.score}\u70B9',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\u300C${date.label}\u300D',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to paywall for more dates
                },
                child: const Text(
                  '\u3082\u3063\u3068\u898B\u308B(\u6709\u6599)',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Share result
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('\u30B7\u30A7\u30A2\u3059\u308B'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(pairProvider.notifier).clearResult();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('\u3082\u3046\u4E00\u5EA6'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
