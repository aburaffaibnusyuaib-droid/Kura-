import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Header salam Home Screen: teks sambutan + ilustrasi maskot.
/// Logo dan nama app ditampilkan di bagian AppBar custom di [HomeScreen].
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding,
        AppConstants.space8,
        AppConstants.horizontalPadding,
        AppConstants.space24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konten teks salam
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang kembali,',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  'Pengguna! 👋',
                  style: AppTextStyles.displayMedium,
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'Jaga makananmu, kurangi sampahnya,\nhidup lebih sehat bersama Kura AI.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Maskot ilustrasi
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.space8,
              top: AppConstants.space16,
            ),
            child: Image.asset(
              'assets/images/mascot_home.png',
              width: 110,
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const _MascotPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder estetik jika aset maskot tidak tersedia.
class _MascotPlaceholder extends StatelessWidget {
  const _MascotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        color: AppColors.foodCheckCardTint,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.eco_rounded,
        size: 56,
        color: AppColors.electricTeal,
      ),
    );
  }
}
