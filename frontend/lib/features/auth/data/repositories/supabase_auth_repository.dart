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
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final client = _supabaseClient;
    if (client == null) {
      throw "Layanan autentikasi belum terhubung. Periksa konfigurasi Supabase.";
    }

    try {
      final response = await client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

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
