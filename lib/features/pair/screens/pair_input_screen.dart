import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/pair_provider.dart';

class PairInputScreen extends ConsumerStatefulWidget {
  const PairInputScreen({super.key});

  @override
  ConsumerState<PairInputScreen> createState() => _PairInputScreenState();
}

class _PairInputScreenState extends ConsumerState<PairInputScreen> {
  final _nicknameController = TextEditingController();
  DateTime _partnerBirth = DateTime(2000, 1, 1);

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickPartnerBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _partnerBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ja'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _partnerBirth = picked);
      ref.read(pairProvider.notifier).setPartnerBirthDate(picked);
    }
  }

  Future<void> _calculate() async {
    ref.read(pairProvider.notifier).setPartnerBirthDate(_partnerBirth);
    ref
        .read(pairProvider.notifier)
        .setPartnerNickname(_nicknameController.text);
    await ref.read(pairProvider.notifier).calculatePairFortune();
    if (mounted) {
      context.push(AppRoutes.pairResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pair = ref.watch(pairProvider);
    final authState = ref.watch(authProvider);
    final myBirthDate = authState.birthDate ?? DateTime(1995, 6, 15);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            AppStrings.tabPair,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: pair.isCalculating
            ? const Center(
                child: LoadingIndicator(
                  message: '\u5360\u3044\u4E2D...',
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Title
                  const Center(
                    child: Text(
                      '2\u4EBA\u306E\u6700\u9AD8\u30BF\u30A4\u30DF\u30F3\u30B0\u3092\n\u898B\u3064\u3051\u307E\u3057\u3087\u3046',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Your info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.pairYou,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy/MM/dd').format(myBirthDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Text(
                          '(\u81EA\u52D5\u5165\u529B)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.disabledText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hearts divider
                  const Center(
                    child: Text(
                      '\u2661 \u00D7 \u2661',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Partner info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.pairPartner,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickPartnerBirthDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              DateFormat('yyyy/MM/dd').format(_partnerBirth),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nickname field
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _nicknameController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: AppStrings.pairNickname,
                        hintStyle:
                            const TextStyle(color: AppColors.disabledText),
                        filled: true,
                        fillColor: AppColors.bgSecondary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '${AppStrings.pairCta} \u2764',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // History section
                  const Text(
                    AppStrings.pairHistory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(color: AppColors.border),
                  ...pair.history.map((entry) => _HistoryTile(entry: entry)),
                ],
              ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final PairHistoryEntry entry;

  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        entry.nickname,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${DateFormat('M/d').format(entry.readingDate)}\u5360\u3044',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: TextButton(
        onPressed: () {
          // TODO: Re-calculate with this partner
        },
        child: const Text(
          '\u518D\u5360\u3044',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
