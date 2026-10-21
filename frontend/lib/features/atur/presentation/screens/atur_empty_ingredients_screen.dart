// TASK-05: SUBTASK-05C — Atur Empty Ingredients Screen (Mockup 05)
// Ditampilkan saat AI tidak berhasil mendeteksi bahan apapun.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../widgets/mascot_confused_placeholder.dart';

class AturEmptyIngredientsScreen extends ConsumerWidget {
  const AturEmptyIngredientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Mascot bingung
                const MascotConfusedPlaceholder(size: 140),
                const SizedBox(height: 28),
                Text(
                  'Ups, Bahan Tidak Terdeteksi',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kura AI tidak dapat mengenali bahan dari foto ini. '
                  'Coba foto ulang dengan pencahayaan lebih terang atau '
                  'bahan lebih terlihat jelas.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                // Tips
                _buildTipsCard(),
                const SizedBox(height: 32),
                // Tombol aksi
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(aturControllerProvider.notifier).reset();
                    context.pushReplacement(AppRoutes.aturCamera);
                  },
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Foto Ulang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: AppTextStyles.labelLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.atur),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Kembali ke Beranda Atur'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryTeal,
                    side: BorderSide(color: AppColors.primaryTeal),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    const tips = [
      'Pastikan bahan makanan berada di tengah frame',
      'Gunakan cahaya yang cukup terang',
      'Hindari bayangan atau pantulan cahaya berlebih',
      'Potret dari jarak ± 30-50 cm',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD600).withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: Color(0xFFF57F17), size: 18),
              SizedBox(width: 8),
              Text(
                'Tips Foto Lebih Baik',
                style: TextStyle(
                  color: Color(0xFFF57F17),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Color(0xFFF57F17))),
                    Expanded(
                      child: Text(
                        t,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF5D4037)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
