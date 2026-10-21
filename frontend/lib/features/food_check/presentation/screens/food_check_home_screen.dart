import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/food_check_models.dart';
import '../controllers/food_check_controller.dart';
import '../widgets/demo_scenario_sheet.dart';
import '../widgets/food_check_banner.dart';
import '../widgets/food_check_guides_section.dart';
import '../widgets/food_type_card.dart';
import '../widgets/recent_scans_section.dart';

/// Halaman Hub Utama Food Check (Refactored & Polished).
class FoodCheckHomeScreen extends ConsumerWidget {
  const FoodCheckHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodCheckControllerProvider);
    final controller = ref.read(foodCheckControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  AppConstants.space16,
                  AppConstants.space8,
                  AppConstants.space8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.electricTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.deepMidnightNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Text('Kura AI', style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    // Tombol Simulasi Demo (Skenario)
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppColors.electricTeal),
                      tooltip: 'Pilih Skenario Demo',
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => DemoScenarioSheet(
                            currentScenario: state.selectedScenario,
                            isOffline: state.isOffline,
                            onSelectScenario: (scen) {
                              controller.setScenario(scen);
                              Navigator.pop(ctx);
                            },
                            onToggleOffline: (off) {
                              controller.setOfflineState(off);
                            },
                          ),
                        );
                      },
                    ),
                    // Avatar Profil
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.electricTeal.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.deepMidnightNavy,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Title & Subtitle ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food Check', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Periksa keamanan makanan dengan AI & inspeksi visual.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.space16),

              // ── Banner Utama Mulai Pemeriksaan ─────────────────
              FoodCheckBanner(
                onStartTap: () => context.push(AppRoutes.foodCheckScan),
              ),

              const SizedBox(height: AppConstants.space20),

              // ── Section: Pilih Jenis Makanan ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Text('Pilih Jenis Makanan', style: AppTextStyles.headlineLarge),
              ),
              const SizedBox(height: AppConstants.space12),

              // Dua Kartu Kategori Sejajar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FoodTypeCard(
                      foodType: FoodType.packaged,
                      imageAsset: 'assets/images/il_packaged_food.png',
                      isSelected: state.selectedFoodType == FoodType.packaged,
                      onTap: () {
                        controller.selectFoodType(FoodType.packaged);
                        context.push(AppRoutes.foodCheckScan);
                      },
                    ),
                    const SizedBox(width: 12),
                    FoodTypeCard(
                      foodType: FoodType.fresh,
                      imageAsset: 'assets/images/il_fresh_food.png',
                      isSelected: state.selectedFoodType == FoodType.fresh,
                      onTap: () {
                        controller.selectFoodType(FoodType.fresh);
                        context.push(AppRoutes.foodCheckScan);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.space24),

              // ── Section: Riwayat Cek Terakhir ──────────────────
              const RecentScansSection(),

              const SizedBox(height: AppConstants.space24),

              // ── Section: Panduan Cepat Kura AI ─────────────────
              const FoodCheckGuidesSection(),

              const SizedBox(height: AppConstants.space32),
            ],
          ),
        ),
      ),
    );
  }
}
