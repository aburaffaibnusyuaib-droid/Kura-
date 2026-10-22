import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';
import '../controllers/atur_controller.dart';
import '../widgets/recipe_ingredient_tile.dart';
import '../widgets/step_instruction_card.dart';

/// Layar Detail Resep Zero-Waste dengan Foto Hidangan Asli & Offline-First Save (Mockup 07).
class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(aturControllerProvider).selectedRecipe;

    if (recipe == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00CBA7)),
        ),
      );
    }

    final isSaved = recipe.isSaved;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header dengan Foto Hidangan Asli & Tombol ─────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF00CBA7),
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            actions: [
              // Tombol Bookmark / Simpan di Atas
              GestureDetector(
                onTap: () async {
                  await _handleSaveRecipe(context, ref, recipe);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSaved
                        ? const Color(0xFF00CBA7)
                        : Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                    Image.network(
                      recipe.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackHero(recipe),
                    )
                  else
                    _buildFallbackHero(recipe),
                  // Gradient Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Konten Detail Resep ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Resep
                  Text(
                    recipe.name,
                    style: AppTextStyles.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tag Kategori
                  Wrap(
                    spacing: 8,
                    children: recipe.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CBA7).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00CBA7).withAlpha(80),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF00CBA7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Baris Metrik (Durasi, Tingkat Kesulitan, Porsi)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailMetric(
                          icon: Icons.timer_outlined,
                          title: 'Waktu',
                          value: '${recipe.durationMinutes} mnt',
                          color: const Color(0xFF00CBA7),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.divider,
                        ),
                        _DetailMetric(
                          icon: Icons.signal_cellular_alt_rounded,
                          title: 'Tingkat',
                          value: recipe.difficulty,
                          color: AppColors.forestGreen,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.divider,
                        ),
                        _DetailMetric(
                          icon: Icons.people_outline_rounded,
                          title: 'Porsi',
                          value: '${recipe.servings} porsi',
                          color: AppColors.sunsetOrange,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.divider,
                        ),
                        _DetailMetric(
                          icon: Icons.local_fire_department_rounded,
                          title: 'Kalori',
                          value: '${recipe.calories} kkal',
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Deskripsi
                  Text(
                    recipe.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Bahan yang Dibutuhkan ──────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CBA7).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.kitchen_rounded,
                          color: Color(0xFF00CBA7),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bahan yang Dibutuhkan',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map(
                    (ing) => RecipeIngredientTile(ingredientText: ing),
                  ),

                  const SizedBox(height: 24),

                  // ── Langkah Memasak ────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CBA7).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.format_list_numbered_rounded,
                          color: Color(0xFF00CBA7),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Langkah Memasak',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...recipe.steps.asMap().entries.map((entry) {
                    return StepInstructionCard(
                      step: entry.value,
                      isLast: entry.key == recipe.steps.length - 1,
                    );
                  }),

                  if (recipe.zeroWasteTip.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CBA7).withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00CBA7).withAlpha(60),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.eco_rounded,
                              color: Color(0xFF00CBA7), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tips Zero Waste',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF00CBA7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  recipe.zeroWasteTip,
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
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Tombol Simpan Resep (Offline-First) ─────────
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _handleSaveRecipe(context, ref, recipe);
                    },
                    icon: Icon(
                      isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      size: 22,
                    ),
                    label: Text(
                      isSaved ? 'Resep Sudah Tersimpan' : 'Simpan Resep ke Favorit',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaved
                          ? AppColors.forestGreen
                          : const Color(0xFF00CBA7),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Kembali
                  OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.divider),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Kembali ke Rekomendasi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveRecipe(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
  ) async {
    HapticFeedback.lightImpact();
    await ref.read(aturControllerProvider.notifier).saveRecipe(recipe);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Resep berhasil disimpan! Siap diakses saat offline.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00CBA7),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildFallbackHero(Recipe recipe) {
    return Container(
      color: const Color(0xFF00CBA7),
      child: Center(
        child: Text(
          recipe.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
