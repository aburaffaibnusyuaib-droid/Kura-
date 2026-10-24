import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

/// Layar Verifikasi OTP 6-Digit Kura AI (Screen 5)
/// Kotak PIN individual, auto-focus, paste capability, dan countdown timer kirim ulang 60s.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    this.email,
  });

  final String? email;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  Future<void> _handleVerify() async {
    final code = _otpCode;
    if (code.length < 6) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan 6 digit kode OTP secara lengkap.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.statusWarning,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final email = widget.email ?? '';
    final notifier = ref.read(authControllerProvider.notifier);
    final success = await notifier.verifyOtp(email, code);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi kode berhasil! Selamat datang.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF00B4A0),
        ),
      );
      context.go(AppRoutes.home);
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

  Future<void> _handleResend() async {
    if (!_canResend) return;
    HapticFeedback.lightImpact();

    final email = widget.email;
    if (email != null && email.isNotEmpty) {
      await ref.read(authControllerProvider.notifier).sendResetCode(email);
    }
    _startCountdown();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Menangani paste string angka (misal user paste "123456")
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && (index + i) < 6; i++) {
        _controllers[index + i].text = digits[i];
      }
      final nextIndex = (index + digits.length).clamp(0, 5);
      _focusNodes[nextIndex].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _handleVerify();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final emailDisplay = widget.email?.isNotEmpty == true
        ? widget.email!
        : 'email Anda';

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
          'Verifikasi OTP',
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
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Maskot OTP Flying Plane ─────────────────────────
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 160,
                            maxWidth: 160,
                          ),
                          child: Image.asset(
                            'assets/images/mascot_auth_otp.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.mark_email_read_rounded,
                              size: 80,
                              color: Color(0xFF00B4A0),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Headline & Subtitle ────────────────────────────
                      Text(
                        'Verifikasi Kode',
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
                          'Masukkan 6 digit kode yang telah dikirim ke $emailDisplay.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── 6 Digit PIN Boxes ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return _buildPinBox(index);
                        }),
                      ),

                      const SizedBox(height: 28),

                      // ── Tombol Verifikasi & Lanjutkan ──────────────────
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleVerify,
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
                                    'Verifikasi & Lanjutkan',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Countdown Timer & Kirim Ulang ──────────────────
                      Center(
                        child: _canResend
                            ? TextButton(
                                onPressed: _handleResend,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF00B4A0),
                                ),
                                child: Text(
                                  'Kirim Ulang Kode Sekarang',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: const Color(0xFF00B4A0),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Kirim ulang kode dalam ',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${_secondsRemaining}s',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00B4A0),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const Spacer(),

                      // ── Link Ganti Email / Batal ───────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 12),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              context.pop();
                            },
                            child: Text(
                              'Ganti Alamat Email',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
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

  Widget _buildPinBox(int index) {
    final controller = _controllers[index];
    final focusNode = _focusNodes[index];
    final hasValue = controller.text.isNotEmpty;

    return SizedBox(
      width: 44,
      height: 54,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (controller.text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].clear();
              setState(() {});
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focusNode.hasFocus
                  ? const Color(0xFF00B4A0)
                  : (hasValue
                      ? const Color(0xFF00B4A0).withAlpha(100)
                      : const Color(0xFFE5E7EB)),
              width: focusNode.hasFocus ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (val) => _onDigitChanged(index, val),
            ),
          ),
        ),
      ),
    );
  }
}
