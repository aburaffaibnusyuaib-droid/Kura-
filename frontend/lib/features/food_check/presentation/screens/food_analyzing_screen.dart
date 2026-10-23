import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/widgets/kura_ai_analyzing_view.dart';
import '../../domain/food_check_models.dart';
import '../controllers/food_check_controller.dart';

/// Layar animasi pemrosesan AI Food Check (Overhauled & Zero Dead Space).
class FoodAnalyzingScreen extends ConsumerStatefulWidget {
  const FoodAnalyzingScreen({super.key});

  @override
  ConsumerState<FoodAnalyzingScreen> createState() => _FoodAnalyzingScreenState();
}

class _FoodAnalyzingScreenState extends ConsumerState<FoodAnalyzingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeAnalysis();
    });
  }

  Future<void> _executeAnalysis() async {
    final state = ref.read(foodCheckControllerProvider);
    if (state.isOffline) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        context.pushReplacement(AppRoutes.foodCheckOffline);
      }
      return;
    }

    final success =
        await ref.read(foodCheckControllerProvider.notifier).startAnalysis();

    if (mounted) {
      if (success) {
        final result = ref.read(foodCheckControllerProvider).result;
        final hasCompleted =
            ref.read(foodCheckControllerProvider).hasCompletedQuestionnaire;

        // Jika status UNCERTAIN pada Makanan Segar dan belum pernah isi kuesioner lanjutan
        if (result != null &&
            result.foodType == FoodType.fresh &&
            result.status == FoodCheckStatus.unableToAssess &&
            !hasCompleted) {
          context.pushReplacement(AppRoutes.foodCheckQuestionnaire);
        } else {
          // Segarkan riwayat di beranda Food Check
          ref.read(foodCheckHistoryProvider.notifier).refresh();
          context.pushReplacement(AppRoutes.foodCheckResult);
        }
      } else {
        context.pushReplacement(AppRoutes.foodCheckOffline);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodCheckControllerProvider);

    return Scaffold(
      body: KuraAiAnalyzingView(
        title: 'Sedang Memeriksa Makanan...',
        progress: state.analysisProgress,
        onBack: () => context.pop(),
      ),
    );
  }
}
