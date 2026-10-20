/// Konstanta global aplikasi Kura AI.
abstract final class AppConstants {
  // App metadata
  static const String appName = 'Kura AI';
  static const String appVersion = '1.0.0';

  // Spacing scale (4/8-point grid)
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  // Radius
  static const double radiusCard = 16;
  static const double radiusButton = 12;
  static const double radiusInput = 12;
  static const double radiusChip = 8;

  // Layout
  static const double horizontalPadding = 16;
  static const double cardPadding = 16;
  static const double sectionSpacing = 24;

  // Touch target minimum 48x48 logical pixels
  static const double minTouchTarget = 48;

  // Network
  static const String baseUrlLocal = 'http://127.0.0.1:8000';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Image constraints
  static const int maxImageEdgePx = 1600;
  static const int maxImageSizeMb = 5;
}
