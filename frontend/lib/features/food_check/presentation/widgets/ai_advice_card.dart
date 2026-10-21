import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/food_check_models.dart';

/// Kotak saran dan catatan dari evaluasi AI (Mockup 06-11).
class AiAdviceCard extends StatelessWidget {
  const AiAdviceCard({super.key, required this.result});

  final FoodCheckResult result;

  @override
  Widget build(BuildContext context) {
    final (tintColor, iconColor, icon) = switch (result.status) {
      FoodCheckStatus.looksOk => (
          AppColors.statusSafeBg,
          AppColors.statusSafe,
          Icons.check_circle_outline_rounded,
        ),
      FoodCheckStatus.checkFurther || FoodCheckStatus.unableToAssess => (
          AppColors.statusWarningBg,
          AppColors.statusWarning,
          Icons.warning_amber_rounded,
        ),
      FoodCheckStatus.avoidEating => (
          AppColors.statusDangerBg,
          AppColors.statusDanger,
          Icons.error_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.status == FoodCheckStatus.unableToAssess) ...[
                  Text(
                    'Saran',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  result.aiAdvice,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
