import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/local_storage_service.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/home_demo_data.dart';
import 'widgets/home_header.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/section_header.dart';
import 'widgets/activity_item_tile.dart';

/// Home Screen utama Kura AI.
///
/// Menampilkan:
/// - App bar dengan logo Kura AI dan ikon profil
/// - Header salam dengan maskot
/// - Kartu Tips Hari Ini (data [DEMO])
/// - Section Fitur Utama: Food Check, Zero Waste Food, Kura AI (placeholder)
/// - Section Aktivitas Terakhir (data [DEMO])
///
/// Menggunakan [HomeDemoRepository] untuk data demo yang terlabel jelas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── App Bar: Logo + Nama App + Icon Profil ───────────────────
            SliverToBoxAdapter(
              child: _HomeAppBar(),
            ),

            // ─── Header salam + maskot ────────────────────────────────────
            const SliverToBoxAdapter(child: HomeHeader()),

            // ─── Tips Hari Ini ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: DailyTipCard(
                tipText: HomeDemoRepository.dailyTip.text,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.sectionSpacing),
            ),

            // ─── Section: Fitur Utama ─────────────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Fitur Utama',
                onActionTap: () {}, // placeholder
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space16),
            ),

            // Kartu Food Check
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Food Check',
                  description:
                      'Cek keamanan makanan dengan AI, barcode, dan inspeksi visual.',
                  buttonLabel: 'Periksa Sekarang',
                  imagePath: 'assets/images/il_food_check.png',
                  backgroundColor: AppColors.foodCheckCardTint,
                  buttonColor: AppColors.electricTeal,
                  onTap: () => context.go(AppRoutes.foodCheck),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space12),
            ),

            // Kartu Zero Waste Food (Atur)
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Zero Waste Food',
                  description:
                      'Ubah bahan yang tersisa menjadi resep lezat dan bermanfaat.',
                  buttonLabel: 'Cari Resep',
                  imagePath: 'assets/images/il_zero_waste.png',
                  backgroundColor: AppColors.aturCardTint,
                  buttonColor: AppColors.sunsetOrange,
                  onTap: () => context.go(AppRoutes.atur),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space12),
            ),

            // Kartu Kura AI
            SliverToBoxAdapter(
              child: FeatureCard(
                data: FeatureCardData(
                  title: 'Kura AI',
                  description:
                      'Tanya seputar kesehatan, gizi, dan tips makanan langsung ke Kura AI.',
                  buttonLabel: 'Mulai Chat',
                  imagePath: 'assets/images/mascot_home.png',
                  backgroundColor: AppColors.kuraAiCardTint,
                  buttonColor: AppColors.kuraAiButtonColor,
                  onTap: () => context.go(AppRoutes.kuraChat),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.sectionSpacing),
            ),

            // ─── Section: Aktivitas Terakhir ──────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Aktivitas Terakhir',
                onActionTap: () {}, // placeholder
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space16),
            ),

            // [DEMO] Daftar aktivitas — bukan riwayat nyata
            if (HomeDemoRepository.recentActivities.isEmpty)
              const SliverToBoxAdapter(child: _EmptyActivityState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = HomeDemoRepository.recentActivities[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.space8,
                      ),
                      child: ActivityItemTile(item: item),
                    );
                  },
                  childCount: HomeDemoRepository.recentActivities.length,
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppConstants.space32),
            ),
          ],
        ),
      ),
    );
  }
}

/// App bar kustom dengan logo, nama app, dan ikon profil.
class _HomeAppBar extends StatelessWidget {
  void _showProfileSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authControllerProvider);
          final userName = LocalStorageService.instance.getUserName();
          final isGuest = authState.isGuest || !authState.isAuthenticated;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/logo_kura.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_circle_rounded,
                        size: 64,
                        color: Color(0xFF00B4A0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGuest
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFE6F7F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isGuest ? 'Mode Tamu (Guest Mode)' : 'Akun Terverifikasi',
                      style: AppTextStyles.caption.copyWith(
                        color: isGuest
                            ? const Color(0xFFD97706)
                            : const Color(0xFF0D9488),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isGuest)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push(AppRoutes.welcome);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4A0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Masuk / Daftar Akun'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            context.go(AppRoutes.welcome);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusDanger,
                          side: const BorderSide(color: AppColors.statusDanger),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Keluar dari Akun (Logout)'),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding,
        AppConstants.space16,
        AppConstants.space8,
        0,
      ),
      child: Row(
        children: [
          // Logo Kura AI
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo_kura.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.electricTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.deepMidnightNavy,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space8),
          Text(
            'Kura AI',
            style: AppTextStyles.headlineMedium,
          ),
          const Spacer(),
          // Ikon profil
          IconButton(
            onPressed: () => _showProfileSheet(context),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
            tooltip: 'Profil',
          ),
        ],
      ),
    );
  }
}

/// State kosong saat belum ada aktivitas terakhir.
class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.space32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_rounded,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            'Belum ada aktivitas',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            'Mulai gunakan Food Check atau Zero Waste Food!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
