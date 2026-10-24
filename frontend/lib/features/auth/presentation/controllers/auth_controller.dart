import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

/// State representasi status autentikasi Kura AI
class KuraAuthState {
  const KuraAuthState({
    this.user,
    this.isGuest = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final User? user;
  final bool isGuest;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  bool get isAuthenticated => user != null && !user!.isAnonymous;

  KuraAuthState copyWith({
    User? user,
    bool? isGuest,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return KuraAuthState(
      user: user ?? this.user,
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Provider state notifier autentikasi terpusat
final authControllerProvider =
    StateNotifierProvider<AuthNotifier, KuraAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<KuraAuthState> {
  AuthNotifier(this._repo)
      : super(
          KuraAuthState(
            user: _repo.currentUser,
            isGuest: _repo.isGuest,
          ),
        );

  final AuthRepository _repo;

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Masuk dengan email dan password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _repo.signInWithEmail(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isGuest: false,
        successMessage: 'Berhasil masuk ke Kura AI!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Mendaftar akun baru
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _repo.signUpWithEmail(email, password, fullName);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isGuest: false,
        successMessage: 'Pendaftaran berhasil! Akun Kura AI siap digunakan.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// 1-Click Guest Mode / Lewati sebagai tamu
  Future<void> continueAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.signInAsGuest();
      state = state.copyWith(
        isLoading: false,
        isGuest: true,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, isGuest: true);
    }
  }

  /// Mengirim kode pemulihan kata sandi
  Future<bool> sendResetCode(String email) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.resetPasswordForEmail(email);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Instruksi pemulihan telah dikirim ke $email',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Verifikasi OTP kode 6 digit
  Future<bool> verifyOtp(String email, String token) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _repo.verifyOTP(email, token);
      state = state.copyWith(
        isLoading: false,
        isGuest: false,
        successMessage: 'Verifikasi berhasil!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Logout akun
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    state = const KuraAuthState(isGuest: false);
  }
}
