// TASK-05: SUBTASK-05A — Atur Intro Screen (Mockup 01 & 02)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AturIntroScreen extends StatelessWidget {
  const AturIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              _buildBanner(context),
              const SizedBox(height: 24),
              _buildStepsSection(context),
              const SizedBox(height: 24),
              _buildCTA(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atur Makanan',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Zero Waste & Resep Cerdas',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────

  Widget _buildBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.forestGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ilustrasi banner
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 160,
              child: Image.asset(
                'assets/images/il_zero_waste.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            // Teks overlay
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kurangi\nSisa Makanan',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bahan di kulkas → Resep lezat!',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Langkah cara kerja ────────────────────────────────────────

  Widget _buildStepsSection(BuildContext context) {
    const steps = [
      _StepData(
        icon: Icons.camera_alt_rounded,
        title: '1. Foto Bahan',
        subtitle: 'Ambil foto bahan makanan yang ada',
        color: Color(0xFF4DB6AC),
      ),
      _StepData(
        icon: Icons.auto_awesome_rounded,
        title: '2. AI Deteksi',
        subtitle: 'Kura AI mengenali bahan secara otomatis',
        color: Color(0xFF66BB6A),
      ),
      _StepData(
        icon: Icons.tune_rounded,
        title: '3. Edit & Pilih',
        subtitle: 'Sesuaikan daftar bahan sesuai kebutuhan',
        color: Color(0xFFFFB74D),
      ),
      _StepData(
        icon: Icons.restaurant_menu_rounded,
        title: '4. Dapatkan Resep',
        subtitle: '3 resep zero-waste siap disajikan',
        color: Color(0xFFEF5350),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cara Kerja',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: steps.map((s) => _StepCard(data: s)).toList(),
          ),
        ],
      ),
    );
  }

  // ── CTA ───────────────────────────────────────────────────────

  Widget _buildCTA(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => context.push(AppRoutes.aturCamera),
        icon: const Icon(Icons.camera_alt_rounded, size: 20),
        label: const Text('Mulai Sekarang'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}

// ── Helper data class ─────────────────────────────────────────

class _StepData {
  const _StepData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.data});

  final _StepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: data.color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: data.color, size: 24),
          const SizedBox(height: 6),
          Text(
            data.title,
            style: AppTextStyles.labelMedium.copyWith(
              color: data.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
