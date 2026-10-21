import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Section Riwayat Cek Terakhir (Horizontal Cards) untuk Food Check.
class RecentScansSection extends StatelessWidget {
  const RecentScansSection({super.key});

  @override
  Widget build(BuildContext context) {
    const recentItems = [
      _RecentItem(
        title: 'Sarden Saus Tomat',
        category: 'Kemasan Kaleng',
        timeAgo: '1 jam lalu',
        statusLabel: 'Aman',
        statusColor: AppColors.statusSafe,
        statusBg: AppColors.statusSafeBg,
        icon: Icons.check_circle_rounded,
        imageAsset: 'assets/images/il_packaged_food.png',
      ),
      _RecentItem(
        title: 'Dada Ayam Segar',
        category: 'Daging Segar',
        timeAgo: 'Kemarin',
        statusLabel: 'Perlu Cek',
        statusColor: AppColors.statusWarning,
        statusBg: AppColors.statusWarningBg,
        icon: Icons.warning_amber_rounded,
        imageAsset: 'assets/images/il_fresh_food.png',
      ),
      _RecentItem(
        title: 'Susu UHT Cokelat',
        category: 'Produk Susu',
        timeAgo: '2 hari lalu',
        statusLabel: 'Aman',
        statusColor: AppColors.statusSafe,
        statusBg: AppColors.statusSafeBg,
        icon: Icons.check_circle_rounded,
        imageAsset: 'assets/images/il_packaged_food.png',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Cek Terakhir', style: AppTextStyles.headlineMedium),
              Text(
                'Lihat Semua',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.electricTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recentItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return _RecentCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _RecentItem {
  const _RecentItem({
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    required this.icon,
    required this.imageAsset,
  });

  final String title;
  final String category;
  final String timeAgo;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;
  final IconData icon;
  final String imageAsset;
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item});

  final _RecentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood_rounded, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.category,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 12, color: item.statusColor),
                    const SizedBox(width: 4),
                    Text(
                      item.statusLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: item.statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.timeAgo,
                style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
