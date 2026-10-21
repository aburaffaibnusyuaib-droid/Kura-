import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/food_check_models.dart';

/// Kartu rincian informasi makanan pada hasil pemeriksaan (Mockup 06-11).
class ResultInfoCard extends StatelessWidget {
  const ResultInfoCard({super.key, required this.result});

  final FoodCheckResult result;

  @override
  Widget build(BuildContext context) {
    if (result.foodType == FoodType.packaged) {
      return Column(
        children: [
          // Kartu Tanggal Kedaluwarsa
          if (result.expiryDate != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.foodCheckCardTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.electricTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal Kedaluwarsa',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.expiryDate!,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Kartu Informasi Produk
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Produk',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (result.barcode != null) ...[
                  _buildRow('Barcode', result.barcode!),
                  const SizedBox(height: 8),
                ],
                if (result.packagingCondition != null) ...[
                  _buildPackagingConditionRow(result.packagingCondition!),
                  const SizedBox(height: 8),
                ],
                if (result.composition != null) ...[
                  const Text('Komposisi', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    result.composition!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Kartu Hasil Pemeriksaan Makanan Segar
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Pemeriksaan',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (result.visualCondition != null) ...[
            _buildRow('Kondisi Visual', result.visualCondition!),
            const Divider(height: 16),
          ],
          if (result.texture != null) ...[
            _buildRow('Tekstur', result.texture!),
            const Divider(height: 16),
          ],
          if (result.aroma != null) ...[
            _buildRow('Aroma', result.aroma!),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackagingConditionRow(String condition) {
    final color = switch (condition.toLowerCase()) {
      'baik' => AppColors.statusSafe,
      'sedikit penyok' => AppColors.statusWarning,
      _ => AppColors.statusDanger,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Kondisi Kemasan',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          condition,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
