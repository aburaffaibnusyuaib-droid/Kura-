// TASK-05: SUBTASK-05D — Recipe Recommendations Screen (Mockup 07)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../widgets/recipe_card.dart';

class RecipeRecommendationsScreen extends ConsumerWidget {
  const RecipeRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aturControllerProvider);
    final recipes = state.recipes;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, state.selectedIngredients.length),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDemoNote(),
                    const SizedBox(height: 16),
                    _buildSubtitle(recipes.length),
                    const SizedBox(height: 12),
                    if (recipes.isEmpty)
                      _buildLoadingState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipes.length,
                        itemBuilder: (ctx, i) => RecipeCard(
                          recipe: recipes[i],
                          index: i,
                          onTap: () {
                            ref
                                .read(aturControllerProvider.notifier)
                                .selectRecipe(recipes[i]);
                            context.push(AppRoutes.aturRecipeDetail);
                          },
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

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    int ingredientCount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Resep',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Dari $ingredientCount bahan pilihanmu',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primaryTeal),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.eco_rounded,
                    color: AppColors.primaryTeal, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Zero Waste',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, color: Color(0xFF388E3C), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '[DEMO] Resep bersifat simulasi — bukan hasil AI live.',
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xFF388E3C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(int count) {
    return Row(
      children: [
        Text(
          'Ditemukan ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '$count resep',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          ' untukmu',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
