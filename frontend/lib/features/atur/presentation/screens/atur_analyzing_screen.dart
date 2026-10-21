// TASK-05: SUBTASK-05C — Atur Analyzing Screen (Mockup 04)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';
import '../../domain/atur_models.dart';

class AturAnalyzingScreen extends ConsumerStatefulWidget {
  const AturAnalyzingScreen({super.key});

  @override
  ConsumerState<AturAnalyzingScreen> createState() =>
      _AturAnalyzingScreenState();
}

class _AturAnalyzingScreenState extends ConsumerState<AturAnalyzingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _progressCtrl;
  Timer? _tipTimer;
  int _tipIndex = 0;

  static const _tips = [
    '🌿 Simpan sayuran hijau di laci crisper kulkas',
    '🥚 Telur tahan hingga 3-5 minggu di kulkas',
    '🍅 Tomat lebih enak disimpan di suhu ruang',
    '♻️ Sisa sayur bisa jadi kaldu lezat',
    '🥕 Wortel tetap segar jika disimpan dalam air',
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _tipTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });

    // Mulai analisis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  Future<void> _startAnalysis() async {
    await ref.read(aturControllerProvider.notifier).analyzeIngredients();
    if (!mounted) return;
    final status = ref.read(aturControllerProvider).status;
    if (status == AturAnalysisStatus.detected) {
      context.pushReplacement(AppRoutes.aturIngredients);
    } else {
      context.pushReplacement(AppRoutes.aturEmptyIngredients);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildMascot(),
                    const SizedBox(height: 32),
                    _buildProgressSection(),
                    const SizedBox(height: 32),
                    _buildTipCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Menganalisis Bahan',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascot() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Image.asset(
        'assets/images/mascot_analyzing.png',
        height: 160,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🐢', style: TextStyle(fontSize: 70)),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'Kura AI sedang mengenali\nbahan makananmu...',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '⚠️ Hasil AI bersifat saran. Selalu periksa ulang bahan.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _progressCtrl,
            builder: (context, child) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressCtrl.value,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryTeal.withAlpha(30),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_progressCtrl.value * 100).toInt()}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_tipIndex),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryTeal.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                color: Color(0xFF4DB6AC), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _tips[_tipIndex],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
