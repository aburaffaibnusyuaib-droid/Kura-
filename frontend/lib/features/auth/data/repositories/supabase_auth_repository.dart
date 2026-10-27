/// Implementasi SupabaseAuthRepository untuk autentikasi Supabase Kura AI.
library;

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../domain/auth_user.dart';
import 'auth_repository.dart';

export 'auth_repository.dart';

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository({
    this.supabase,
    super.storage,
  });

  final SupabaseClient? supabase;

  SupabaseClient? get _supabaseClient => supabase ?? super.client;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final client = _supabaseClient;
    if (client == null) {
      throw "Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.";
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await storage.setGuestMode(false);
        await storage.setAuthSessionActive(true);

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

        final fullName = (profileName != null && profileName.trim().isNotEmpty)
            ? profileName.trim()
            : (user.userMetadata?['full_name'] as String? ?? 'Pengguna');

        await storage.setUserName(fullName);
        return user;
      }
      throw "Gagal masuk: Pengguna tidak ditemukan.";
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      if (e is String) rethrow;
      throw "Gagal masuk: ${e.toString()}";
    }
  }

  /// Registrasi akun baru dengan metadata full_name untuk Supabase SQL Trigger
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

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final supabase = _supabaseClient;
    if (supabase == null) {
      throw "Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.";
    }

    try {
      final response = await supabase.auth.signUp(email: email, password: password, data: {'full_name': fullName});

      if (response.user != null) {
        await storage.setGuestMode(false);
        await storage.setAuthSessionActive(true);
        await storage.setUserName(fullName.trim());
        // Sesi langsung aktif
        return AuthUser.fromSupabase(response.user!, fullName: fullName);
      }
      throw "Gagal mendaftarkan akun. Silakan coba lagi.";
    } catch (e) {
      throw "Terjadi kesalahan sistem atau email sudah terdaftar.";
    }
  }
}
