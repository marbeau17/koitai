import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/analytics_service.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final sub = ref.watch(subscriptionProvider);

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
            AppStrings.settings,
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
            // Dark mode toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  '\u30C0\u30FC\u30AF\u30E2\u30FC\u30C9',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                secondary: const Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.textSecondary,
                ),
                value: profile.isDarkMode,
                onChanged: (_) =>
                    ref.read(profileProvider.notifier).toggleTheme(),
                activeThumbColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Notification toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  '\u901A\u77E5',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  profile.notificationEnabled
                      ? '\u6BCE\u65E5 ${_formatTime(profile.notificationTime)} \u306B\u901A\u77E5'
                      : '\u30AA\u30D5',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
                value: profile.notificationEnabled,
                onChanged: (enabled) {
                  ref
                      .read(profileProvider.notifier)
                      .setNotificationEnabled(enabled);
                  final time = _formatTime(profile.notificationTime);
                  AnalyticsService().logSetNotification(enabled, time);
                },
                activeThumbColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Notification time setting
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.access_time,
                  color: AppColors.textSecondary,
                ),
                title: const Text(
                  '\u901A\u77E5\u6642\u523B',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _formatTime(profile.notificationTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.disabledText,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: profile.notificationTime,
                  );
                  if (picked != null) {
                    ref
                        .read(profileProvider.notifier)
                        .setNotificationTime(picked);
                    if (profile.notificationEnabled) {
                      AnalyticsService().logSetNotification(
                        true,
                        _formatTime(picked),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Restore purchases (Apple App Store review requirement)
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.restore,
                  color: AppColors.textSecondary,
                ),
                title: const Text(
                  '\u8CFC\u5165\u3092\u5FA9\u5143', // 購入を復元
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  '\u4EE5\u524D\u306E\u8CFC\u5165\u3092\u5FA9\u5143\u3057\u307E\u3059', // 以前の購入を復元します
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: sub.isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.chevron_right,
                        color: AppColors.disabledText,
                      ),
                onTap: sub.isRestoring
                    ? null
                    : () => _handleRestorePurchases(context, ref),
              ),
            ),
            const SizedBox(height: 12),

            // Account management
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                    ),
                    title: const Text(
                      '\u30ED\u30B0\u30A2\u30A6\u30C8',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onTap: () => _handleLogout(context, ref),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade300,
                    ),
                    title: Text(
                      '\u30A2\u30AB\u30A6\u30F3\u30C8\u524A\u9664',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red.shade300,
                      ),
                    ),
                    subtitle: Text(
                      '\u3059\u3079\u3066\u306E\u30C7\u30FC\u30BF\u304C\u524A\u9664\u3055\u308C\u307E\u3059', // すべてのデータが削除されます
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade300.withValues(alpha: 0.7),
                      ),
                    ),
                    onTap: () => _showDeleteAccountDialog(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRestorePurchases(
      BuildContext context, WidgetRef ref) async {
    final restored =
        await ref.read(subscriptionProvider.notifier).restorePurchases();
    if (!context.mounted) return;
    if (restored) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u8CFC\u5165\u3092\u5FA9\u5143\u3057\u307E\u3057\u305F')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('\u5FA9\u5143\u3067\u304D\u308B\u8CFC\u5165\u304C\u898B\u3064\u304B\u308A\u307E\u305B\u3093\u3067\u3057\u305F')),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).signOut();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  /// Show confirmation dialog before account deletion.
  Future<void> _showDeleteAccountDialog(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '\u30A2\u30AB\u30A6\u30F3\u30C8\u524A\u9664', // アカウント削除
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade300,
          ),
        ),
        content: const Text(
          '\u30A2\u30AB\u30A6\u30F3\u30C8\u3092\u524A\u9664\u3059\u308B\u3068\u3001\u3059\u3079\u3066\u306E\u30C7\u30FC\u30BF\u304C\u5B8C\u5168\u306B\u524A\u9664\u3055\u308C\u307E\u3059\u3002\u3053\u306E\u64CD\u4F5C\u306F\u53D6\u308A\u6D88\u3059\u3053\u3068\u304C\u3067\u304D\u307E\u305B\u3093\u3002\n\n\u672C\u5F53\u306B\u524A\u9664\u3057\u307E\u3059\u304B\uFF1F',
          // アカウントを削除すると、すべてのデータが完全に削除されます。この操作は取り消すことができません。\n\n本当に削除しますか？
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade300,
            ),
            child: const Text(
              '\u524A\u9664\u3059\u308B', // 削除する
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await _deleteAccount(context, ref);
  }

  /// Perform the actual account deletion.
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Delete Firebase user account
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      if (e.code == 'requires-recent-login') {
        // The user needs to re-authenticate before deletion.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '\u30BB\u30AD\u30E5\u30EA\u30C6\u30A3\u306E\u305F\u3081\u3001\u518D\u30ED\u30B0\u30A4\u30F3\u304C\u5FC5\u8981\u3067\u3059\u3002\u30ED\u30B0\u30A2\u30A6\u30C8\u5F8C\u3001\u518D\u5EA6\u30ED\u30B0\u30A4\u30F3\u3057\u3066\u304B\u3089\u524A\u9664\u3057\u3066\u304F\u3060\u3055\u3044\u3002',
              // セキュリティのため、再ログインが必要です。ログアウト後、再度ログインしてから削除してください。
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '\u30A2\u30AB\u30A6\u30F3\u30C8\u524A\u9664\u306B\u5931\u6557\u3057\u307E\u3057\u305F: ${e.message}',
            // アカウント削除に失敗しました: ...
          ),
        ),
      );
      return;
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '\u30A2\u30AB\u30A6\u30F3\u30C8\u524A\u9664\u306B\u5931\u6557\u3057\u307E\u3057\u305F',
            // アカウント削除に失敗しました
          ),
        ),
      );
      return;
    }

    // 2. Clear all local Hive boxes
    try {
      await _clearHiveBoxes();
    } catch (_) {
      // Best-effort cleanup; proceed even if clearing fails.
    }

    // 3. Sign out (clears auth state)
    await ref.read(authProvider.notifier).signOut();

    // 4. Navigate to login screen
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  /// Clear all application Hive boxes.
  Future<void> _clearHiveBoxes() async {
    final boxNames = [
      AppConfig.hiveBoxFortune,
      AppConfig.hiveBoxProfile,
      AppConfig.hiveBoxPair,
      AppConfig.hiveBoxSettings,
    ];

    for (final name in boxNames) {
      try {
        if (Hive.isBoxOpen(name)) {
          final box = Hive.box<dynamic>(name);
          await box.clear();
        }
      } catch (_) {
        // Ignore individual box errors during cleanup.
      }
    }
  }

  /// Format a [TimeOfDay] as HH:mm.
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
