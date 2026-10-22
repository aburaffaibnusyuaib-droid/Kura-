import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'gemini_service.dart';
import 'local_storage_service.dart';
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

/// Provider untuk LocalStorageService (SharedPreferences)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

/// Provider untuk mengambil riwayat Food Check secara reaktif
final foodCheckHistoryProvider =
    StateNotifierProvider<FoodCheckHistoryNotifier, List<dynamic>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FoodCheckHistoryNotifier(storage);
});

class FoodCheckHistoryNotifier extends StateNotifier<List<dynamic>> {
  FoodCheckHistoryNotifier(this._storage) : super([]) {
    loadHistory();
  }

  final LocalStorageService _storage;

  void loadHistory() {
    state = _storage.getFoodCheckHistory();
  }

  Future<void> refresh() async {
    loadHistory();
  }
}
