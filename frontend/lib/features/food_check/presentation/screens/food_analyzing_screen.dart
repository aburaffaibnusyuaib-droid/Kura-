import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../controllers/food_check_controller.dart';

/// Layar animasi pemrosesan AI (Mockup 05).
class FoodAnalyzingScreen extends ConsumerStatefulWidget {
  const FoodAnalyzingScreen({super.key});

  @override
  ConsumerState<FoodAnalyzingScreen> createState() => _FoodAnalyzingScreenState();
}

class _FoodAnalyzingScreenState extends ConsumerState<FoodAnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _tipTimer;
  int _currentTipIndex = 0;

  final List<String> _tips = [
    'Jangan khawatir, proses ini hanya membutuhkan beberapa detik.',
    'AI menganalisis perubahan warna, tekstur visual, dan integritas kemasan.',
    'Simpan sayuran pada suhu 4–7°C di kulkas agar kesegarannya terjaga lebih lama.',
    'Pemeriksaan visual adalah langkah awal; pastikan selalu mencium dan mengecek fisik makanan.',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
        });
      }
    });

    // Mulai proses analisis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeAnalysis();
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _executeAnalysis() async {
    final state = ref.read(foodCheckControllerProvider);
    if (state.isOffline) {
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        context.pushReplacement(AppRoutes.foodCheckOffline);
      }
      return;
    }

    final success = await ref.read(foodCheckControllerProvider.notifier).startAnalysis();

    if (mounted) {
      if (success) {
        context.pushReplacement(AppRoutes.foodCheckResult);
      } else {
        context.pushReplacement(AppRoutes.foodCheckOffline);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodCheckControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Maskot Menganalisis dengan Animasi Pulse/Breathing (Mockup 05)
              ScaleTransition(
                scale: _pulseAnimation,
                child: Image.asset(
                  'assets/images/mascot_analyzing.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.biotech_rounded,
                    size: 96,
                    color: AppColors.electricTeal,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Sedang memeriksa makananmu...',
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'AI kami sedang menganalisis informasi dari\ngambar, barcode, dan detail lainnya.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Progress Bar Animasi & Persentase
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: state.analysisProgress,
                        minHeight: 12,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricTeal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(state.analysisProgress * 100).toInt()}%',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.electricTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Kotak Info Tips Edukatif Dinamis (Mockup 05)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.foodCheckCardTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.electricTeal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.electricTeal, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _tips[_currentTipIndex],
                          key: ValueKey<int>(_currentTipIndex),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.deepMidnightNavy,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
