import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import '../../../../app/router.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/auth_user.dart';

/// State representasi status autentikasi Kura AI
class KuraAuthState {
  const KuraAuthState({
    this.user,
    this.isGuest = false,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.userName,
  });

  final User? user;
  final bool isGuest;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? userName;

  bool get isAuthenticated =>
      (user != null && !user!.isAnonymous) ||
      LocalStorageService.instance.isAuthSessionActive();

  KuraAuthState copyWith({
    User? user,
    bool? isGuest,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? userName,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return KuraAuthState(
      user: user ?? this.user,
      isGuest: isGuest ?? this.isGuest,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      userName: userName ?? this.userName,
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
            userName: LocalStorageService.instance.getUserName(),
          ),
        ) {
    if (_repo.currentUser != null && !_repo.currentUser!.isAnonymous) {
      fetchAndSyncProfile();
    }
  }

  final AuthRepository _repo;

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Sinkronisasi data sesi dan profil pengguna aktif (dipanggil saat startup / auto-login)
  void syncUserSession({
    required User user,
    required String fullName,
  }) {
    state = state.copyWith(
      user: user,
      isGuest: false,
      userName: fullName,
      isLoading: false,
    );
  }

  /// Memuat profil pengguna aktif langsung dari Supabase profiles table
  Future<void> fetchAndSyncProfile() async {
    try {
      final client = _repo.client;
      if (client == null) return;
      final user = client.auth.currentUser;
      if (user != null && !user.isAnonymous) {
        String? profileName;
        try {
          final profile = await client
              .from('profiles')
              .select('full_name')
              .eq('id', user.id)
              .maybeSingle();
          if (profile != null && profile['full_name'] != null) {
            profileName = profile['full_name'] as String;
          }
        } catch (_) {}

        final resolvedName = (profileName != null && profileName.trim().isNotEmpty)
            ? profileName.trim()
            : (user.userMetadata?['full_name'] as String? ?? 'Pengguna');

        await LocalStorageService.instance.setAuthSessionActive(true);
        await LocalStorageService.instance.setGuestMode(false);
        await LocalStorageService.instance.setUserName(resolvedName);

        syncUserSession(user: user, fullName: resolvedName);
      }
    } catch (_) {}
  }

  /// Masuk dengan email dan password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final dynamic authResult = await _repo.signInWithEmail(email, password);
      User? user;
      String? fullName;
      if (authResult is AuthUser) {
        user = authResult.rawUser;
        fullName = authResult.fullName;
      } else if (authResult is User) {
        user = authResult;
        fullName = user.userMetadata?['full_name'] as String?;
      }

      // Ambil nama dari profiles jika tersedia
      final client = _repo.client;
      if (client != null && user != null) {
        try {
          final profile = await client
              .from('profiles')
              .select('full_name')
              .eq('id', user.id)
              .maybeSingle();
          if (profile != null && profile['full_name'] != null) {
            final pName = (profile['full_name'] as String).trim();
            if (pName.isNotEmpty) fullName = pName;
          }
        } catch (_) {}
      }

      final storedName = LocalStorageService.instance.getUserName();
      final resolvedName = (fullName != null && fullName.trim().isNotEmpty)
          ? fullName.trim()
          : ((storedName.isNotEmpty && storedName != 'Pengguna')
              ? storedName
              : 'Pengguna');

      await LocalStorageService.instance.setGuestMode(false);
      await LocalStorageService.instance.setAuthSessionActive(true);
      await LocalStorageService.instance.setUserName(resolvedName);
      state = state.copyWith(
        isLoading: false,
        user: user ?? _repo.currentUser,
        isGuest: false,
        userName: resolvedName,
        successMessage: 'Berhasil masuk ke Kura AI!',
      );
      routerNotifier.notify();
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
      final dynamic authResult = await _repo.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      User? user;
      if (authResult is AuthUser) {
        user = authResult.rawUser;
      } else if (authResult is User) {
        user = authResult;
      }
      await LocalStorageService.instance.setGuestMode(false);
      await LocalStorageService.instance.setAuthSessionActive(true);
      await LocalStorageService.instance.setUserName(fullName.trim());
      state = state.copyWith(
        isLoading: false,
        user: user ?? _repo.currentUser,
        isGuest: false,
        userName: fullName.trim(),
        successMessage: 'Pendaftaran berhasil! Akun Kura AI siap digunakan.',
      );
      routerNotifier.notify();
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
      await LocalStorageService.instance.setGuestMode(true);
      await LocalStorageService.instance.setAuthSessionActive(false);
      state = state.copyWith(
        isLoading: false,
        isGuest: true,
        user: null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, isGuest: true, user: null);
    }
    routerNotifier.notify();
  }

  /// Logout akun
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repo.signOut();
    await LocalStorageService.instance.clearAllCacheAndLocalHistory();
    await LocalStorageService.instance.setAuthSessionActive(false);
    await LocalStorageService.instance.setGuestMode(false);
    await LocalStorageService.instance.setUserName('Pengguna');
    state = const KuraAuthState(isGuest: false, userName: 'Pengguna');
    routerNotifier.notify();
  }

  /// Alias signOut untuk konsistensi
  Future<void> signOut() => logout();
}
