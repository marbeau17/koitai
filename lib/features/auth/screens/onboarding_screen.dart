import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Birth date
  int _selectedYear = AppConfig.defaultBirthYear;
  int _selectedMonth = AppConfig.defaultBirthMonth;
  int _selectedDay = AppConfig.defaultBirthDay;

  // Step 2: Gender
  String? _selectedGender;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _currentStep++);
    }
  }

  bool _isBirthDateValid() {
    final now = DateTime.now();
    final birth = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final age = now.year - birth.year -
        ((now.month < birth.month ||
                (now.month == birth.month && now.day < birth.day))
            ? 1
            : 0);
    return age >= AppConfig.minimumAge;
  }

  Future<void> _completeOnboarding() async {
    final birth = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    ref.read(authProvider.notifier).setBirthDate(birth);
    ref.read(authProvider.notifier).setGender(_selectedGender);
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Step indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.onboardingStep} ${_currentStep + 1}/3',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: AppColors.disabledBg,
                      color: AppColors.primary,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBirthDateStep(),
                    _buildGenderStep(),
                    _buildNotificationStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Birth Date ─────────────────────────────────────
  Widget _buildBirthDateStep() {
    final valid = _isBirthDateValid();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.nightlight_round,
            color: AppColors.primaryLight,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.onboardingBirthTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.onboardingBirthSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Date picker (drum roll style)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Year
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedYear - 1950,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedYear = 1950 + index);
                      },
                      children: List.generate(
                        DateTime.now().year - 1950 + 1,
                        (i) => Center(
                          child: Text(
                            '${1950 + i}\u5E74',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Month
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedMonth - 1,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedMonth = index + 1);
                      },
                      children: List.generate(
                        12,
                        (i) => Center(
                          child: Text(
                            '${i + 1}\u6708',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Day
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedDay - 1,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedDay = index + 1);
                      },
                      children: List.generate(
                        31,
                        (i) => Center(
                          child: Text(
                            '${i + 1}\u65E5',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: valid
                  ? () {
                      _nextPage();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    valid ? AppColors.primary : AppColors.disabledBg,
                foregroundColor:
                    valid ? Colors.white : AppColors.disabledText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.next,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Step 2: Gender ─────────────────────────────────────────
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.star_outline_rounded,
            color: AppColors.primaryLight,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.onboardingGenderTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.onboardingGenderSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _GenderOption(
            icon: Icons.male,
            label: AppStrings.genderMale,
            isSelected: _selectedGender == 'male',
            onTap: () => setState(() => _selectedGender = 'male'),
          ),
          const SizedBox(height: 12),
          _GenderOption(
            icon: Icons.female,
            label: AppStrings.genderFemale,
            isSelected: _selectedGender == 'female',
            onTap: () => setState(() => _selectedGender = 'female'),
          ),
          const SizedBox(height: 12),
          _GenderOption(
            icon: Icons.star_outline,
            label: AppStrings.genderOther,
            isSelected: _selectedGender == 'other',
            onTap: () => setState(() => _selectedGender = 'other'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedGender != null ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedGender != null
                    ? AppColors.primary
                    : AppColors.disabledBg,
                foregroundColor: _selectedGender != null
                    ? Colors.white
                    : AppColors.disabledText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.next,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _nextPage,
            child: const Text(
              AppStrings.skip,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Step 3: Notifications ──────────────────────────────────
  Widget _buildNotificationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.gold,
            size: 40,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.onboardingNotifyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.onboardingNotifySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          // Notification preview cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _NotificationPreview(
                  icon: Icons.auto_awesome,
                  title: '\u544A\u767D\u65E5\u548C\u306E\u671D',
                  subtitle: '\u304A\u77E5\u3089\u305B',
                ),
                const Divider(color: AppColors.border),
                _NotificationPreview(
                  icon: Icons.nightlight_round,
                  title: '\u6708\u9F62\u304C\u5909\u308F\u308B',
                  subtitle: '\u30BF\u30A4\u30DF\u30F3\u30B0\u901A\u77E5',
                ),
                const Divider(color: AppColors.border),
                _NotificationPreview(
                  icon: Icons.favorite,
                  title: '\u30DA\u30A2\u76F8\u6027',
                  subtitle: '\u30D9\u30B9\u30C8\u30C7\u30FC\u901A\u77E5',
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).setNotificationEnabled(true);
                // TODO: Request OS notification permission
                _completeOnboarding();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.enableNotifications,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text(
              AppStrings.laterSettings,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationPreview({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
