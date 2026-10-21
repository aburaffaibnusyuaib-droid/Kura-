import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Overlay Viewfinder Kamera dengan Animasi Laser Scanning Halus (Atur Makanan).
class AturLaserViewfinderOverlay extends StatefulWidget {
  const AturLaserViewfinderOverlay({
    super.key,
    this.boxSize = 280,
  });

  final double boxSize;

  @override
  State<AturLaserViewfinderOverlay> createState() =>
      _AturLaserViewfinderOverlayState();
}

class _AturLaserViewfinderOverlayState extends State<AturLaserViewfinderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxSize = widget.boxSize;
        final left = (constraints.maxWidth - boxSize) / 2;
        final top = (constraints.maxHeight - boxSize) / 2 - 40;

        return Stack(
          children: [
            // ── Kotak Bidik Utama ───────────────────────────────
            Positioned(
              left: left,
              top: top,
              width: boxSize,
              height: boxSize,
              child: Stack(
                children: [
                  // Border luar rounded transparan
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(90),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricTeal.withAlpha(30),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Sudut-sudut bidik aksen toska
                  ..._buildCorners(boxSize),

                  // Garis Laser Scanning Glowing Bergerak Naik-Turun
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimation.value * (boxSize - 12),
                        left: 12,
                        right: 12,
                        child: child!,
                      );
                    },
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.electricTeal.withAlpha(120),
                            AppColors.electricTeal,
                            AppColors.electricTeal.withAlpha(120),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricTeal.withAlpha(180),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Hint Text di Bawah Kotak Bidik ──────────────────
            Positioned(
              top: top + boxSize + 20,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Arahkan kamera ke bahan makanan',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI akan mendeteksi bahan untuk resep zero-waste',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCorners(double size) {
    const cornerLength = 24.0;
    const cornerWidth = 3.5;
    const radius = 24.0;
    const color = AppColors.electricTeal;

    return [
      // Top-Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(radius)),
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Top-Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(radius)),
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-Left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius:
                BorderRadius.only(bottomLeft: Radius.circular(radius)),
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-Right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius:
                BorderRadius.only(bottomRight: Radius.circular(radius)),
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
    ];
  }
}
