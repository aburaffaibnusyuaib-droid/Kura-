import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../widgets/recipe_card.dart';

/// Layar Daftar Rekomendasi Resep Zero-Waste Padat & Proporsional (Zero Dead Space).
class RecipeRecommendationsScreen extends ConsumerWidget {
  const RecipeRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aturControllerProvider);
    final recipes = state.recipes;
    final selectedIngredients = state.selectedIngredients;
    final selectedCount = selectedIngredients.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header Navigation ─────────────────────────────
            _buildHeader(context, selectedCount),

            // ── Main Content Scrollable ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ringkasan Bahan di Bagian Atas ────────────────────
                    if (selectedIngredients.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.kitchen_rounded,
                            size: 15,
                            color: Color(0xFF00897B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Bahan yang Digunakan ($selectedCount):',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: selectedIngredients.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final ing = selectedIngredients[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F7F5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF00CBA7).withAlpha(80),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: Color(0xFF00897B),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${ing.name} (${ing.quantity})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF004D40),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Subtitle & Badge
                    Row(
                      children: [
                        Text(
                          'Ditemukan ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${recipes.length} Resep Terpilih',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color(0xFF00CBA7),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00CBA7).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                color: Color(0xFF00CBA7),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Zero Waste',
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(0xFF00CBA7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Daftar Kartu Resep Interaktif
                    if (recipes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(48),
                          child: CircularProgressIndicator(
                            color: Color(0xFF00CBA7),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            index: index,
                            onTap: () {
                              ref
                                  .read(aturControllerProvider.notifier)
                                  .selectRecipe(recipe);
                              context.push(AppRoutes.aturRecipeDetail);
                            },
                            onBookmarkTap: () async {
                              await ref
                                  .read(aturControllerProvider.notifier)
                                  .saveRecipe(recipe);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Resep "${recipe.name}" berhasil disimpan ke riwayat!',
                                    ),
                                    backgroundColor: const Color(0xFF00CBA7),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),

                    // ── Banner Edukatif Bawah: Zero-Waste Secret Kura ──
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE6F7F5), Color(0xFFF0FDF4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF00CBA7).withAlpha(60),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00CBA7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.lightbulb_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Zero-Waste Secret Kura',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: Color(0xFF004D40),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kulit sayuran seperti wortel dan kentang serta batang herba kaya akan serat dan vitamin! '
                                  'Cuci bersih lalu iris untuk tumisan gurih, atau simpan di freezer untuk rebusan kaldu alami homemade tanpa sampah dapur.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.deepMidnightNavy,
                                    height: 1.4,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int ingredientCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Resep',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Dari $ingredientCount bahan pilihanmu',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF00CBA7),
                    fontWeight: FontWeight.w600,
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
