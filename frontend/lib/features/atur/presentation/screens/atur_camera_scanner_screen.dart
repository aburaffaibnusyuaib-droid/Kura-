import 'package:camera/camera.dart';
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
import '../widgets/atur_laser_viewfinder_overlay.dart';

/// Layar Live Viewfinder Kamera & Scanner Engine Atur Makanan (Refactored).
class AturCameraScannerScreen extends ConsumerStatefulWidget {
  const AturCameraScannerScreen({super.key});

  @override
  ConsumerState<AturCameraScannerScreen> createState() =>
      _AturCameraScannerScreenState();
}

class _AturCameraScannerScreenState
    extends ConsumerState<AturCameraScannerScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _hasPermission = true;
  bool _isFlashOn = false;
  bool _isCapturing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameraFlow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (lifecycleState == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _initCameraFlow();
    }
  }

  Future<void> _initCameraFlow() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    if (status.isGranted) {
      setState(() => _hasPermission = true);
      ref.read(aturControllerProvider.notifier).setHasPermission(granted: true);
      await _setupCameras();
    } else {
      setState(() => _hasPermission = false);
      ref.read(aturControllerProvider.notifier).setHasPermission(granted: false);
    }
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty && mounted) {
        await _initializeController(_cameras.first);
      }
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _initializeController(CameraDescription cameraDescription) async {
    final controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (_) {
      if (mounted) setState(() => _isCameraInitialized = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    HapticFeedback.lightImpact();
    try {
      final nextFlash = !_isFlashOn;
      await _cameraController!.setFlashMode(
        nextFlash ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() => _isFlashOn = nextFlash);
    } catch (_) {}
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    HapticFeedback.lightImpact();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        setState(() => _isCapturing = true);
        final file = await _cameraController!.takePicture();
        if (mounted) {
          ref.read(aturControllerProvider.notifier).capturePhoto(file.path);
          context.push(AppRoutes.aturAnalyzing);
        }
      } catch (_) {
        // Fallback ke picker jika error hardware
        await _pickFromCamera();
      } finally {
        if (mounted) setState(() => _isCapturing = false);
      }
    } else {
      await _pickFromCamera();
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      ref.read(aturControllerProvider.notifier).capturePhoto(picked.path);
      context.push(AppRoutes.aturAnalyzing);
    }
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      ref.read(aturControllerProvider.notifier).capturePhoto(picked.path);
      context.push(AppRoutes.aturAnalyzing);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildPermissionDeniedUI()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Live Camera Feed / Fallback Background ─────────────
          if (_isCameraInitialized && _cameraController != null)
            Center(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.electricTeal),
              ),
            ),

          // ── Laser Viewfinder Overlay ───────────────────────────
          const AturLaserViewfinderOverlay(),

          // ── Top Bar Controls (Back & Flash) ───────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Back
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),

                    // Judul Mode
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.electricTeal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Bahan Zero Waste',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle Flash
                    GestureDetector(
                      onTap: _toggleFlash,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isFlashOn
                              ? AppColors.electricTeal
                              : Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _isFlashOn ? AppColors.deepMidnightNavy : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Controls (Gallery, Shutter) ─────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Galeri
                    GestureDetector(
                      onTap: _pickFromGallery,
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
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Galeri',
                            style: AppTextStyles.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Tombol Shutter Utama
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.electricTeal,
                            shape: BoxShape.circle,
                          ),
                          child: _isCapturing
                              ? const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.deepMidnightNavy,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.deepMidnightNavy,
                                  size: 32,
                                ),
                        ),
                      ),
                    ),

                    // Placeholder Seimbang Kanan
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/il_camera_permission.png',
            height: 180,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.no_photography_rounded,
              size: 80,
              color: AppColors.electricTeal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Izin Kamera Diperlukan',
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kura AI memerlukan izin kamera untuk memindai bahan makananmu secara langsung.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _initCameraFlow();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricTeal,
              foregroundColor: AppColors.deepMidnightNavy,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Izinkan Kamera'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              openAppSettings();
            },
            child: Text(
              'Buka Pengaturan',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.electricTeal),
            ),
          ),
        ],
      ),
    );
  }
}
