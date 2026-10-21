// TASK-05: Atur Widget — Recipe Card

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';

/// Kartu resep pada halaman daftar rekomendasi.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.index = 0,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accent = Color(recipe.colorHex);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header berwarna ──────────────────────────────
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    _recipeEmoji(index),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              // ── Konten ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.timer_outlined,
                          label: '${recipe.durationMinutes} mnt',
                          color: AppColors.primaryTeal,
                        ),
                        const SizedBox(width: 8),
                        _InfoPill(
                          icon: Icons.signal_cellular_alt_rounded,
                          label: recipe.difficulty,
                          color: AppColors.forestGreen,
                        ),
                        const SizedBox(width: 8),
                        _InfoPill(
                          icon: Icons.people_outline_rounded,
                          label: '${recipe.servings} porsi',
                          color: AppColors.primaryTeal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: recipe.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: AppColors.primaryTeal.withAlpha(20),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _recipeEmoji(int i) {
    const emojis = ['🥗', '🥘', '🍲'];
    return emojis[i % emojis.length];
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
