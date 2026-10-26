import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../widgets/ingredient_grid_card.dart';

/// Layar Pemilihan Bahan Makanan Berbasis 2-Column Grid (Mockup 09).
class AturIngredientSelectionScreen extends ConsumerStatefulWidget {
  const AturIngredientSelectionScreen({super.key});

  @override
  ConsumerState<AturIngredientSelectionScreen> createState() =>
      _AturIngredientSelectionScreenState();
}

class _AturIngredientSelectionScreenState
    extends ConsumerState<AturIngredientSelectionScreen> {
  final TextEditingController _addCtrl = TextEditingController();

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateRecipes() async {
    final state = ref.read(aturControllerProvider);
    if (state.selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 bahan terlebih dahulu'),
          backgroundColor: Color(0xFF00CBA7),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 12),
              CircularProgressIndicator(color: Color(0xFF00CBA7)),
              SizedBox(height: 20),
              Text(
                'Kura AI sedang meracik 3 resep zero waste...',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );

    try {
      await ref.read(aturControllerProvider.notifier).generateRecipes();
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }

    if (mounted) {
      final recipes = ref.read(aturControllerProvider).recipes;
      final errorMsg = ref.read(aturControllerProvider).errorMessage;
      if (recipes.isNotEmpty) {
        context.push(AppRoutes.aturRecipes);
      } else {
        showDialog<void>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.statusWarning),
                SizedBox(width: 8),
                Text(
                  'Gagal Membuat Resep',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              errorMsg != null && errorMsg.toLowerCase().contains('timeout')
                  ? 'Waktu pembuatan resep habis (timeout). Server AI membutuhkan waktu lebih lama. Silakan coba kembali.'
                  : (errorMsg ??
                      'Kura AI tidak dapat menyelesaikan racikan resep saat ini. Periksa koneksi internet Anda.'),
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _generateRecipes();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CBA7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showAddDialog() {
    _addCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Bahan Manual'),
        content: TextField(
          controller: _addCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama bahan (mis. Bayam, Tempe)',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _submitAdd(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _submitAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CBA7),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _submitAdd() {
    if (_addCtrl.text.trim().isNotEmpty) {
      ref.read(aturControllerProvider.notifier).addIngredient(_addCtrl.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aturControllerProvider);
    final ingredients = state.detectedIngredients;
    final selectedCount = state.selectedIngredients.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ──────────────────────────────
            _buildHeader(context, selectedCount),

            // ── Main Content Grid ───────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Title & Subtitle Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bahan Terdeteksi',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showAddDialog,
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 18,
                                  color: Color(0xFF00CBA7),
                                ),
                                label: Text(
                                  'Tambah',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: const Color(0xFF00CBA7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pilih bahan yang ingin kamu olah hari ini:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2-Column Grid Card
                  if (ingredients.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Tidak ada bahan terdeteksi.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          childAspectRatio: 0.82,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final ing = ingredients[index];
                            return IngredientGridCard(
                              ingredient: ing,
                              onToggle: () => ref
                                  .read(aturControllerProvider.notifier)
                                  .toggleIngredient(ing.id),
                            );
                          },
                          childCount: ingredients.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Sticky Bottom Button: Lanjut ke Rekomendasi ────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: ElevatedButton.icon(
            onPressed: selectedCount > 0 ? _generateRecipes : null,
            icon: const Icon(Icons.restaurant_menu_rounded, size: 20),
            label: Text(
              selectedCount > 0
                  ? 'Lanjut ke Rekomendasi ($selectedCount Bahan)'
                  : 'Pilih Minimal 1 Bahan',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00CBA7),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              minimumSize: const Size(double.infinity, 52),
              elevation: selectedCount > 0 ? 3 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int selectedCount) {
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
                  'Hasil Deteksi Bahan',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$selectedCount bahan dipilih untuk dimasak',
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
