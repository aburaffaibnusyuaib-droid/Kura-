import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Modern Cinematic Splash Screen untuk Kura.
///
/// Menampilkan animasi pembuka halus (Scale + Fade dengan Curves.easeOutBack),
/// logo card terpusat dengan soft teal glow shadow, serta handshake rute
/// sesi pengguna (Auth valid / Mode Tamu -> Home, lainnya -> Login).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeIn,
      ),
    );

    _animCtrl.forward();

    // Handshake navigasi setelah 2000ms
    _navTimer = Timer(const Duration(milliseconds: 2000), _handleNavigation);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    if (!mounted) return;

    // Cek sesi aktif Supabase
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {}

    // 1. Jika session aktif (user != null dan bukan anonim)
    if (user != null && !user.isAnonymous) {
      try {
        final supabase = Supabase.instance.client;
        final profile = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();

        String fullName = 'Pengguna';
        if (profile != null && profile['full_name'] != null) {
          final pName = (profile['full_name'] as String).trim();
          if (pName.isNotEmpty) fullName = pName;
        } else if (user.userMetadata?['full_name'] != null) {
          final mName = (user.userMetadata!['full_name'] as String).trim();
          if (mName.isNotEmpty) fullName = mName;
        } else {
          final cached = LocalStorageService.instance.getUserName();
          if (cached.isNotEmpty && cached != 'Pengguna') {
            fullName = cached;
          }
        }

        await LocalStorageService.instance.setAuthSessionActive(true);
        await LocalStorageService.instance.setGuestMode(false);
        await LocalStorageService.instance.setUserName(fullName);

        if (mounted) {
          ref.read(authControllerProvider.notifier).syncUserSession(
            user: user,
            fullName: fullName,
          );
        }
      } catch (_) {
        final cached = LocalStorageService.instance.getUserName();
        if (mounted) {
          ref.read(authControllerProvider.notifier).syncUserSession(
            user: user,
            fullName: cached,
          );
        }
      }

      if (mounted && context.mounted) {
        context.go(AppRoutes.home);
      }
      return;
    }

    // 2. Cek apakah pengguna berada di Mode Tamu
    bool isGuest = false;
    try {
      isGuest = LocalStorageService.instance.isGuestMode();
    } catch (_) {}

    if (isGuest) {
      if (mounted && context.mounted) {
        context.go(AppRoutes.home);
      }
      return;
    }

    // 3. Jika tidak ada session, arahkan ke layar Login
    if (mounted && context.mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          // Konten Branding Tengah Layar
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card Logo Rounded Putih
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2600B4A0),
                            blurRadius: 32,
                            spreadRadius: 4,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/logo_kura.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.eco_rounded,
                          size: 48,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Typografi Judul Kura
                    Text(
                      'Kura',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepMidnightNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle / Tagline
                    Text(
                      'Asisten Makanan Cerdas & Berkelanjutan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indikator Loading & Nomor Versi di Bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00B4A0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
