// TASK-05: Atur Module — Repository Interface

import '../domain/atur_models.dart';

/// Kontrak repository untuk modul Atur.
abstract interface class AturRepository {
  /// Menganalisis foto dan mengembalikan daftar bahan terdeteksi.
  /// [imagePath] boleh null pada mock (diisi dummy).
  Future<List<DetectedIngredient>> analyzeIngredients(String? imagePath);

  /// Menghasilkan TEPAT 3 resep zero-waste dari [selectedIngredients].
  Future<List<Recipe>> generateRecipes(
    List<DetectedIngredient> selectedIngredients,
  );
}
