import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Banner interaktif utama Food Check (Mockup 01 & 02).
class FoodCheckBanner extends StatelessWidget {
  const FoodCheckBanner({super.key, required this.onStartTap});

  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.foodCheckCardTint,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.electricTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Ilustrasi Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/il_food_check_banner.png',
                height: 140,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: AppColors.white,
                  child: const Icon(
                    Icons.fastfood_rounded,
                    size: 64,
                    color: AppColors.electricTeal,
                  ),
                ),
              ),
            ),
          ),
          // Tombol Mulai Pemeriksaan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onStartTap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricTeal,
                  foregroundColor: AppColors.deepMidnightNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Mulai Pemeriksaan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
