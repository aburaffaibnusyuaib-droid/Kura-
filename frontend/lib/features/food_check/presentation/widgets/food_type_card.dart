import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/food_check_models.dart';

/// Kartu pemilihan jenis makanan (Makanan Kemasan / Makanan Segar).
class FoodTypeCard extends StatelessWidget {
  const FoodTypeCard({
    super.key,
    required this.foodType,
    required this.imageAsset,
    required this.isSelected,
    required this.onTap,
  });

  final FoodType foodType;
  final String imageAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: isSelected ? AppColors.electricTeal : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ilustrasi jenis makanan
                Center(
                  child: Container(
                    height: 85,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.lunch_dining_rounded,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  foodType.label,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  foodType.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
