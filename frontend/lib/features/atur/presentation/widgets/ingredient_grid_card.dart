import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';
import 'cropped_ingredient_image.dart';

/// Kartu Grid Bahan Makanan dengan Potongan Foto Asli Kamera (On-Device Cropper) & Checkbox Toska.
class IngredientGridCard extends StatelessWidget {
  const IngredientGridCard({
    super.key,
    required this.ingredient,
    required this.onToggle,
    this.originalImage,
    this.originalImagePath,
    this.onRemove,
  });

  final DetectedIngredient ingredient;
  final VoidCallback onToggle;
  final Uint8List? originalImage;
  final String? originalImagePath;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isSelected = ingredient.isSelected;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 3 : 1,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00CBA7) : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Bagian Atas: Foto Bahan + Checkbox Floating ───
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    // Foto Bahan Asli Kamera (On-Device Cropped Image)
                    Positioned.fill(
                      child: CroppedIngredientImage(
                        originalImage: originalImage,
                        originalImagePath: originalImagePath,
                        box2d: ingredient.box2d,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        fallback: Image.asset(
                          'assets/images/placeholder_ingredients.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFE6F7F5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ingredient.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      ingredient.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: const Color(0xFF00B4A0),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Checkbox Toska Interaktif di Pojok Kanan Atas
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00CBA7)
                              : Colors.white.withAlpha(220),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00CBA7)
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Bagian Bawah: Informasi Nama & Kuantitas ───────
              Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ingredient.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jumlah: ${ingredient.quantity}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
