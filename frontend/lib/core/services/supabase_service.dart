import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service client untuk integrasi Supabase REST API secara aman.
/// Tidak ada kredensial hardcoded; nilai diambil dari AppConfig/dotenv.
class SupabaseService {
  SupabaseService({
    required this.url,
    required this.anonKey,
  });

  final String url;
  final String anonKey;

  bool get isConfigured => url.trim().isNotEmpty && anonKey.trim().isNotEmpty;

  /// Menyimpan resep ke database Supabase (background sync).
  Future<bool> saveRecipe(Map<String, dynamic> recipeData) async {
    if (!isConfigured) {
      // Offline / belum dikonfigurasi - sukses lokal
      return false;
    }

    try {
      final endpoint = Uri.parse('$url/rest/v1/saved_recipes');
      final response = await http
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json',
              'apikey': anonKey,
              'Authorization': 'Bearer $anonKey',
              'Prefer': 'return=minimal',
            },
            body: jsonEncode(recipeData),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      // Fail silently for background sync
      return false;
    }
  }
}
