import 'package:supabase_flutter/supabase_flutter.dart';

/// Service client untuk integrasi Supabase secara aman.
/// Tidak ada kredensial hardcoded; konfigurasi diambil via AppConfig/dotenv.
class SupabaseService {
  SupabaseService({
    required this.url,
    required this.anonKey,
  });

  final String url;
  final String anonKey;

  bool get isConfigured => url.trim().isNotEmpty && anonKey.trim().isNotEmpty;

  /// Supabase client instance (jika Supabase sudah diinisialisasi)
  SupabaseClient? get _client {
    try {
      if (isConfigured) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  /// Memastikan status autentikasi anonim / tamu (guest auth fallback).
  Future<void> ensureAnonymousAuth() async {
    final client = _client;
    if (client == null) return;

    try {
      if (client.auth.currentUser == null) {
        await client.auth.signInAnonymously();
      }
    } catch (_) {
      // Abaikan jika anonymous sign-in belum diaktifkan di dasbor Supabase atau sedang offline
    }
  }

  /// Menyimpan resep ke database Supabase secara asinkron di latar belakang.
  Future<bool> saveRecipe(Map<String, dynamic> recipeData) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client.from('saved_recipes').insert(recipeData);
      return true;
    } catch (_) {
      // Fail silently for background sync
      return false;
    }
  }

  /// Menyimpan riwayat scan Food Check ke Supabase di latar belakang (opsional).
  Future<bool> saveFoodCheck(Map<String, dynamic> checkData) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client.from('food_checks').insert(checkData);
      return true;
    } catch (_) {
      return false;
    }
  }
}
