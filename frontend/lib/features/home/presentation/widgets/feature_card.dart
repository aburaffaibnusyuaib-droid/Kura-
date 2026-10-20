import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Model data untuk kartu fitur utama.
final class FeatureCardData {
  const FeatureCardData({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.imagePath,
    required this.backgroundColor,
    required this.buttonColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final String imagePath;
  final Color backgroundColor;
  final Color buttonColor;
  final VoidCallback onTap;
}

/// Kartu fitur utama (Food Check, Zero Waste, Kura AI).
/// Menampilkan ilustrasi, judul, deskripsi, dan tombol aksi.
class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.data});

  final FeatureCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      decoration: BoxDecoration(
        color: data.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            data.onTap();
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.cardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ilustrasi fitur
                _FeatureIllustration(
                  imagePath: data.imagePath,
                  backgroundColor: data.backgroundColor,
                ),
                const SizedBox(width: AppConstants.space12),
                // Konten: judul + deskripsi + tombol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.space4),
                      Text(
                        data.description,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppConstants.space12),
                      _FeatureButton(
                        label: data.buttonLabel,
                        color: data.buttonColor,
                        onTap: data.onTap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.space4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget ilustrasi dengan fallback placeholder estetik.
class _FeatureIllustration extends StatelessWidget {
  const _FeatureIllustration({
    required this.imagePath,
    required this.backgroundColor,
  });

  final String imagePath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textHint,
        size: 36,
      ),
    );
  }
}

/// Tombol aksi di dalam kartu fitur.
class _FeatureButton extends StatelessWidget {
  const _FeatureButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  bool get _isDark =>
      color == AppColors.electricTeal || color == AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.space16,
            vertical: AppConstants.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: _isDark
                      ? AppColors.deepMidnightNavy
                      : AppColors.white,
                ),
              ),
              const SizedBox(width: AppConstants.space4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: _isDark
                    ? AppColors.deepMidnightNavy
                    : AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
