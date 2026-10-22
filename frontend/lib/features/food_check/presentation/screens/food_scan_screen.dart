import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_routes.dart';
import '../controllers/food_check_controller.dart';
import '../widgets/camera_viewfinder_overlay.dart';
import '../widgets/camera_permission_view.dart';

/// Layar bidik kamera pemindaian makanan (Mockup 03, 12, 14).
class FoodScanScreen extends ConsumerStatefulWidget {
  const FoodScanScreen({super.key});

  @override
  ConsumerState<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends ConsumerState<FoodScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _hasPermission = true;
  bool _isFlashOn = false;
  int _selectedCameraIndex = 0;
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
      ref.read(foodCheckControllerProvider.notifier).setCameraPermission(true);
      await _setupCameras();
    } else {
      setState(() => _hasPermission = false);
      ref.read(foodCheckControllerProvider.notifier).setCameraPermission(false);
    }
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty && mounted) {
        await _initializeController(_cameras[_selectedCameraIndex]);
      }
    } catch (_) {
      // Fallback aman jika kamera hardware tidak tersedia (misal di simulator)
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
    if (_cameraController == null || !_isCameraInitialized) return;
    HapticFeedback.lightImpact();
    setState(() => _isFlashOn = !_isFlashOn);
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    HapticFeedback.lightImpact();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initializeController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePicture() async {
    HapticFeedback.heavyImpact();
    String? path;

    if (_cameraController != null && _isCameraInitialized) {
      try {
        final xFile = await _cameraController!.takePicture();
        path = xFile.path;
      } catch (_) {}
    }

    // Fallback path untuk testing jika kamera hardware tidak mereturn file
    path ??= 'assets/images/il_food_check_banner.png';

    if (mounted) {
      ref.read(foodCheckControllerProvider.notifier).setCapturedImage(path);
      context.push(AppRoutes.foodCheckPreview);
    }
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        ref.read(foodCheckControllerProvider.notifier).setCapturedImage(picked.path);
        context.push(AppRoutes.foodCheckPreview);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          backgroundColor: AppColors.background,
        ),
        body: CameraPermissionView(onRetryTap: _initCameraFlow),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Preview Kamera atau Placeholder Cerdas
            Positioned.fill(
              child: _isCameraInitialized && _cameraController != null
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_rounded, size: 56, color: Colors.white54),
                            const SizedBox(height: 12),
                            Text(
                              'Menyiapkan kamera...',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Viewfinder Grid Overlay (Mockup 03)
            const Positioned.fill(child: CameraViewfinderOverlay()),

            // Top Bar: Tombol Kembali & Flash
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _isFlashOn ? AppColors.electricTeal : Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Bar: Galeri, Shutter, Balik Kamera & Toggle Mode
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Galeri
                      IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 30),
                        tooltip: 'Pilih dari Galeri',
                      ),
                      // Tombol Shutter Utama
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tombol Balik Kamera
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white, size: 30),
                        tooltip: 'Ganti Kamera',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Toggle Mode: [Kamera] | [Barcode] (Mockup 03)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.deepMidnightNavy.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.electricTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Kamera',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.deepMidnightNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Text(
                            'Barcode',
                            style: AppTextStyles.labelLarge.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
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
}
