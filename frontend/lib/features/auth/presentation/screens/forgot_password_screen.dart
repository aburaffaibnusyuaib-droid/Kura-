import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

/// Layar Lupa Kata Sandi Kura AI (Screen 4)
/// Meminta email terdaftar dan mengirim instruksi kode verifikasi / reset password.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final email = _emailCtrl.text.trim();
    final notifier = ref.read(authControllerProvider.notifier);
    final success = await notifier.sendResetCode(email);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode instruksi pemulihan telah dikirim ke $email'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF00B4A0),
        ),
      );
      // Navigasi ke layar OTP dengan meneruskan parameter email
      context.push('${AppRoutes.otp}?email=${Uri.encodeComponent(email)}');
    } else if (mounted) {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
            context.pop();
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = MediaQuery.of(context).size.width > 600;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32.0 : 20.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32).clamp(0, double.infinity),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        const SizedBox(height: 8),

                        // ── Maskot Lupa Password ───────────────────────────
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 160,
                              maxWidth: 160,
                            ),
                            child: Image.asset(
                              'assets/images/mascot_auth_forgot_password.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.help_outline_rounded,
                                size: 80,
                                color: Color(0xFF00B4A0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Headline & Subtitle ────────────────────────────
                        Text(
                          'Lupa Sandi?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepMidnightNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Tenang, Kura bantu pulihkan akses akunmu. Masukkan email terdaftarmu di bawah ini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Field Email ────────────────────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat Email Terdaftar',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepMidnightNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Masukkan email Anda';
                                  }
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFF1F2937),
                                ),
                                decoration: const InputDecoration(
                                  icon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF00B4A0),
                                    size: 20,
                                  ),
                                  hintText: 'nama@email.com',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 13.5,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  filled: false,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Tombol Kirim Instruksi ─────────────────────────
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                authState.isLoading ? null : _handleSendReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4A0),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0x3300B4A0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Kirim Instruksi Pemulihan',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Kembali ke Login ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 16,
                                color: Color(0xFF00B4A0),
                              ),
                              label: Text(
                                'Kembali ke Layar Masuk',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: const Color(0xFF00B4A0),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          },
        ),
      ),
    );
  }
}
