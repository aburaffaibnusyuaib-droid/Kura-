// TASK-05: SUBTASK-05D — Atur Ingredient Selection Screen (Mockup 06 & 09)
// Pengguna bisa toggle, hapus, dan tambah bahan sebelum generate resep.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../widgets/ingredient_chip.dart';

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
          backgroundColor: Color(0xFF4DB6AC),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    await ref.read(aturControllerProvider.notifier).generateRecipes();
    if (mounted) context.push(AppRoutes.aturRecipes);
  }

  void _showAddDialog() {
    _addCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Bahan'),
        content: TextField(
          controller: _addCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama bahan (mis. Bayam)',
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
              backgroundColor: AppColors.primaryTeal,
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
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, selectedCount),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDemoNote(),
                    const SizedBox(height: 16),
                    _buildSectionTitle(
                      'Bahan Terdeteksi AI',
                      subtitle: '⚠️ Verifikasi ulang sebelum digunakan',
                    ),
                    const SizedBox(height: 12),
                    if (ingredients.isEmpty)
                      _buildEmptyState()
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ingredients.map((ing) {
                          return IngredientChip(
                            ingredient: ing,
                            onToggle: () => ref
                                .read(aturControllerProvider.notifier)
                                .toggleIngredient(ing.id),
                            onRemove: () => ref
                                .read(aturControllerProvider.notifier)
                                .removeIngredient(ing.id),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    _buildAddButton(),
                    const SizedBox(height: 16),
                    if (selectedCount > 0) _buildSelectionSummary(selectedCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ── Bottom CTA ─────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _generateRecipes,
            icon: const Icon(Icons.restaurant_menu_rounded, size: 20),
            label: Text(
              selectedCount > 0
                  ? 'Cari Resep ($selectedCount bahan)'
                  : 'Pilih Bahan Dulu',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedCount > 0
                  ? AppColors.primaryTeal
                  : AppColors.textSecondary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle:
                  AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int selectedCount) {
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
                  'Bahan Terdeteksi',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$selectedCount bahan dipilih',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primaryTeal),
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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF66BB6A).withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_rounded, color: Color(0xFF388E3C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '[DEMO] Data bahan adalah simulasi. Hasil AI hanya sebagai saran.',
              style: AppTextStyles.caption.copyWith(color: const Color(0xFF388E3C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Belum ada bahan. Tambahkan secara manual.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      onPressed: _showAddDialog,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Tambah Bahan Manual'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryTeal,
        side: BorderSide(color: AppColors.primaryTeal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildSelectionSummary(int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTeal.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: Color(0xFF4DB6AC), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count bahan siap diproses menjadi 3 rekomendasi resep',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
