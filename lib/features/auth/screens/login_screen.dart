import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: auth.isLoading
              ? const Center(child: LoadingIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Logo
                      const Icon(
                        Icons.nightlight_round,
                        size: 64,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.appNameEn,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.appTagline,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(flex: 2),

                      // Google sign in
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authProvider.notifier)
                                .signInWithGoogle();
                            if (context.mounted &&
                                ref.read(authProvider).isAuthenticated) {
                              context.go(AppRoutes.onboarding);
                            }
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text(
                            'Google\u3067\u7D9A\u3051\u308B',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Apple sign in
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(authProvider.notifier)
                                .signInWithApple();
                            if (context.mounted &&
                                ref.read(authProvider).isAuthenticated) {
                              context.go(AppRoutes.onboarding);
                            }
                          },
                          icon: const Icon(Icons.apple, size: 24),
                          label: const Text(
                            'Apple\u3067\u7D9A\u3051\u308B',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (auth.error != null)
                        Text(
                          auth.error!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red.shade300,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const Spacer(),
                      const Text(
                        '\u5229\u7528\u898F\u7D04\u30FB\u30D7\u30E9\u30A4\u30D0\u30B7\u30FC\u30DD\u30EA\u30B7\u30FC\u306B\u540C\u610F\u306E\u4E0A\u3001\u3054\u5229\u7528\u304F\u3060\u3055\u3044',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.disabledText,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
