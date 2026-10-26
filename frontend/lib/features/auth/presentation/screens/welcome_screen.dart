import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

/// Layar Welcome / Landing Autentikasi Kura AI (Screen 1)
/// Responsif untuk Infinix Hot 30i (720x1612, 20:9) dengan Zero RenderFlex Overflow.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = MediaQuery.of(context).size.width > 600;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 20.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(0, double.infinity),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),

                    // ── Ilustrasi Maskot Welcome ───────────────────────────
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 180,
                          maxWidth: 180,
                        ),
                        child: Image.asset(
                          'assets/images/mascot_auth_welcome.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.eco_rounded,
                            size: 90,
                            color: Color(0xFF00B4A0),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Headline & Subtitle ────────────────────────────────
                    Text(
                      'Mulai Hidup Sehat\n& Anti-Mubazir',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: AppColors.deepMidnightNavy,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Teman setia mengelola makanan cerdas di dapurmu.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Tombol Utama: Masuk dengan Email ────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push(AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4A0),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0x3300B4A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Masuk dengan Email',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Tombol Sekunder: Daftar Akun Baru ───────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push(AppRoutes.register);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00B4A0),
                          side: const BorderSide(
                            color: Color(0xFF00B4A0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Daftar Akun Baru',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: const Color(0xFF00B4A0),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tombol Tamu: Eksplorasi Dulu ────────────────────────
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              HapticFeedback.lightImpact();
                              await authNotifier.continueAsGuest();
                              if (context.mounted) {
                                context.go(AppRoutes.home);
                              }
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        'Eksplorasi Dulu (Lanjut sebagai Tamu)',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
