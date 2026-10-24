import 'dart:async';
import 'dart:io';

import '../../../core/services/gemini_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/image_compressor.dart';
import '../domain/atur_models.dart';
import 'atur_repository.dart';

/// Implementasi AturRepository berbasis Google Gemini Vision API asli & Offline-First Storage.
/// Tidak ada data dummy hardcoded; seluruh deteksi bahan dan resep dihasilkan secara cerdas oleh AI.
final class AturHybridRepository implements AturRepository {
  AturHybridRepository({
    required this.geminiService,
    this.supabaseService,
    this.localStorageService,
  });

  final GeminiService geminiService;
  final SupabaseService? supabaseService;
  final LocalStorageService? localStorageService;

  @override
  Future<List<DetectedIngredient>> analyzeIngredients(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const [];
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw FileSystemException(
        'File foto bahan makanan tidak ditemukan: $imagePath',
      );
    }

    final rawBytes = await file.readAsBytes();
    final bytes = await ImageCompressor.compressBytes(rawBytes);
    final ingredients = await geminiService.detectIngredients(imageBytes: bytes);
    return ingredients;
  }

  @override
  Future<List<Recipe>> generateRecipes(
    List<DetectedIngredient> selectedIngredients,
  ) async {
    if (selectedIngredients.isEmpty) {
      return const [];
    }

    final recipes = await geminiService.generateZeroWasteRecipes(
      selectedIngredients: selectedIngredients,
    );

    // Tandai status isSaved jika resep sudah ada di LocalStorage
    final savedIds = localStorageService?.getSavedRecipeIds() ?? const <String>{};
    return recipes.map((r) {
      return r.copyWith(isSaved: savedIds.contains(r.id));
    }).toList();
  }

  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    // 1. Simpan ke local storage seketika (Offline-First)
    if (localStorageService != null) {
      await localStorageService!.saveRecipe(recipe);
    }

    // 2. Background sync ke Supabase secara asinkron tanpa memblokir UI
    if (supabaseService != null && supabaseService!.isConfigured) {
      unawaited(
        supabaseService!.saveRecipe({
          'recipe_id': recipe.id,
          'name': recipe.name,
          'duration': recipe.durationMinutes,
          'difficulty': recipe.difficulty,
          'calories': recipe.calories,
          'zero_waste_tip': recipe.zeroWasteTip,
          'saved_at': DateTime.now().toIso8601String(),
        }),
      );
    }

    return true;
  }
}
