import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/kura_camera_scanner_screen.dart';
import '../controllers/atur_controller.dart';

/// Layar Live Viewfinder Kamera & Scanner Engine Atur Makanan (Unified Scanner Engine).
class AturCameraScannerScreen extends ConsumerWidget {
  const AturCameraScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KuraCameraScannerScreen(
      title: 'Scan Bahan Zero Waste',
      hintTitle: 'Arahkan kamera ke bahan makanan',
      hintSubtitle: 'AI akan mendeteksi bahan untuk resep zero-waste',
      onBack: () => context.pop(),
      onImageCaptured: (imagePath) {
        ref.read(aturControllerProvider.notifier).capturePhoto(imagePath);
        context.push(AppRoutes.aturAnalyzing);
      },
    );
  }
}
