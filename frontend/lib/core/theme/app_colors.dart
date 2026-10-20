import 'package:flutter/material.dart';

/// Warna brand resmi Kura AI - Light Mode MVP.
/// Semua warna harus diambil dari konstanta ini; hindari hardcode di UI.
abstract final class AppColors {
  // Brand palette
  static const Color electricTeal = Color(0xFF00F0A8);
  static const Color deepMidnightNavy = Color(0xFF081426);
  static const Color sunsetOrange = Color(0xFFFF5A36);
  static const Color buttermilk = Color(0xFFFFF4D0);
  static const Color offWhite = Color(0xFFFAF8F5);
  static const Color white = Color(0xFFFFFFFF);

  // Turunan fungsional
  static const Color primary = electricTeal;
  static const Color onPrimary = deepMidnightNavy;
  static const Color secondary = sunsetOrange;
  static const Color background = offWhite;
  static const Color surface = white;
  static const Color onBackground = deepMidnightNavy;
  static const Color onSurface = deepMidnightNavy;
  static const Color textPrimary = deepMidnightNavy;
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint = Color(0xFF9AA5B4);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color cardBackground = white;
  static const Color navBackground = white;
  static const Color navSelected = electricTeal;
  static const Color navUnselected = Color(0xFF9AA5B4);

  // Status warna (JANGAN gunakan warna saja; selalu sertakan teks/ikon)
  static const Color statusSafe = Color(0xFF22C55E);
  static const Color statusWarning = sunsetOrange;
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusNeutral = Color(0xFF64748B);

  // Surface tinted untuk kartu fitur
  static const Color foodCheckCardTint = Color(0xFFE8FDF6);
  static const Color aturCardTint = Color(0xFFFFF3E0);
  static const Color kuraAiCardTint = Color(0xFFE3F2FD);
  static const Color kuraAiButtonColor = Color(0xFF64B5F6);

  // Shadow
  static const Color shadow = Color(0x1A081426);
}
