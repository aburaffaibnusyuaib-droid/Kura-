import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/food_check_models.dart';

/// Section Riwayat Cek Terakhir (Horizontal Cards) untuk Food Check.
/// Terhubung langsung ke penyimpanan lokal via Riverpod.
class RecentScansSection extends ConsumerWidget {
  const RecentScansSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(foodCheckHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Cek Terakhir', style: AppTextStyles.headlineMedium),
              if (history.isNotEmpty)
                Text(
                  '${history.length} Terpindai',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.electricTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        if (history.isEmpty)
          _buildEmptyHistory()
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.horizontalPadding),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = history[index] as FoodCheckResult;
                return _RecentCard(item: item);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history_rounded,
                  color: AppColors.textHint, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belum Ada Riwayat',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hasil scan makanan Anda akan tersimpan otomatis di sini.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item});

  final FoodCheckResult item;

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Baru saja';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (item.status) {
      case FoodCheckStatus.looksOk:
        statusColor = AppColors.statusSafe;
        statusBg = AppColors.statusSafeBg;
        statusIcon = Icons.check_circle_rounded;
      case FoodCheckStatus.checkFurther:
        statusColor = AppColors.statusWarning;
        statusBg = AppColors.statusWarningBg;
        statusIcon = Icons.warning_amber_rounded;
      case FoodCheckStatus.avoidEating:
        statusColor = AppColors.statusDanger;
        statusBg = AppColors.statusDangerBg;
        statusIcon = Icons.cancel_rounded;
      case FoodCheckStatus.unableToAssess:
        statusColor = AppColors.sunsetOrange;
        statusBg = AppColors.aturCardTint;
        statusIcon = Icons.help_outline_rounded;
    }

    return Container(
      width: 236,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  color: AppColors.offWhite,
                  child: _buildThumb(item.imagePath, item.foodType),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: AppTextStyles.labelLarge
                          .copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.categoryName,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item.status.label,
                          style: AppTextStyles.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatTimeAgo(item.scannedAt),
                style: AppTextStyles.caption
                    .copyWith(fontSize: 10, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(String path, FoodType type) {
    if (path.isNotEmpty) {
      if (path.startsWith('assets/')) {
        return Image.asset(path, fit: BoxFit.cover);
      }
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.asset(
      type == FoodType.packaged
          ? 'assets/images/il_packaged_food.png'
          : 'assets/images/il_fresh_food.png',
      fit: BoxFit.contain,
    );
  }
}
