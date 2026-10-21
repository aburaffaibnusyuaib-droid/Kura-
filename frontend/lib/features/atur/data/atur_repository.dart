// TASK-05: Atur Module — Repository Interface

import '../domain/atur_models.dart';

/// Kontrak repository untuk modul Atur Makanan.
abstract interface class AturRepository {
  /// Menganalisis foto dan mengembalikan daftar bahan terdeteksi.
  /// Mendukung mode live Gemini Vision dan dynamic fallback engine.
  Future<List<DetectedIngredient>> analyzeIngredients(String? imagePath);

  /// Menghasilkan TEPAT 3 resep zero-waste dari [selectedIngredients].
  Future<List<Recipe>> generateRecipes(
    List<DetectedIngredient> selectedIngredients,
  );

  /// Menyimpan resep ke local cache dan memicu background sync ke Supabase.
  Future<bool> saveRecipe(Recipe recipe);
}
