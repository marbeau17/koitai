import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../auth/providers/auth_provider.dart';
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
                    onPressed: () =>
                        _showProfileEditDialog(context, ref, profile),
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
                    onTap: () => _showTermsDialog(context),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    label: AppStrings.privacyPolicy,
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    label: AppStrings.help,
                    onTap: () => _showHelpDialog(context),
                  ),
                  const Divider(
                      height: 1, color: AppColors.border, indent: 56),
                  _SettingsTile(
                    icon: Icons.share_outlined,
                    label: AppStrings.shareApp,
                    onTap: () {
                      Share.share(
                        '\uD83C\uDF19 \u30B3\u30A4\u30BF\u30A4 - \u604B\u306E\u30BF\u30A4\u30DF\u30F3\u30B0\u5360\u3044\n'
                        '\u604B\u306E\u6700\u9AD8\u30BF\u30A4\u30DF\u30F3\u30B0\u304C\u308F\u304B\u308B\u30A2\u30D7\u30EA\n'
                        'https://koitai-prod.web.app\n'
                        '#\u30B3\u30A4\u30BF\u30A4',
                      );
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

  void _showTermsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          AppStrings.termsOfService,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '\u30B3\u30A4\u30BF\u30A4 \u5229\u7528\u898F\u7D04\n\n'
            '1. \u672C\u30B5\u30FC\u30D3\u30B9\u306F\u5A2F\u697D\u76EE\u7684\u306E\u5360\u3044\u30A2\u30D7\u30EA\u3067\u3059\u3002\n\n'
            '2. \u5360\u3044\u7D50\u679C\u306F\u53C2\u8003\u60C5\u5831\u3067\u3042\u308A\u3001\u5B9F\u969B\u306E\u610F\u601D\u6C7A\u5B9A\u306B\u5BFE\u3059\u308B\u8CAC\u4EFB\u306F\u8CA0\u3044\u304B\u306D\u307E\u3059\u3002\n\n'
            '3. \u30E6\u30FC\u30B6\u30FC\u306F13\u6B73\u4EE5\u4E0A\u3067\u3042\u308B\u5FC5\u8981\u304C\u3042\u308A\u307E\u3059\u3002\n\n'
            '4. \u30B5\u30D6\u30B9\u30AF\u30EA\u30D7\u30B7\u30E7\u30F3\u306F\u3044\u3064\u3067\u3082\u89E3\u7D04\u53EF\u80FD\u3067\u3059\u3002\n\n'
            '5. \u30B3\u30F3\u30C6\u30F3\u30C4\u306E\u7121\u65AD\u8907\u88FD\u30FB\u8EE2\u8F09\u3092\u7981\u3058\u307E\u3059\u3002\n\n'
            '\u8A73\u7D30: https://koitai-prod.web.app/terms',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.close,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          AppStrings.privacyPolicy,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '\u30B3\u30A4\u30BF\u30A4 \u30D7\u30E9\u30A4\u30D0\u30B7\u30FC\u30DD\u30EA\u30B7\u30FC\n\n'
            '\u53CE\u96C6\u3059\u308B\u60C5\u5831:\n'
            '\u30FB\u751F\u5E74\u6708\u65E5\uFF08\u5360\u3044\u7B97\u51FA\u306B\u4F7F\u7528\uFF09\n'
            '\u30FB\u6027\u5225\uFF08\u4EFB\u610F\u3001\u7CBE\u5EA6\u5411\u4E0A\u306B\u4F7F\u7528\uFF09\n'
            '\u30FB\u30A2\u30D7\u30EA\u5229\u7528\u30C7\u30FC\u30BF\uFF08\u5206\u6790\u76EE\u7684\uFF09\n\n'
            '\u30C7\u30FC\u30BF\u306E\u4FDD\u7BA1:\n'
            '\u30FB\u5360\u3044\u30C7\u30FC\u30BF\u306F\u7AEF\u672B\u306B\u4FDD\u5B58\u3055\u308C\u307E\u3059\n'
            '\u30FB\u30A2\u30AB\u30A6\u30F3\u30C8\u60C5\u5831\u306FFirebase\u3067\u6697\u53F7\u5316\u4FDD\u5B58\n'
            '\u30FB\u7B2C\u4E09\u8005\u3078\u306E\u500B\u4EBA\u60C5\u5831\u63D0\u4F9B\u306F\u884C\u3044\u307E\u305B\u3093\n\n'
            '\u8A73\u7D30: https://koitai-prod.web.app/privacy',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.close,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          AppStrings.help,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                question: '\u5360\u3044\u306E\u4ED5\u7D44\u307F\u306F\uFF1F',
                answer: '\u6570\u79D8\u8853\u00D7\u6708\u76F8\u00D7\u30D0\u30A4\u30AA\u30EA\u30BA\u30E0\u306E3\u3064\u306E\u8981\u7D20\u3092\u7D44\u307F\u5408\u308F\u305B\u3066\u3001\u604B\u611B\u904B\u3092\u7B97\u51FA\u3057\u3066\u3044\u307E\u3059\u3002',
              ),
              SizedBox(height: 16),
              _HelpItem(
                question: '\u30B5\u30D6\u30B9\u30AF\u30EA\u30D7\u30B7\u30E7\u30F3\u306E\u89E3\u7D04\u306F\uFF1F',
                answer: '\u7AEF\u672B\u306E\u8A2D\u5B9A\u30A2\u30D7\u30EA\u304B\u3089\u3044\u3064\u3067\u3082\u89E3\u7D04\u53EF\u80FD\u3067\u3059\u3002',
              ),
              SizedBox(height: 16),
              _HelpItem(
                question: '\u30C7\u30FC\u30BF\u306F\u5B89\u5168\uFF1F',
                answer: '\u5360\u3044\u30C7\u30FC\u30BF\u306F\u7AEF\u672B\u306B\u4FDD\u5B58\u3055\u308C\u3001\u30A2\u30AB\u30A6\u30F3\u30C8\u60C5\u5831\u306FFirebase\u3067\u6697\u53F7\u5316\u3055\u308C\u3066\u3044\u307E\u3059\u3002',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.close,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a bottom sheet dialog for editing the user's profile.
  void _showProfileEditDialog(
    BuildContext context,
    WidgetRef ref,
    ProfileState profile,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _ProfileEditSheet(
          initialDisplayName: profile.displayName,
          initialBirthDate: profile.birthDate,
        );
      },
    ).then((value) {
      // Handled inside the sheet via Navigator.pop.
    });
  }
}

/// A stateful bottom sheet widget for editing display name and birth date.
class _ProfileEditSheet extends ConsumerStatefulWidget {
  final String initialDisplayName;
  final DateTime initialBirthDate;

  const _ProfileEditSheet({
    required this.initialDisplayName,
    required this.initialBirthDate,
  });

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late TextEditingController _nameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDisplayName);
    _selectedDate = widget.initialBirthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: '\u751F\u5E74\u6708\u65E5\u3092\u9078\u629E', // 生年月日を選択
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    final newName = _nameController.text.trim();

    // Update birth date in auth provider.
    ref.read(authProvider.notifier).setBirthDate(_selectedDate);

    // Persist to Hive.
    await ref.read(authProvider.notifier).saveProfile();

    // Update display name in profile provider.
    if (newName.isNotEmpty) {
      ref.read(profileProvider.notifier).updateDisplayName(newName);
    }

    // Refresh profile to recalculate life path number from new birth date.
    ref.read(profileProvider.notifier).refresh();

    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '\u30D7\u30ED\u30D5\u30A3\u30FC\u30EB\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F', // プロフィールを更新しました
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabledText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '\u30D7\u30ED\u30D5\u30A3\u30FC\u30EB\u7DE8\u96C6', // プロフィール編集
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Display name field
          const Text(
            '\u8868\u793A\u540D', // 表示名
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '\u540D\u524D\u3092\u5165\u529B', // 名前を入力
              hintStyle: const TextStyle(color: AppColors.disabledText),
              filled: true,
              fillColor: AppColors.bgSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Birth date picker
          const Text(
            '\u751F\u5E74\u6708\u65E5', // 生年月日
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy/MM/dd').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '\u4FDD\u5B58\u3059\u308B', // 保存する
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;

  const _HelpItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q. $question',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'A. $answer',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
