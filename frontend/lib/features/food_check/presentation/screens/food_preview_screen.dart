import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../controllers/food_check_controller.dart';

/// Layar peninjauan foto hasil jepretan sebelum diproses (Mockup 04).
class FoodPreviewScreen extends ConsumerWidget {
  const FoodPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodCheckControllerProvider);
    final controller = ref.read(foodCheckControllerProvider.notifier);
    final imagePath = state.capturedImagePath;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusDanger),
            tooltip: 'Hapus Foto',
            onPressed: () {
              controller.clearCapturedImage();
              context.pop();
            },
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Pratinjau Gambar Utama
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.white,
                    child: _buildImage(imagePath),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Metadata Gambar (Mockup 04)
              Row(
                children: [
                  const Icon(Icons.image_outlined, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IMG_${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_0942.jpg',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '2.4 MB',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol Tindakan Bawah: Foto Ulang & Gunakan Foto
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.electricTeal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Foto Ulang',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.electricTeal,
                            fontWeight: FontWeight.w700,
                          ),
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
                          context.push(AppRoutes.foodCheckAnalyzing);
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
                          'Gunakan Foto',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null) {
      return Image.asset('assets/images/il_food_check_banner.png', fit: BoxFit.cover);
    }
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
