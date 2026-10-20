import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/home_demo_data.dart';

/// Tile untuk satu item aktivitas terakhir di Home Screen.
class ActivityItemTile extends StatelessWidget {
  const ActivityItemTile({super.key, required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.cardPadding,
        vertical: AppConstants.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Thumbnail / ikon fitur
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.foodCheckCardTint,
              borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              color: AppColors.electricTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.space12),
          // Nama fitur + deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.featureName, style: AppTextStyles.titleMedium),
                const SizedBox(height: AppConstants.space4),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          // Waktu + chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.timeAgo,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
              const SizedBox(height: AppConstants.space4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
