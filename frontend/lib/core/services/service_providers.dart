import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'gemini_service.dart';
import 'supabase_service.dart';

/// Provider untuk GeminiService berbasis konfigurasi .env
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: AppConfig.geminiApiKey);
});

/// Provider untuk SupabaseService/Client berbasis konfigurasi .env
final supabaseClientProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
});
