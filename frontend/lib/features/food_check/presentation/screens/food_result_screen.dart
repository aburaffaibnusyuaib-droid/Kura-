import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/service_providers.dart';
import '../controllers/food_check_controller.dart';
import '../widgets/status_badge.dart';
import '../widgets/result_info_card.dart';
import '../widgets/ai_advice_card.dart';

/// Layar Tampilan Hasil Pemeriksaan Komprehensif (Mockup 06, 07, 08, 09, 11).
class FoodResultScreen extends ConsumerWidget {
  const FoodResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodCheckControllerProvider);
    final controller = ref.read(foodCheckControllerProvider.notifier);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background),
        body: const Center(child: Text('Data hasil tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.foodCheck),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary),
            tooltip: 'Simpan ke Riwayat',
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref.read(localStorageServiceProvider).saveFoodCheck(result);
              ref.read(foodCheckHistoryProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hasil pemeriksaan berhasil disimpan ke riwayat!'),
                    backgroundColor: AppColors.electricTeal,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Hero Image Makanan + Floating Status Badge (Mockup 06-11)
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.white,
                      child: _buildFoodImage(result.imagePath),
                    ),
                  ),
                  // Floating Badge
                  Positioned(
                    bottom: -18,
                    child: StatusBadge(status: result.status),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Nama Produk & Kategori
              Text(
                result.productName,
                style: AppTextStyles.displayMedium.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                result.categoryName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Kartu Rincian Informasi (Mockup 06-11)
              ResultInfoCard(result: result),

              const SizedBox(height: 16),

              // Kotak Saran AI
              AiAdviceCard(result: result),

              const SizedBox(height: 28),

              // Tombol Bawah: Simpan & Pindai Lagi
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await ref.read(localStorageServiceProvider).saveFoodCheck(result);
                          ref.read(foodCheckHistoryProvider.notifier).refresh();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hasil berhasil disimpan ke riwayat.'),
                                backgroundColor: AppColors.electricTeal,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.electricTeal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bookmark_border_rounded, size: 18, color: AppColors.electricTeal),
                            const SizedBox(width: 6),
                            Text(
                              'Simpan',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.electricTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.clearCapturedImage();
                          context.push(AppRoutes.foodCheckScan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricTeal,
                          foregroundColor: AppColors.deepMidnightNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pindai Lagi',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Image.asset('assets/images/il_food_check_banner.png', fit: BoxFit.cover);
  }
}
