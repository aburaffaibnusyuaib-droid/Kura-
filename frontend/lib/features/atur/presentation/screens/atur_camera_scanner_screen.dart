// TASK-05: SUBTASK-05B — Atur Camera Scanner Screen (Mockup 03)
// Menggunakan image_picker sebagai fallback ringan agar tidak perlu
// CameraController penuh (sudah dipakai food_check, hindari konflik).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/atur_controller.dart';

class AturCameraScannerScreen extends ConsumerStatefulWidget {
  const AturCameraScannerScreen({super.key});

  @override
  ConsumerState<AturCameraScannerScreen> createState() =>
      _AturCameraScannerScreenState();
}

class _AturCameraScannerScreenState
    extends ConsumerState<AturCameraScannerScreen> {
  bool _checkingPermission = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _checkingPermission = false;
      });
      ref
          .read(aturControllerProvider.notifier)
          .setHasPermission(granted: status.isGranted);
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => _hasPermission = status.isGranted);
      ref
          .read(aturControllerProvider.notifier)
          .setHasPermission(granted: status.isGranted);
    }
  }

  Future<void> _openGallery() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      ref.read(aturControllerProvider.notifier).capturePhoto(picked.path);
      context.push(AppRoutes.aturAnalyzing);
    }
  }

  Future<void> _openCamera() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      ref.read(aturControllerProvider.notifier).capturePhoto(picked.path);
      context.push(AppRoutes.aturAnalyzing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _checkingPermission
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : _hasPermission
                ? _buildScannerUI()
                : _buildPermissionDeniedUI(),
      ),
    );
  }

  // ── Scanner UI ────────────────────────────────────────────────

  Widget _buildScannerUI() {
    return Stack(
      children: [
        // Background gelap + viewfinder
        Container(color: Colors.black87),
        // Overlay viewfinder
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildViewfinderFrame(),
              const SizedBox(height: 20),
              Text(
                'Arahkan kamera ke bahan makanan',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                'Pastikan bahan terlihat jelas & terang',
                style: AppTextStyles.caption.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(),
        ),
        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildViewfinderFrame() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryTeal, width: 2.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Corner decorations
          ..._buildCorners(),
          Center(
            child: Icon(
              Icons.kitchen_rounded,
              size: 60,
              color: AppColors.primaryTeal.withAlpha(80),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 20.0;
    const thickness = 3.0;
    const color = Color(0xFF4DB6AC);
    return [
      Positioned(
        top: 0,
        left: 0,
        child: _Corner(size: size, thickness: thickness, color: color),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: _Corner(
            size: size,
            thickness: thickness,
            color: color,
            flipH: true),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: _Corner(
            size: size,
            thickness: thickness,
            color: color,
            flipV: true),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: _Corner(
            size: size,
            thickness: thickness,
            color: color,
            flipH: true,
            flipV: true),
      ),
    ];
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Scan Bahan Makanan',
            style: AppTextStyles.titleSmall
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Galeri
          _CircleButton(
            icon: Icons.photo_library_rounded,
            label: 'Galeri',
            onTap: _openGallery,
          ),
          // Tombol shutter
          GestureDetector(
            onTap: _openCamera,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryTeal,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          // Demo langsung
          _CircleButton(
            icon: Icons.science_rounded,
            label: 'Demo',
            onTap: () {
              ref.read(aturControllerProvider.notifier).capturePhoto('demo');
              context.push(AppRoutes.aturAnalyzing);
            },
          ),
        ],
      ),
    );
  }

  // ── Permission Denied UI ──────────────────────────────────────

  Widget _buildPermissionDeniedUI() {
    return Container(
      color: AppColors.backgroundWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/il_camera_permission.png',
            height: 180,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.no_photography_rounded,
              size: 80,
              color: Color(0xFF4DB6AC),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Izin Kamera Diperlukan',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Kura AI memerlukan akses kamera untuk mengenali bahan makananmu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Izinkan Kamera'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => openAppSettings(),
            child: Text(
              'Buka Pengaturan',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primaryTeal),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────

class _Corner extends StatelessWidget {
  const _Corner({
    required this.size,
    required this.thickness,
    required this.color,
    this.flipH = false,
    this.flipV = false,
  });

  final double size;
  final double thickness;
  final Color color;
  final bool flipH;
  final bool flipV;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipH ? -1 : 1,
      scaleY: flipV ? -1 : 1,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _CornerPainter(color, thickness)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.color, this.thickness);

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.thickness != thickness;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
