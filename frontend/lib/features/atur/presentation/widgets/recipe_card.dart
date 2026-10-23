import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/atur_models.dart';

/// Kartu Rekomendasi Resep Padat & Proporsional (Rasio 16:9) dengan Floating Badges,
/// Baris Metrik Lengkap, dan Tombol Bookmark Aksi Cepat.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onBookmarkTap,
    this.index = 0,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Kategori default jika tags kosong
    final displayTags = recipe.tags.isNotEmpty
        ? recipe.tags
        : ['Sehat', 'Praktis', 'Zero Waste'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Foto Masakan Asli (Rasio 16:9) ─────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Foto Masakan
                        if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
                          Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFE8FDF6),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF00CBA7),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackHero(),
                          )
                        else
                          _buildFallbackHero(),

                        // Gradient Shadow Bawah Foto
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 48,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),

                        // Floating Badges Kategori di Pojok Kiri Atas (Translucent Blur)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Wrap(
                            spacing: 6,
                            children: displayTags.take(2).map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xE6004D40), // Toska gelap transparan
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0x6600CBA7)),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Panel Bawah: Judul, Deskripsi & Metrik Sejajar ──
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Resep & Tombol Bookmark Instan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              recipe.name,
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol Bookmark / Simpan Cepat
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              if (onBookmarkTap != null) {
                                onBookmarkTap!();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: recipe.isSaved
                                    ? const Color(0xFF00CBA7)
                                    : const Color(0xFFF2F4F7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                recipe.isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: recipe.isSaved
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Deskripsi Singkat
                      Text(
                        recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Baris Metrik Sejajar dengan Ikon Mini
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MetricMini(
                            icon: Icons.schedule_rounded,
                            label: '${recipe.durationMinutes} Mnt',
                            color: const Color(0xFF00897B),
                          ),
                          _MetricMini(
                            icon: Icons.signal_cellular_alt_rounded,
                            label: recipe.difficulty,
                            color: AppColors.forestGreen,
                          ),
                          _MetricMini(
                            icon: Icons.local_fire_department_rounded,
                            label: '~${recipe.calories} kkal',
                            color: Colors.deepOrange,
                          ),
                          _MetricMini(
                            icon: Icons.people_alt_rounded,
                            label: '${recipe.servings} Porsi',
                            color: AppColors.sunsetOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00CBA7), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 6),
              Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricMini extends StatelessWidget {
  const _MetricMini({
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
