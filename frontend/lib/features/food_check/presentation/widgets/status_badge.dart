import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/food_check_models.dart';

/// Badge status melayang untuk hasil analisis Food Check (Mockup 06-11).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final FoodCheckStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, icon) = switch (status) {
      FoodCheckStatus.looksOk => (
          AppColors.statusSafe,
          AppColors.white,
          Icons.verified_user_rounded,
        ),
      FoodCheckStatus.checkFurther => (
          const Color(0xFFFBBF24),
          AppColors.deepMidnightNavy,
          Icons.error_outline_rounded,
        ),
      FoodCheckStatus.avoidEating => (
          AppColors.statusDanger,
          AppColors.white,
          Icons.dangerous_rounded,
        ),
      FoodCheckStatus.unableToAssess => (
          const Color(0xFFF59E0B),
          AppColors.deepMidnightNavy,
          Icons.help_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: AppTextStyles.labelLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
