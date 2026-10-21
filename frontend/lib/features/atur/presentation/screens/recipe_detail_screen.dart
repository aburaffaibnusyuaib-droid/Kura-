// TASK-05: SUBTASK-05D — Recipe Detail Screen (Mockup 08)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';
import '../controllers/atur_controller.dart';
import '../widgets/step_instruction_card.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = ref.watch(aturControllerProvider).selectedRecipe;

    if (recipe == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final accent = Color(recipe.colorHex);

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, recipe.name, accent),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(recipe, accent),
                  const SizedBox(height: 16),
                  _buildDescription(recipe.description),
                  const SizedBox(height: 20),
                  _buildTagsRow(recipe.tags, accent),
                  const SizedBox(height: 24),
                  _buildIngredientsSection(recipe.ingredients, accent),
                  const SizedBox(height: 24),
                  _buildStepsSection(recipe.steps),
                  const SizedBox(height: 32),
                  _buildBackButton(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    String title,
    Color accent,
  ) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: accent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withAlpha(180)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text('🍽️', style: TextStyle(fontSize: 80)),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(Recipe recipe, Color accent) {
    return Row(
      children: [
        _MetaPill(
          icon: Icons.timer_outlined,
          label: '${recipe.durationMinutes} menit',
          accent: accent,
        ),
        const SizedBox(width: 8),
        _MetaPill(
          icon: Icons.signal_cellular_alt_rounded,
          label: recipe.difficulty,
          accent: accent,
        ),
        const SizedBox(width: 8),
        _MetaPill(
          icon: Icons.people_outline_rounded,
          label: '${recipe.servings} porsi',
          accent: accent,
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildTagsRow(List<String> tags, Color accent) {
    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        return Chip(
          label: Text(
            tag,
            style: AppTextStyles.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: accent.withAlpha(20),
          side: BorderSide(color: accent.withAlpha(60)),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsSection(List<String> ingredients, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.kitchen_rounded, color: accent, size: 20),
            const SizedBox(width: 8),
            Text(
              'Bahan-bahan',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...ingredients.map((ing) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ing,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildStepsSection(List<RecipeStep> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_numbered_rounded,
                color: AppColors.primaryTeal, size: 20),
            const SizedBox(width: 8),
            Text(
              'Langkah Memasak',
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          return StepInstructionCard(
            step: entry.value,
            isLast: entry.key == steps.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('Kembali ke Daftar Resep'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryTeal,
        side: BorderSide(color: AppColors.primaryTeal),
        minimumSize: const Size(double.infinity, 48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
