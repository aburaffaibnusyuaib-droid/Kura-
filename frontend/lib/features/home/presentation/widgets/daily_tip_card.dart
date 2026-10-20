import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Kartu Tips Hari Ini yang menampilkan satu tip makanan harian.
class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key, required this.tipText});

  final String tipText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon lampu
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0x2600F0A8), // teal ~15% opacity
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.electricTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.space12),
          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Hari Ini',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  tipText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.space8),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.electricTeal,
            size: 20,
          ),
        ],
      ),
    );
  }
}
