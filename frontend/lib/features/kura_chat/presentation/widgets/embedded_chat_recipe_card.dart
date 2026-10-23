import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../atur/domain/atur_models.dart';
import '../../../atur/presentation/controllers/atur_controller.dart';

/// Kartu Resep Interaktif yang Disematkan di Dalam Balon Chat (Mockup State 6).
class EmbeddedChatRecipeCard extends ConsumerStatefulWidget {
  const EmbeddedChatRecipeCard({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  ConsumerState<EmbeddedChatRecipeCard> createState() =>
      _EmbeddedChatRecipeCardState();
}

class _EmbeddedChatRecipeCardState
    extends ConsumerState<EmbeddedChatRecipeCard> {
  bool? _isLiked;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isSaved = ref.watch(aturControllerProvider).savedRecipeIds.contains(recipe.id) ||
        recipe.isSaved;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0F2F1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Judul Resep & Badges ─────────────────────────────────
          Text(
            recipe.name,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          Wrap(
            spacing: 6,
            children: (recipe.tags.isNotEmpty ? recipe.tags : ['Sehat', 'Praktis'])
                .take(2)
                .map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00897B),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // ── Foto Masakan ─────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
                    )
                  : _buildFallbackImage(),
            ),
          ),
          const SizedBox(height: 10),

          // ── Metrik Singkat (Waktu & Porsi) ────────────────────────
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: Color(0xFF00897B)),
              const SizedBox(width: 4),
              Text(
                '${recipe.durationMinutes} menit',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepMidnightNavy,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.people_alt_rounded,
                  size: 14, color: AppColors.sunsetOrange),
              const SizedBox(width: 4),
              Text(
                '${recipe.servings} porsi',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepMidnightNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bahan-Bahan Ringkas ───────────────────────────────────
          const Text(
            'Bahan-bahan:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ...recipe.ingredients.take(4).map((ing) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      ing,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // ── Tombol Navigasi ke Detail Resep ──────────────────────
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(aturControllerProvider.notifier).selectRecipe(recipe);
              context.push(AppRoutes.aturRecipeDetail);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FBF9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB2DFDB)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lihat langkah memasak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF00897B),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Action Bar Bawah (Copy, Bookmark, Thumbs) ─────────────
          Row(
            children: [
              // Copy Resep
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(
                    text: '${recipe.name}\n${recipe.description}\nBahan:\n${recipe.ingredients.join("\n")}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resep disalin ke papan klip!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),

              // Simpan Resep
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await ref.read(aturControllerProvider.notifier).saveRecipe(recipe);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resep "${recipe.name}" disimpan ke favorit!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF00CBA7),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 18,
                    color: isSaved ? const Color(0xFF00CBA7) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Thumbs Up
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isLiked = true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _isLiked == true ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                    size: 16,
                    color: _isLiked == true ? const Color(0xFF00CBA7) : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Thumbs Down
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isLiked = false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _isLiked == false ? Icons.thumb_down_rounded : Icons.thumb_down_alt_outlined,
                    size: 16,
                    color: _isLiked == false ? AppColors.sunsetOrange : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFE0F2F1),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: Color(0xFF00897B), size: 36),
      ),
    );
  }
}
