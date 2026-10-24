import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/kura_global_app_bar.dart';
import '../data/home_demo_data.dart';
import 'widgets/home_header.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/section_header.dart';
import 'widgets/activity_item_tile.dart';

/// Home Screen utama Kura AI.
///
/// Menampilkan:
/// - App bar dengan logo Kura dan ikon profil
/// - Header salam dengan maskot
/// - Kartu Tips Hari Ini (data [DEMO])
/// - Section Fitur Utama: Food Check, Zero Waste Food, Kura AI (placeholder)
/// - Section Aktivitas Terakhir (data [DEMO])
///
/// Menggunakan [HomeDemoRepository] untuk data demo yang terlabel jelas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const KuraGlobalAppBar(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header salam + maskot ────────────────────────────────────
            const SliverToBoxAdapter(child: HomeHeader()),

            // ─── Tips Hari Ini ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: DailyTipCard(
                tipText: HomeDemoRepository.dailyTip.text,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.sectionSpacing),
            ),

            // ─── Section: Fitur Utama ─────────────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Fitur Utama',
                onActionTap: () {}, // placeholder
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space16),
            ),

            // Kartu Food Check
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Food Check',
                  description:
                      'Cek keamanan makanan dengan AI, barcode, dan inspeksi visual.',
                  buttonLabel: 'Periksa Sekarang',
                  imagePath: 'assets/images/il_food_check.png',
                  backgroundColor: AppColors.foodCheckCardTint,
                  buttonColor: AppColors.electricTeal,
                  onTap: () => context.go(AppRoutes.foodCheck),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space12),
            ),

            // Kartu Zero Waste Food (Atur)
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Zero Waste Food',
                  description:
                      'Ubah bahan yang tersisa menjadi resep lezat dan bermanfaat.',
                  buttonLabel: 'Cari Resep',
                  imagePath: 'assets/images/il_zero_waste.png',
                  backgroundColor: AppColors.aturCardTint,
                  buttonColor: AppColors.sunsetOrange,
                  onTap: () => context.go(AppRoutes.atur),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space12),
            ),

            // Kartu Kura AI
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Kura AI',
                  description:
                      'Tanya seputar kesehatan, gizi, dan tips makanan langsung ke Kura AI.',
                  buttonLabel: 'Mulai Chat',
                  imagePath: 'assets/images/mascot_home.png',
                  backgroundColor: AppColors.kuraAiCardTint,
                  buttonColor: AppColors.kuraAiButtonColor,
                  onTap: () => context.go(AppRoutes.kuraChat),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.sectionSpacing),
            ),

            // ─── Section: Aktivitas Terakhir ──────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Aktivitas Terakhir',
                onActionTap: () {}, // placeholder
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space16),
            ),

            // [DEMO] Daftar aktivitas — bukan riwayat nyata
            if (HomeDemoRepository.recentActivities.isEmpty)
              const SliverToBoxAdapter(child: _EmptyActivityState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = HomeDemoRepository.recentActivities[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.space8,
                      ),
                      child: ActivityItemTile(item: item),
                    );
                  },
                  childCount: HomeDemoRepository.recentActivities.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space32),
            ),
          ],
        ),
      ),
    );
  }
}

/// State kosong saat belum ada aktivitas terakhir.
class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.space32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_rounded,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            'Belum ada aktivitas',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            'Mulai gunakan Food Check atau Zero Waste Food!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
