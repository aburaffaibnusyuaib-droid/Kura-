import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';

/// Kartu Grid Bahan Makanan dengan Foto Asli & Checkbox Toska (Mockup 09).
class IngredientGridCard extends StatelessWidget {
  const IngredientGridCard({
    super.key,
    required this.ingredient,
    required this.onToggle,
    this.onRemove,
  });

  final DetectedIngredient ingredient;
  final VoidCallback onToggle;
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
                    // Foto Bahan Asli
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                        child: ingredient.imageUrl != null &&
                                ingredient.imageUrl!.isNotEmpty
                            ? Image.network(
                                ingredient.imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: const Color(0xFFF2F4F7),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF00CBA7),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildFallbackImage(),
                              )
                            : _buildFallbackImage(),
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

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFE8FDF6),
      child: Center(
        child: Text(
          ingredient.emoji,
          style: const TextStyle(fontSize: 42),
        ),
      ),
    );
  }
}
