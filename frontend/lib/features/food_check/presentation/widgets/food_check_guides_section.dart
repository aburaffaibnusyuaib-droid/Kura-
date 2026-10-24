import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Section Panduan Cepat Keamanan Pangan Kura AI.
class FoodCheckGuidesSection extends StatelessWidget {
  const FoodCheckGuidesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const guides = [
      _GuideData(
        title: 'Kemasan Kembung / Rusak',
        subtitle: 'Waspadai mikroba anaerob botulisme jika kaleng atau pouch menggembung.',
        badge: 'Makanan Kemasan',
        badgeColor: AppColors.sunsetOrange,
        icon: Icons.inventory_2_outlined,
      ),
      _GuideData(
        title: 'Tanda Kesegaran Bahan',
        subtitle: 'Bahan segar memiliki aroma netral, warna cerah, dan tekstur tidak berlendir.',
        badge: 'Makanan Segar',
        badgeColor: AppColors.statusSafe,
        icon: Icons.eco_outlined,
      ),
      _GuideData(
        title: 'Prinsip Emas Keamanan',
        subtitle: '"When in doubt, throw it out." Jangan pernah mengambil risiko jika ragu.',
        badge: 'Standar Kura AI',
        badgeColor: AppColors.electricTeal,
        icon: Icons.health_and_safety_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.electricTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Panduan Cepat Kura AI',
                  style: AppTextStyles.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guides.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final g = guides[index];
              return _GuideCard(guide: g);
            },
          ),
        ],
      ),
    );
  }
}

class _GuideData {
  const _GuideData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final IconData icon;
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide});

  final _GuideData guide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: guide.badgeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(guide.icon, color: guide.badgeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        guide.title,
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: guide.badgeColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        guide.badge,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: guide.badgeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  guide.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
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
