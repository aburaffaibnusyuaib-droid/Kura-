import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/local_storage_service.dart';

/// Provider untuk instance [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Repository autentikasi terpadu untuk Kura AI menggunakan Supabase Auth.
/// Menyediakan dukungan Email/Password dan Mode Tamu (Guest Mode).
class AuthRepository {
  AuthRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;
  LocalStorageService get storage => _storage;

  /// Mengambil instance SupabaseClient secara aman (menghindari exception saat test/offline)
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get client => _client;

  /// Pengguna yang sedang masuk saat ini
  User? get currentUser => _client?.auth.currentUser;

  /// Memeriksa apakah sesi saat ini adalah mode tamu (Guest)
  bool get isGuest {
    final user = currentUser;
    if (user != null && !user.isAnonymous) return false;
    if (_storage.isAuthSessionActive()) return false;
    if (user != null && user.isAnonymous) return true;
    return _storage.isGuestMode();
  }

  /// Stream perubahan status autentikasi untuk GoRouter refreshListenable
  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  /// Masuk menggunakan Email dan Kata Sandi
  Future<User?> signInWithEmail(String email, String password) async {
    final client = _client;
    if (client == null) {
      throw const SocketException('Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.');
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await _storage.setGuestMode(false);
        await _storage.setAuthSessionActive(true);

        String? profileFullName;
        try {
          final profile = await client
              .from('profiles')
              .select('full_name')
              .eq('id', user.id)
              .maybeSingle();
          if (profile != null && profile['full_name'] != null) {
            profileFullName = profile['full_name'] as String;
          }
        } catch (_) {}

        final fullName = (profileFullName != null && profileFullName.trim().isNotEmpty)
            ? profileFullName.trim()
            : (user.userMetadata?['full_name'] as String? ?? 'Pengguna');

        await _storage.setUserName(fullName);
      }
      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on SocketException catch (_) {
      throw const SocketException('Koneksi internet bermasalah. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Gagal masuk: ${e.toString()}');
    }
  }

  /// Mendaftar akun baru dengan Nama Lengkap, Email, dan Kata Sandi
  /// Konfigurasi Confirm Email nonaktif: sesi dan user langsung terikat.
  Future<dynamic> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  /// Mendaftar akun baru dengan Nama Lengkap, Email, dan Kata Sandi
  Future<dynamic> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final supabase = _client;
    if (supabase == null) {
      throw const SocketException('Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.');
    }

    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

      if (response.user != null) {
        await _storage.setGuestMode(false);
        await _storage.setAuthSessionActive(true);
        await _storage.setUserName(fullName.trim());
        return response.user;
      }

      throw Exception("Gagal mendaftarkan akun. Silakan coba lagi.");
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on SocketException catch (_) {
      throw const SocketException('Koneksi internet bermasalah. Periksa jaringan Anda.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan sistem atau email sudah terdaftar.');
    }
  }

  /// 1-Click Guest Mode / Masuk sebagai Tamu
  /// Membuat sesi anonim di Supabase (jika aktif) dan mengaktifkan guest flag di local storage
  Future<void> signInAsGuest() async {
    await _storage.setGuestMode(true);
    await _storage.setAuthSessionActive(false);
    await _storage.setUserName('Tamu Kura');

    final client = _client;
    if (client != null && client.auth.currentUser == null) {
      try {
        await client.auth.signInAnonymously();
      } catch (_) {
        // Abaikan jika anonymous auth dinonaktifkan di dashboard, flag lokal tetap aktif
      }
    }
  }

  /// Keluar dari sesi akun saat ini
  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    await _storage.setAuthSessionActive(false);
    await _storage.setGuestMode(false);
    await _storage.setUserName('Pengguna');
    await _storage.clearAllCacheAndLocalHistory();
  }

  /// Menerjemahkan pesan error Supabase Auth ke Bahasa Indonesia yang ramah pengguna
  Exception _handleAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials') ||
        msg.contains('wrong password')) {
      return Exception('Email atau kata sandi yang Anda masukkan salah.');
    } else if (msg.contains('user already registered') ||
        msg.contains('already exists')) {
      return Exception('Email ini sudah terdaftar. Silakan masuk.');
    } else if (msg.contains('password should be at least')) {
      return Exception('Kata sandi minimal harus 6 karakter.');
    } else if (msg.contains('invalid email')) {
      return Exception('Format alamat email tidak valid.');
    } else if (msg.contains('token has expired') ||
        msg.contains('otp expired') ||
        msg.contains('invalid token')) {
      return Exception('Kode OTP telah kedaluwarsa atau tidak valid.');
    } else if (msg.contains('rate limit')) {
      return Exception('Terlalu banyak percobaan. Tunggu beberapa saat lagi.');
    }
    return Exception(e.message);
  }
}
