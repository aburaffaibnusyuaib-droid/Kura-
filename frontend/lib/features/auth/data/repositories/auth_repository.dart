import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/local_storage_service.dart';

/// Provider untuk instance [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Repository autentikasi terpadu untuk Kura AI menggunakan Supabase Auth.
/// Menyediakan dukungan Email/Password, Anonymous/Guest Mode, Reset Password, dan OTP.
class AuthRepository {
  AuthRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;

  /// Mengambil instance SupabaseClient secara aman (menghindari exception saat test/offline)
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Pengguna yang sedang masuk saat ini
  User? get currentUser => _client?.auth.currentUser;

  /// Memeriksa apakah sesi saat ini adalah mode tamu (Guest)
  bool get isGuest {
    final user = currentUser;
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
        final fullName = user.userMetadata?['full_name'] as String?;
        if (fullName != null && fullName.isNotEmpty) {
          await _storage.setUserName(fullName);
        }
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
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    final client = _client;
    if (client == null) {
      throw const SocketException('Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.');
    }

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      final user = response.user;
      if (user != null) {
        await _storage.setGuestMode(false);
        await _storage.setUserName(fullName.trim());
      }
      return user;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on SocketException catch (_) {
      throw const SocketException('Koneksi internet bermasalah. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Gagal mendaftar: ${e.toString()}');
    }
  }

  /// 1-Click Guest Mode / Masuk sebagai Tamu
  /// Membuat sesi anonim di Supabase (jika aktif) dan mengaktifkan guest flag di local storage
  Future<void> signInAsGuest() async {
    await _storage.setGuestMode(true);
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

  /// Mengirim email pemulihan instruksi / kode reset password
  Future<void> resetPasswordForEmail(String email) async {
    final client = _client;
    if (client == null) {
      throw const SocketException('Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.');
    }

    try {
      await client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on SocketException catch (_) {
      throw const SocketException('Koneksi internet bermasalah. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Gagal mengirim instruksi pemulihan: ${e.toString()}');
    }
  }

  /// Verifikasi 6 digit OTP / Token Pemulihan
  Future<void> verifyOTP(String email, String token) async {
    final client = _client;
    if (client == null) {
      throw const SocketException('Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.');
    }

    try {
      // Coba verifikasi tipe recovery (reset password), jika gagal fallback ke email/signup
      try {
        await client.auth.verifyOTP(
          email: email.trim(),
          token: token.trim(),
          type: OtpType.recovery,
        );
      } catch (_) {
        await client.auth.verifyOTP(
          email: email.trim(),
          token: token.trim(),
          type: OtpType.email,
        );
      }
      await _storage.setGuestMode(false);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } on SocketException catch (_) {
      throw const SocketException('Koneksi internet bermasalah. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Kode verifikasi tidak valid atau kedaluwarsa.');
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
    await _storage.setGuestMode(false);
    await _storage.setUserName('Pengguna');
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
