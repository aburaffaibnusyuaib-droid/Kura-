import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Model item data halaman onboarding
class OnboardingItem {
  const OnboardingItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.tagBgColor,
    required this.tagTextColor,
  });

  final String tag;
  final String title;
  final String subtitle;
  final String imagePath;
  final Color tagBgColor;
  final Color tagTextColor;
}

/// Layar Onboarding Kura AI (3-Step PageView)
/// Responsif untuk Infinix Hot 30i (720x1612, 20:9) dengan Zero RenderFlex Overflow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      tag: 'Deteksi Visual Instan',
      title: 'Pemeriksaan Makanan Cerdas',
      subtitle:
          'Ketahui kelayakan dan kesegaran makananmu secara instan dengan kecerdasan visual AI Kura.',
      imagePath: 'assets/images/mascot_ob_food_safety.png',
      tagBgColor: Color(0xFFE8FDF6),
      tagTextColor: Color(0xFF0D9488),
    ),
    OnboardingItem(
      tag: 'Resep Ramah Lingkungan',
      title: 'Dapur Bebas Sampah\n(Zero Waste)',
      subtitle:
          'Ubah sisa bahan di kulkas menjadi resep masakan lezat dan hemat tanpa ada yang terbuang.',
      imagePath: 'assets/images/mascot_ob_zero_waste.png',
      tagBgColor: Color(0xFFFFF3E0),
      tagTextColor: Color(0xFFD97706),
    ),
    OnboardingItem(
      tag: 'Asisten Dapur Pintar 24/7',
      title: 'Tanya Kura AI Kapan Saja',
      subtitle:
          'Konsultasikan nutrisi, tips dapur, dan resep masakan langsung dengan asisten pintar Kura.',
      imagePath: 'assets/images/mascot_ob_kura_ask.png',
      tagBgColor: Color(0xFFE0F2FE),
      tagTextColor: Color(0xFF0284C7),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinishOnboarding() async {
    HapticFeedback.mediumImpact();
    await LocalStorageService.instance.setOnboardingDone(true);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _onNextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar: Logo & Tombol Lewati ───────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalPadding,
                vertical: AppConstants.space8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.electricTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.deepMidnightNavy,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppConstants.space8),
                      Text(
                        'Kura AI',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _onFinishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Text(
                        'Lewati',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),

            // ── PageView Slide Onboarding ─────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return _buildPageItem(context, item);
                },
              ),
            ),

            // ── Bottom Section: Dots Indicator & CTA Button ───────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding,
                AppConstants.space12,
                AppConstants.horizontalPadding,
                AppConstants.space20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index == _currentPage),
                    ),
                  ),

                  const SizedBox(height: AppConstants.space20),

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastPage
                            ? const Color(0xFF00CBA7)
                            : AppColors.deepMidnightNavy,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: (isLastPage
                                ? const Color(0xFF00CBA7)
                                : AppColors.deepMidnightNavy)
                            .withAlpha(60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: AppConstants.space8),
                          Icon(
                            isLastPage
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, OnboardingItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final imageSize = (maxHeight * 0.44).clamp(160.0, 260.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.horizontalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ilustrasi Maskot dengan Glow Shadow Lembut
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.tagTextColor.withAlpha(25),
                        blurRadius: 32,
                        spreadRadius: 8,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.smart_toy_rounded,
                      size: imageSize * 0.5,
                      color: item.tagTextColor,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.space24),

                // Pill Tag Kategori
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.tagBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.tagTextColor.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item.tag,
                    style: AppTextStyles.caption.copyWith(
                      color: item.tagTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.space12),

                // Judul Slide
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.25,
                    color: AppColors.deepMidnightNavy,
                  ),
                ),

                const SizedBox(height: AppConstants.space12),

                // Subtitle / Deskripsi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 26 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00CBA7)
            : AppColors.textSecondary.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
