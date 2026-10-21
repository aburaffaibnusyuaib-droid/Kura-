import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/food_check_models.dart';
import '../controllers/food_check_controller.dart';
import '../widgets/food_check_banner.dart';
import '../widgets/food_type_card.dart';
import '../widgets/demo_scenario_sheet.dart';

/// Halaman Hub Utama Food Check (Mockup 01 & 02).
class FoodCheckHomeScreen extends ConsumerWidget {
  const FoodCheckHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodCheckControllerProvider);
    final controller = ref.read(foodCheckControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  AppConstants.space16,
                  AppConstants.space8,
                  AppConstants.space16,
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
                    // Tombol Simulasi Demo (Pengujian 14 Mockup)
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
                    // Icon Profil
                    IconButton(
                      icon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                      tooltip: 'Profil',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Judul & Deskripsi Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Food Check', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Periksa keamanan makanan dengan AI, barcode, dan inspeksi visual.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.space24)),

            // Banner Interaktif Mulai Pemeriksaan (Mockup 01)
            SliverToBoxAdapter(
              child: FoodCheckBanner(
                onStartTap: () => context.push(AppRoutes.foodCheckScan),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.space24)),

            // Section: Pilih Jenis Makanan
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Text('Pilih Jenis Makanan', style: AppTextStyles.headlineLarge),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.space12)),

            // Dua Kartu Jenis Makanan (Makanan Kemasan & Makanan Segar)
            SliverToBoxAdapter(
              child: Padding(
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.space32)),
          ],
        ),
      ),
    );
  }
}
