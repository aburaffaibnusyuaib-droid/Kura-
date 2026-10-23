import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/kura_camera_scanner_screen.dart';
import '../controllers/food_check_controller.dart';

/// Layar bidik kamera pemindaian makanan (Unified Scanner Engine).
class FoodScanScreen extends ConsumerWidget {
  const FoodScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KuraCameraScannerScreen(
      title: 'Pindai Makanan',
      hintTitle: 'Arahkan kamera ke makanan atau kemasan',
      hintSubtitle: 'Pastikan pencahayaan cukup dan objek terlihat jelas',
      onBack: () => context.pop(),
      onImageCaptured: (imagePath) {
        ref.read(foodCheckControllerProvider.notifier).setCapturedImage(imagePath);
        context.push(AppRoutes.foodCheckPreview);
      },
    );
  }
}
