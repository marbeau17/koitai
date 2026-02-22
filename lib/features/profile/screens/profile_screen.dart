import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            AppStrings.tabProfile,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgSecondary,
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: AppColors.primaryLight,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('yyyy/MM/dd').format(profile.birthDate)} \u751F',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u30E9\u30A4\u30D5\u30D1\u30B9: ${profile.lifePathNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to profile edit
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(AppStrings.editProfile),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Subscription section
            const Text(
              AppStrings.subscription,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '\uD83C\uDD93',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.isPremium
                            ? AppStrings.premiumPlan
                            : AppStrings.freePlan,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!profile.isPremium) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '\u30D7\u30EC\u30DF\u30A2\u30E0\u306B\u3059\u308B\u3068\u5168\u6A5F\u80FD\u304C\u4F7F\u3048\u307E\u3059',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.subscription),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '${AppStrings.upgradeToPremium} >',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings section
            const Text(
              AppStrings.settings,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.notificationSettings,
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    label: AppStrings.themeSettings,
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: AppStrings.termsOfService,
                    onTap: () {
                      // TODO: Navigate to terms
                    },
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    label: AppStrings.privacyPolicy,
                    onTap: () {
                      // TODO: Navigate to privacy
                    },
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    label: AppStrings.help,
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.share_outlined,
                    label: AppStrings.shareApp,
                    onTap: () {
                      // TODO: Share app
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                '\u30D0\u30FC\u30B8\u30E7\u30F3 ${AppConfig.appVersion}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.disabledText,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.disabledText,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
