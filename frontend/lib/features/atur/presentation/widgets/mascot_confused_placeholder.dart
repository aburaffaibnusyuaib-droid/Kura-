// TASK-05: Atur Widget — Mascot Confused (Image or Aesthetic Placeholder)

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Menampilkan maskot Kura bingung (empty state).
/// Memuat gambar `assets/images/mascot_confused.jpg` jika ada,
/// atau jatuh ke placeholder estetik jika belum tersedia.
class MascotConfusedPlaceholder extends StatelessWidget {
  const MascotConfusedPlaceholder({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.asset(
        'assets/images/mascot_confused.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🐢',
                    style: TextStyle(fontSize: size * 0.45),
                  ),
                  Text(
                    '?',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w900,
                      fontSize: size * 0.18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
