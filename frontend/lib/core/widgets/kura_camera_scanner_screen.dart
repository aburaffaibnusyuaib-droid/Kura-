import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Komponen Kamera Pemindai Bersama (Unified Scanner Engine) untuk Kura AI.
/// Digunakan secara seragam oleh modul Food Check dan Zero Waste (Atur).
class KuraCameraScannerScreen extends StatefulWidget {
  const KuraCameraScannerScreen({
    super.key,
    required this.title,
    required this.hintTitle,
    required this.hintSubtitle,
    this.onImageCaptured,
    this.onBytesCaptured,
    this.onBack,
  });

  final String title;
  final String hintTitle;
  final String hintSubtitle;
  final void Function(String imagePath)? onImageCaptured;
  final void Function(Uint8List imageBytes)? onBytesCaptured;
  final VoidCallback? onBack;

  @override
  State<KuraCameraScannerScreen> createState() => _KuraCameraScannerScreenState();
}

class _KuraCameraScannerScreenState extends State<KuraCameraScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _hasPermission = true;
  bool _isFlashOn = false;
  bool _isCapturing = false;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Animasi Laser Scanning 60fps
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOut,
      ),
    );

    _initCameraFlow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _laserController.dispose();
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
      await _setupCameras();
    } else {
      setState(() => _hasPermission = false);
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
      ResolutionPreset.medium, // Efisien untuk upload AI & pas di layar 720x1612
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

  Future<void> _notifyCaptured(String path) async {
    if (widget.onImageCaptured != null) {
      widget.onImageCaptured!(path);
    }
    if (widget.onBytesCaptured != null) {
      try {
        final bytes = await File(path).readAsBytes();
        widget.onBytesCaptured!(bytes);
      } catch (_) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    HapticFeedback.lightImpact();

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        setState(() => _isCapturing = true);
        final file = await _cameraController!.takePicture();
        if (mounted) {
          await _notifyCaptured(file.path);
        }
      } catch (_) {
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
      await _notifyCaptured(picked.path);
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
      await _notifyCaptured(picked.path);
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
          // ── Live Camera Feed (Aspect ratio terjaga tanpa distorsi) ──
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

          // ── Viewfinder Rounded & Animasi Laser Scanning ─────────
          _buildViewfinderOverlay(),

          // ── Kontrol Atas (Back, Title Badge, Toggle Flash) ──────
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
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.of(context).maybePop();
                        }
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

                    // Badge Judul Mode
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
                            widget.title,
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

          // ── Kontrol Bawah (Galeri, Shutter Button Toska) ────────
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

                    // Placeholder Seimbang di Kanan
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

  Widget _buildViewfinderOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Kotak Bidik Rasio 4:3 (misal lebar 280, tinggi 210) atau persegi adaptif
        final boxWidth = (constraints.maxWidth * 0.76).clamp(240.0, 320.0);
        final boxHeight = boxWidth * (3.0 / 4.0);
        final left = (constraints.maxWidth - boxWidth) / 2;
        final top = (constraints.maxHeight - boxHeight) / 2 - 40;

        return Stack(
          children: [
            // Kotak Bidik Utama
            Positioned(
              left: left,
              top: top,
              width: boxWidth,
              height: boxHeight,
              child: Stack(
                children: [
                  // Border luar rounded transparan
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withAlpha(90),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricTeal.withAlpha(35),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Aksen Sudut Tebal di Keempat Pojok
                  ..._buildCorners(boxWidth, boxHeight),

                  // Garis Laser Scanning Halus
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimation.value * (boxHeight - 12),
                        left: 12,
                        right: 12,
                        child: child!,
                      );
                    },
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.electricTeal.withAlpha(120),
                            AppColors.electricTeal,
                            AppColors.electricTeal.withAlpha(120),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricTeal.withAlpha(180),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hint Text di Bawah Kotak Bidik
            Positioned(
              top: top + boxHeight + 20,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      widget.hintTitle,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.hintSubtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCorners(double width, double height) {
    const cornerLength = 26.0;
    const cornerWidth = 4.0;
    const radius = 22.0;
    const color = AppColors.electricTeal;

    return [
      // Top-Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(radius)),
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Top-Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(radius)),
            border: Border(
              top: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-Left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(radius)),
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              left: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
      // Bottom-Right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerLength,
          height: cornerLength,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(radius)),
            border: Border(
              bottom: BorderSide(color: color, width: cornerWidth),
              right: BorderSide(color: color, width: cornerWidth),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildPermissionDeniedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              size: 64,
              color: AppColors.sunsetOrange,
            ),
            const SizedBox(height: 16),
            Text(
              'Izin Kamera Dibutuhkan',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kura AI membutuhkan akses kamera untuk memindai makanan dan bahan masakan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: openAppSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricTeal,
                foregroundColor: AppColors.deepMidnightNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      ),
    );
  }
}
