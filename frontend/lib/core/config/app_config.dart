import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi lingkungan aplikasi yang dimuat dari `.env`.
/// TIDAK ADA hardcoded API key atau kredensial di kode sumber.
abstract final class AppConfig {
  /// Mengambil Gemini API Key dari .env secara aman
  static String get geminiApiKey =>
      dotenv.isInitialized ? (dotenv.env['GEMINI_API_KEY'] ?? '') : '';

  /// Mengambil Supabase URL dari .env secara aman
  static String get supabaseUrl {
    if (!dotenv.isInitialized) return '';
    final raw = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    // Auto-derive project URL jika format token/ref
    final anon = supabaseAnonKey;
    if (anon.contains('.')) {
      try {
        final parts = anon.split('.');
        if (parts.length > 1) {
          final payload =
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final ref = data['ref'] as String?;
          if (ref != null && ref.isNotEmpty) {
            return 'https://$ref.supabase.co';
          }
        }
      } catch (_) {}
    }
    return raw;
  }

  /// Mengambil Supabase Anon Key dari .env secara aman
  static String get supabaseAnonKey =>
      dotenv.isInitialized ? (dotenv.env['SUPABASE_ANON_KEY'] ?? '') : '';

  /// Mengecek apakah konfigurasi Gemini siap
  static bool get hasGeminiKey => geminiApiKey.trim().isNotEmpty;

  /// Mengecek apakah konfigurasi Supabase siap
  static bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
