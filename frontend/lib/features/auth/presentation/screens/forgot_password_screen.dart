import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Layar Lupa Kata Sandi (Nonaktif).
/// Alur Password Recovery telah dihapus demi kesederhanaan autentikasi Kura AI.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.deepMidnightNavy,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: Text(
          'Pemulihan Sandi',
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: Color(0xFF00B4A0),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fitur Tidak Tersedia',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepMidnightNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fitur pemulihan kata sandi telah dinonaktifkan. Silakan gunakan akun yang sudah ada atau buat akun baru.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4A0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Kembali ke Layar Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
