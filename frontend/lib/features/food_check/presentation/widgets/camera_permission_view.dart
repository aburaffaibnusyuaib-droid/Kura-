import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Tampilan state saat izin kamera belum diberikan (Mockup 12).
class CameraPermissionView extends StatelessWidget {
  const CameraPermissionView({
    super.key,
    required this.onRetryTap,
  });

  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustrasi Izin Kamera
            Image.asset(
              'assets/images/il_camera_permission.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.foodCheckCardTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_photography_rounded,
                  size: 64,
                  color: AppColors.sunsetOrange,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space24),
            Text(
              'Akses Kamera Diperlukan',
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              'Kami membutuhkan izin kamera untuk\nmengambil gambar makanan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.space32),
            // Tombol Buka Pengaturan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricTeal,
                  foregroundColor: AppColors.deepMidnightNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Buka Pengaturan',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.space12),
            // Tombol Coba Lagi
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetryTap();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.electricTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.electricTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
