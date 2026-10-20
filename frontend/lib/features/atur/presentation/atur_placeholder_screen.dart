import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// Placeholder screen untuk Atur / Zero Waste Food.
/// Implementasi lengkap akan dibangun di TASK-05.
class AturPlaceholderScreen extends StatelessWidget {
  const AturPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Zero Waste Food'),
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
                    color: AppColors.aturCardTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 56,
                    color: AppColors.sunsetOrange,
                  ),
                ),
                const SizedBox(height: AppConstants.space24),
                Text('Zero Waste Food', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'Implementasi lengkap akan hadir di TASK-05.\nUbah sisa bahan menjadi resep lezat.',
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
