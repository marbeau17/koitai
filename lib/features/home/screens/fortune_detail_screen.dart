import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/services/biorhythm_service.dart';
import '../../../domain/services/fortune_text_service.dart';
import '../../../domain/services/love_timing_service.dart';
import '../../../domain/services/moon_phase_service.dart';
import '../../../domain/services/numerology_service.dart';
import '../../../shared/widgets/fortune_score_badge.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/score_bar.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../auth/providers/auth_provider.dart';

/// Full fortune detail screen for a given date.
class FortuneDetailScreen extends ConsumerWidget {
  const FortuneDetailScreen({super.key, required this.date});

  /// Date string in "yyyy-MM-dd" format.
  final String date;

  /// Default birth date used as fallback when the user hasn't set one yet.
  static final _defaultBirthDate = DateTime(1995, 6, 15);

  /// Returns a moon phase emoji for a given [MoonPhase].
  static String _moonPhaseEmoji(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return '\uD83C\uDF11'; // 🌑
      case MoonPhase.waxingCrescent:
        return '\uD83C\uDF12'; // 🌒
      case MoonPhase.firstQuarter:
        return '\uD83C\uDF13'; // 🌓
      case MoonPhase.waxingGibbous:
        return '\uD83C\uDF14'; // 🌔
      case MoonPhase.fullMoon:
        return '\uD83C\uDF15'; // 🌕
      case MoonPhase.waningGibbous:
        return '\uD83C\uDF16'; // 🌖
      case MoonPhase.lastQuarter:
        return '\uD83C\uDF17'; // 🌗
      case MoonPhase.waningCrescent:
        return '\uD83C\uDF18'; // 🌘
    }
  }

  /// Returns an icon for a given [LoveAction].
  static IconData _actionIcon(LoveAction action) {
    switch (action) {
      case LoveAction.confession:
        return Icons.favorite;
      case LoveAction.proposal:
        return Icons.diamond;
      case LoveAction.askForDate:
        return Icons.restaurant;
      case LoveAction.sendMessage:
        return Icons.chat_bubble;
      case LoveAction.exchangeContact:
        return Icons.contacts;
      case LoveAction.reviewRelation:
        return Icons.psychology;
      case LoveAction.selfImprovement:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse the date string.
    final targetDate = DateTime.tryParse(date) ?? DateTime.now();

    // Read user birth date from auth provider.
    final birthDate = ref.watch(authProvider).birthDate ?? _defaultBirthDate;

    // Calculate all fortune scores.
    final overallScore =
        LoveTimingService.calculateTotalLoveScore(birthDate, targetDate);
    final starRating = LoveTimingService.getStarRating(overallScore);

    final numerologyScore =
        NumerologyService.calculateNumerologyLoveScore(birthDate, targetDate);

    final moonAge = MoonPhaseService.calculateMoonAge(targetDate);
    final moonFraction = MoonPhaseService.calculateMoonFraction(moonAge);
    int moonScore = MoonPhaseService.calculateMoonLoveScore(moonFraction);
    moonScore = MoonPhaseService.applyFullMoonBonus(moonScore, moonFraction);
    final moonPhase = MoonPhaseService.getMoonPhase(moonFraction);
    final moonPhaseName = MoonPhaseService.getMoonPhaseName(moonPhase);

    int biorhythmScore =
        BiorhythmService.calculateLoveBiorhythmScore(birthDate, targetDate);
    final criticalInfo =
        BiorhythmService.checkCriticalDay(birthDate, targetDate);
    biorhythmScore =
        BiorhythmService.applyCriticalDayPenalty(biorhythmScore, criticalInfo);

    final biorhythm =
        BiorhythmService.calculateBiorhythm(birthDate, targetDate);

    // Generate advice.
    final dailyAdvice = FortuneTextService.generateDailyAdvice(
      birthDate: birthDate,
      targetDate: targetDate,
      userName: '\u3042\u306A\u305F', // あなた
    );

    // Get recommended actions.
    final actions = LoveTimingService.getRecommendedActions(
      overallScore,
      moonFraction,
      biorhythm,
    );

    // Format the date for the app bar.
    final formattedDate = DateFormat('M\u6708d\u65E5(E)', 'ja').format(targetDate);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '$formattedDate\u306E\u904B\u52E2', // の運勢
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // ── Overall Score Badge ──────────────────────────────
            const SizedBox(height: 16),
            const Center(
              child: Text(
                AppStrings.overallScore,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: FortuneScoreBadge(score: overallScore),
            ),
            const SizedBox(height: 8),
            Center(
              child: StarRating(score: overallScore),
            ),

            // ── Score Breakdown ──────────────────────────────────
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u30B9\u30B3\u30A2\u5185\u8A33', // スコア内訳
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ScoreBar(
                    label: AppStrings.numerology,
                    score: numerologyScore,
                  ),
                  ScoreBar(
                    label: AppStrings.moonPhase,
                    score: moonScore,
                  ),
                  ScoreBar(
                    label: AppStrings.biorhythm,
                    score: biorhythmScore,
                  ),
                ],
              ),
            ),

            // ── Moon Phase Info ──────────────────────────────────
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    _moonPhaseEmoji(moonPhase),
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moonPhaseName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\u6708\u9F62: ${moonAge.toStringAsFixed(1)}\u65E5'
                          ' / \u604B\u611B\u30B9\u30B3\u30A2: $moonScore\u70B9',
                          // 月齢: X.X日 / 恋愛スコア: XX点
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
            ),

            // ── Biorhythm Summary ────────────────────────────────
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u30D0\u30A4\u30AA\u30EA\u30BA\u30E0\u8A73\u7D30',
                    // バイオリズム詳細
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BiorhythmRow(
                    label: '\u8EAB\u4F53', // 身体
                    value: biorhythm.physical,
                    phase: BiorhythmService.getBiorhythmPhase(
                        biorhythm.physical),
                  ),
                  const SizedBox(height: 8),
                  _BiorhythmRow(
                    label: '\u611F\u60C5', // 感情
                    value: biorhythm.emotional,
                    phase: BiorhythmService.getBiorhythmPhase(
                        biorhythm.emotional),
                  ),
                  const SizedBox(height: 8),
                  _BiorhythmRow(
                    label: '\u77E5\u6027', // 知性
                    value: biorhythm.intellectual,
                    phase: BiorhythmService.getBiorhythmPhase(
                        biorhythm.intellectual),
                  ),
                ],
              ),
            ),

            // ── Advice Card ──────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  left: BorderSide(color: AppColors.accent, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.todayAdvice,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dailyAdvice.mainText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LuckyItemRow(
                    icon: Icons.palette,
                    label: '\u30E9\u30C3\u30AD\u30FC\u30AB\u30E9\u30FC',
                    // ラッキーカラー
                    value: dailyAdvice.luckyColor,
                  ),
                  const SizedBox(height: 6),
                  _LuckyItemRow(
                    icon: Icons.access_time,
                    label: '\u30E9\u30C3\u30AD\u30FC\u30BF\u30A4\u30E0',
                    // ラッキータイム
                    value: dailyAdvice.luckyTime,
                  ),
                  const SizedBox(height: 6),
                  _LuckyItemRow(
                    icon: Icons.place,
                    label: '\u30E9\u30C3\u30AD\u30FC\u30B9\u30DD\u30C3\u30C8',
                    // ラッキースポット
                    value: dailyAdvice.luckySpot,
                  ),
                ],
              ),
            ),

            // ── Recommended Actions ──────────────────────────────
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u304A\u3059\u3059\u3081\u30A2\u30AF\u30B7\u30E7\u30F3',
                      // おすすめアクション
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...actions.map((action) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _actionIcon(action),
                                  color: AppColors.primaryLight,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                FortuneTextService.getActionLabel(action),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],

            // ── Share Button ─────────────────────────────────────
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  final starStr = '\u2605' * starRating;
                  final text = '\uD83C\uDF19 \u30B3\u30A4\u30BF\u30A4'
                      ' - \u604B\u306E\u30BF\u30A4\u30DF\u30F3\u30B0\u5360\u3044\n'
                      '\n'
                      '\u3010$formattedDate\u306E\u604B\u611B\u904B\u3011\n'
                      '\u30B9\u30B3\u30A2: $overallScore\u70B9'
                      ' $starStr\n'
                      '${dailyAdvice.mainText}\n'
                      '\n'
                      '\u30A2\u30D7\u30EA\u3067\u8A73\u3057\u304F\u898B\u308B'
                      ' \u25B6 https://koitai-prod.web.app\n'
                      '#\u30B3\u30A4\u30BF\u30A4 #\u604B\u611B\u904B';
                  Share.share(text);
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text(AppStrings.shareResult),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row in the biorhythm detail section.
class _BiorhythmRow extends StatelessWidget {
  const _BiorhythmRow({
    required this.label,
    required this.value,
    required this.phase,
  });

  final String label;
  final double value;
  final String phase;

  @override
  Widget build(BuildContext context) {
    // Map value from [-1, 1] to [0, 1] for the progress indicator.
    final normalised = ((value + 1.0) / 2.0).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: normalised,
              minHeight: 8,
              backgroundColor: AppColors.disabledBg,
              valueColor: AlwaysStoppedAnimation<Color>(
                value > 0.3
                    ? AppColors.primary
                    : value > -0.3
                        ? AppColors.primaryLight
                        : AppColors.normalDay,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            phase,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// A row displaying a lucky item (color, time, or spot).
class _LuckyItemRow extends StatelessWidget {
  const _LuckyItemRow({
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
        Icon(icon, color: AppColors.primaryLight, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
