import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Overlay viewfinder kamera dengan bingkai bidik dan panduan visual (Mockup 03).
class CameraViewfinderOverlay extends StatelessWidget {
  const CameraViewfinderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = constraints.maxWidth * 0.78;

        return Stack(
          children: [
            // Banner Panduan Atas
            Positioned(
              top: 70,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.deepMidnightNavy.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.electricTeal.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Posisikan makanan di dalam bingkai\nagar hasil lebih akurat.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),

            // Frame Bingkai Bidik Tengah
            Center(
              child: SizedBox(
                width: boxSize,
                height: boxSize,
                child: Stack(
                  children: [
                    // Bingkai tipis transparan
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Siku Sudut Kiri-Atas
                    const Positioned(
                      top: 0,
                      left: 0,
                      child: _CornerBracket(isTop: true, isLeft: true),
                    ),
                    // Siku Sudut Kanan-Atas
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: _CornerBracket(isTop: true, isLeft: false),
                    ),
                    // Siku Sudut Kiri-Bawah
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      child: _CornerBracket(isTop: false, isLeft: true),
                    ),
                    // Siku Sudut Kanan-Bawah
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: _CornerBracket(isTop: false, isLeft: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.isTop, required this.isLeft});

  final bool isTop;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    const length = 28.0;
    const thickness = 3.5;
    const radius = 12.0;

    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: AppColors.white, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: AppColors.white, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: AppColors.white, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: AppColors.white, width: thickness)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(radius) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(radius) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(radius) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(radius) : Radius.zero,
        ),
      ),
    );
  }
}
