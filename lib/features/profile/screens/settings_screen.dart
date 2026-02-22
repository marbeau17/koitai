import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

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
                activeColor: AppColors.primary,
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
                subtitle: const Text(
                  '08:00',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.disabledText,
                ),
                onTap: () async {
                  await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                  );
                },
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
                    onTap: () {
                      // TODO: Log out
                    },
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
                    onTap: () {
                      // TODO: Account deletion flow
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
