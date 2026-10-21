import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi lingkungan aplikasi yang dimuat dari `.env`.
/// TIDAK ADA hardcoded API key atau kredensial di kode sumber.
abstract final class AppConfig {
  /// Mengambil Gemini API Key dari .env secara aman
  static String get geminiApiKey =>
      dotenv.isInitialized ? (dotenv.env['GEMINI_API_KEY'] ?? '') : '';

  /// Mengambil Supabase URL dari .env secara aman
  static String get supabaseUrl =>
      dotenv.isInitialized ? (dotenv.env['SUPABASE_URL'] ?? '') : '';

  /// Mengambil Supabase Anon Key dari .env secara aman
  static String get supabaseAnonKey =>
      dotenv.isInitialized ? (dotenv.env['SUPABASE_ANON_KEY'] ?? '') : '';

  /// Mengecek apakah konfigurasi Gemini siap
  static bool get hasGeminiKey => geminiApiKey.trim().isNotEmpty;

  /// Mengecek apakah konfigurasi Supabase siap
  static bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
