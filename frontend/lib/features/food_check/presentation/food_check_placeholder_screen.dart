import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Placeholder screen untuk Food Check.
/// Implementasi lengkap akan dibangun di TASK-04.
class FoodCheckPlaceholderScreen extends StatelessWidget {
  const FoodCheckPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Food Check'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.foodCheckCardTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 56,
                    color: AppColors.electricTeal,
                  ),
                ),
                const SizedBox(height: AppConstants.space24),
                Text('Food Check', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'Implementasi lengkap akan hadir di TASK-04.\nCek keamanan makanan dengan AI.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
