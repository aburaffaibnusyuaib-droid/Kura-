import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/kura_ai_analyzing_view.dart';
import '../../domain/atur_models.dart';
import '../controllers/atur_controller.dart';

/// Layar animasi pemrosesan AI Atur Makanan (Overhauled & Zero Dead Space).
class AturAnalyzingScreen extends ConsumerStatefulWidget {
  const AturAnalyzingScreen({super.key});

  @override
  ConsumerState<AturAnalyzingScreen> createState() =>
      _AturAnalyzingScreenState();
}

class _AturAnalyzingScreenState extends ConsumerState<AturAnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _progressCtrl,
        builder: (context, _) {
          return KuraAiAnalyzingView(
            title: 'Mengenali Bahan Makanan...',
            progress: _progressCtrl.value,
            onBack: () => context.pop(),
          );
        },
      ),
    );
  }
}
