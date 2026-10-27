import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget pemotong gambar bahan makanan otomatis on-device berbasis koordinat Bounding Box (box_2d) Gemini.
/// Menampilkan potongan fisik bahan makanan murni dari foto asli kamera pengguna (Zero-Unsplash/Internet).
class CroppedIngredientImage extends StatelessWidget {
  const CroppedIngredientImage({
    super.key,
    this.originalImage,
    this.originalImagePath,
    this.box2d,
    this.borderRadius,
    this.fallback,
  });

  /// Raw bytes dari foto kamera asli pengguna
  final Uint8List? originalImage;

  /// Path lokal dari foto kamera asli pengguna
  final String? originalImagePath;

  /// Koordinat [ymin, xmin, ymax, xmax] skala 0-1000 dari Gemini Vision
  final List<int>? box2d;

  /// Radius border untuk kartu
  final BorderRadius? borderRadius;

  /// Widget pengganti jika bounding box atau foto tidak tersedia
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final clipRadius =
        borderRadius ?? const BorderRadius.vertical(top: Radius.circular(14));

    // Fallback jika data koordinat tidak valid atau foto belum tersedia
    if (box2d == null || box2d!.length != 4) {
      return fallback ?? _buildDefaultFallback(clipRadius);
    }

    final hasMemoryImage = originalImage != null && originalImage!.isNotEmpty;
    final hasFileImage = originalImagePath != null &&
        originalImagePath!.isNotEmpty &&
        File(originalImagePath!).existsSync();

    if (!hasMemoryImage && !hasFileImage) {
      return fallback ?? _buildDefaultFallback(clipRadius);
    }

    // Ekstraksi koordinat dasar skala 0-1000 dari Gemini
    final double rawYmin = (box2d![0] / 1000).clamp(0.0, 1.0);
    final double rawXmin = (box2d![1] / 1000).clamp(0.0, 1.0);
    final double rawYmax = (box2d![2] / 1000).clamp(0.0, 1.0);
    final double rawXmax = (box2d![3] / 1000).clamp(0.0, 1.0);

    // 10% Safety Margin: Perluas batas koordinat 10% ke luar agar fisik bahan tidak terpotong
    final double rawWidth = (rawXmax - rawXmin).abs();
    final double rawHeight = (rawYmax - rawYmin).abs();
    final double marginX = rawWidth * 0.10;
    final double marginY = rawHeight * 0.10;

    final double xmin = (rawXmin - marginX).clamp(0.0, 1.0);
    final double ymin = (rawYmin - marginY).clamp(0.0, 1.0);
    final double xmax = (rawXmax + marginX).clamp(0.0, 1.0);
    final double ymax = (rawYmax + marginY).clamp(0.0, 1.0);

    final double boxWidthRatio = (xmax - xmin).abs().clamp(0.02, 1.0);
    final double boxHeightRatio = (ymax - ymin).abs().clamp(0.02, 1.0);

    final double scaleX = 1.0 / boxWidthRatio;
    final double scaleY = 1.0 / boxHeightRatio;

    return LayoutBuilder(
      builder: (context, constraints) {
        final targetWidth = constraints.maxWidth;
        final targetHeight = constraints.maxHeight;

        Widget imageWidget;
        if (hasMemoryImage) {
          imageWidget = Image.memory(
            originalImage!,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                _buildDefaultFallback(clipRadius),
          );
        } else {
          imageWidget = Image.file(
            File(originalImagePath!),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) =>
                _buildDefaultFallback(clipRadius),
          );
        }

        return ClipRRect(
          borderRadius: clipRadius,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: -xmin * targetWidth * scaleX,
                top: -ymin * targetHeight * scaleY,
                width: targetWidth * scaleX,
                height: targetHeight * scaleY,
                child: imageWidget,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultFallback(BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        'assets/images/placeholder_ingredients.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFE6F7F5),
          child: const Center(
            child: Icon(
              Icons.restaurant_rounded,
              color: AppColors.electricTeal,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
