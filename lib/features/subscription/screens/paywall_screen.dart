import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: sub.isPurchasing || sub.isRestoring
            ? Center(
                child: LoadingIndicator(
                  message: sub.isPurchasing
                      ? '\u8CFC\u5165\u4E2D...'
                      : '\u5FA9\u5143\u4E2D...',
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  const Center(
                    child: Icon(
                      Icons.nightlight_round,
                      size: 40,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      AppStrings.premiumTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      AppStrings.premiumSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Benefits
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        _BenefitRow(
                          icon: Icons.auto_awesome,
                          text: '\u5168\u5360\u8853\u306E\u8A73\u7D30\u7D50\u679C',
                        ),
                        SizedBox(height: 12),
                        _BenefitRow(
                          icon: Icons.calendar_month,
                          text: '\u7FCC\u6708\u4EE5\u964D\u306E\u30AB\u30EC\u30F3\u30C0\u30FC\u95B2\u89A7',
                        ),
                        SizedBox(height: 12),
                        _BenefitRow(
                          icon: Icons.favorite,
                          text: '\u30DA\u30A2\u5360\u3044\u7121\u5236\u9650',
                        ),
                        SizedBox(height: 12),
                        _BenefitRow(
                          icon: Icons.notifications_active,
                          text: '\u30D7\u30EC\u30DF\u30A2\u30E0\u901A\u77E5',
                        ),
                        SizedBox(height: 12),
                        _BenefitRow(
                          icon: Icons.block,
                          text: '\u5E83\u544A\u975E\u8868\u793A',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Monthly plan
                  _PlanCard(
                    title: AppStrings.monthlyPlan,
                    price: AppStrings.monthlyPrice,
                    subtitle: AppStrings.cancelAnytime,
                    isSelected: sub.selectedPlan == SubscriptionPlan.monthly,
                    onTap: () => ref
                        .read(subscriptionProvider.notifier)
                        .selectPlan(SubscriptionPlan.monthly),
                  ),
                  const SizedBox(height: 12),

                  // Yearly plan (recommended)
                  _PlanCard(
                    title: AppStrings.yearlyPlan,
                    price: AppStrings.yearlyPrice,
                    subtitle: '(\u6708\u3042\u305F\u308A\u00A5450)',
                    badge: AppStrings.yearlyDiscount,
                    isSelected: sub.selectedPlan == SubscriptionPlan.yearly,
                    isRecommended: true,
                    onTap: () => ref
                        .read(subscriptionProvider.notifier)
                        .selectPlan(SubscriptionPlan.yearly),
                  ),
                  const SizedBox(height: 24),

                  // Purchase button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final notifier =
                            ref.read(subscriptionProvider.notifier);
                        final packageId =
                            sub.selectedPlan == SubscriptionPlan.monthly
                                ? 'monthly'
                                : 'yearly';
                        final success = await notifier.purchaseSubscription(
                          packageId: packageId,
                        );
                        if (success && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        AppStrings.startPremium,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Free trial notice
                  const Center(
                    child: Text(
                      AppStrings.freeTrial,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms and restore
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Open terms
                        },
                        child: const Text(
                          AppStrings.termsOfService,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Text(
                        ' | ',
                        style: TextStyle(color: AppColors.disabledText),
                      ),
                      TextButton(
                        onPressed: () async {
                          final restored = await ref
                              .read(subscriptionProvider.notifier)
                              .restorePurchases();
                          if (!context.mounted) return;
                          if (restored) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('\u8CFC\u5165\u3092\u5FA9\u5143\u3057\u307E\u3057\u305F'),
                              ),
                            );
                            Navigator.of(context).pop(true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('\u5FA9\u5143\u3067\u304D\u308B\u8CFC\u5165\u304C\u898B\u3064\u304B\u308A\u307E\u305B\u3093\u3067\u3057\u305F'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          AppStrings.restore,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (sub.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        sub.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    this.badge,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isRecommended)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                        ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bgPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
