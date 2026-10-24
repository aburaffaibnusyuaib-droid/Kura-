import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/kura_global_app_bar.dart';
import '../widgets/atur_workflow_stepper_card.dart';

/// Halaman Intro / Hub Atur Makanan (Mockup 01 Refactored).
class AturIntroScreen extends StatelessWidget {
  const AturIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KuraGlobalAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.space16),

              // ── Judul & Tagline Atur ────────────────────────────
              Text(
                'Atur Makanan',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Ubah sisa bahan makanan di kulkas menjadi hidangan lezat zero-waste.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: AppConstants.space20),

              // ── Banner Ilustrasi Zero Waste ─────────────────────
              _buildIllustrationBanner(),

              const SizedBox(height: AppConstants.space16),

              // ── Tombol CTA Utama Tepat di Bawah Banner ──────────
              _buildMainCTAButton(context),

              const SizedBox(height: AppConstants.space24),

              // ── Kartu Cara Kerja Tunggal (Single Container) ────
              const AturWorkflowStepperCard(),

              const SizedBox(height: AppConstants.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationBanner() {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC8F5E9),
            Color(0xFFE2F9F2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Tagline Kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricTeal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ZERO WASTE',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          color: AppColors.deepMidnightNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kurangi\nSisa Pangan',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.deepMidnightNavy,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bahan di kulkas siap diolah!',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ilustrasi Kanan
              Image.asset(
                'assets/images/il_zero_waste.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCTAButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        context.push(AppRoutes.aturCamera);
      },
      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
      label: Text(
        'Mulai Sekarang',
        style: AppTextStyles.labelLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00CBA7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 54),
        elevation: 3,
        shadowColor: const Color(0x4000CBA7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
