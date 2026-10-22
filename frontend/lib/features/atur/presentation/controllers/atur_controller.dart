// TASK-05: Atur Module — State Controller (Riverpod)

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';
import '../../data/atur_hybrid_repository.dart';
import '../../data/atur_repository.dart';
import '../../domain/atur_models.dart';

/// Provider untuk repository hybrid (Live Gemini + Dynamic Fallback).
final aturRepositoryProvider = Provider<AturRepository>(
  (ref) => AturHybridRepository(
    geminiService: ref.watch(geminiServiceProvider),
    supabaseService: ref.watch(supabaseClientProvider),
    localStorageService: ref.watch(localStorageServiceProvider),
  ),
);

/// StateNotifier utama modul Atur.
final aturControllerProvider =
    StateNotifierProvider<AturNotifier, AturState>(
  (ref) => AturNotifier(ref.watch(aturRepositoryProvider)),
);

class AturNotifier extends StateNotifier<AturState> {
  AturNotifier(this._repository) : super(const AturState());

  final AturRepository _repository;

  // ── Permission ────────────────────────────────────────────────

  void setHasPermission({required bool granted}) {
    state = state.copyWith(hasPermission: granted);
  }

  // ── Kamera & Scan ─────────────────────────────────────────────

  void startScanning() {
    state = state.copyWith(
      status: AturAnalysisStatus.scanning,
      clearError: true,
    );
  }

  void capturePhoto(String imagePath) {
    HapticFeedback.lightImpact();
    state = state.copyWith(
      capturedImagePath: imagePath,
      status: AturAnalysisStatus.idle,
    );
  }

  void retakePhoto() {
    state = state.copyWith(
      clearImage: true,
      status: AturAnalysisStatus.scanning,
    );
  }

  // ── Analisis Bahan ────────────────────────────────────────────

  Future<void> analyzeIngredients() async {
    state = state.copyWith(
      status: AturAnalysisStatus.analyzing,
      clearError: true,
    );
    try {
      final ingredients = await _repository.analyzeIngredients(
        state.capturedImagePath,
      );
      if (ingredients.isEmpty) {
        state = state.copyWith(status: AturAnalysisStatus.failed);
      } else {
        state = state.copyWith(
          status: AturAnalysisStatus.detected,
          detectedIngredients: ingredients,
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(
        status: AturAnalysisStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Edit Bahan ────────────────────────────────────────────────

  void toggleIngredient(String id) {
    HapticFeedback.lightImpact();
    final updated = state.detectedIngredients.map((i) {
      return i.id == id ? i.copyWith(isSelected: !i.isSelected) : i;
    }).toList();
    state = state.copyWith(detectedIngredients: updated);
  }

  void addIngredient(String name) {
    if (name.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final newItem = DetectedIngredient(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      quantity: '1 porsi',
      emoji: '🍽️',
    );
    state = state.copyWith(
      detectedIngredients: [...state.detectedIngredients, newItem],
    );
  }

  void removeIngredient(String id) {
    HapticFeedback.lightImpact();
    final updated = state.detectedIngredients.where((i) => i.id != id).toList();
    state = state.copyWith(detectedIngredients: updated);
  }

  // ── Generate Resep ────────────────────────────────────────────

  Future<void> generateRecipes() async {
    if (state.selectedIngredients.isEmpty) return;
    HapticFeedback.lightImpact();
    state = state.copyWith(
      status: AturAnalysisStatus.analyzing,
      clearError: true,
    );
    try {
      final recipes = await _repository.generateRecipes(
        state.selectedIngredients,
      );
      state = state.copyWith(
        recipes: recipes,
        status: AturAnalysisStatus.detected,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        status: AturAnalysisStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Detail & Simpan Resep (Offline-First) ─────────────────────

  void selectRecipe(Recipe recipe) {
    HapticFeedback.lightImpact();
    final isSaved = state.savedRecipeIds.contains(recipe.id) || recipe.isSaved;
    state = state.copyWith(selectedRecipe: recipe.copyWith(isSaved: isSaved));
  }

  Future<bool> saveRecipe(Recipe recipe) async {
    HapticFeedback.lightImpact();
    final updatedSavedIds = Set<String>.from(state.savedRecipeIds)..add(recipe.id);
    final updatedRecipe = recipe.copyWith(isSaved: true);

    final updatedRecipes = state.recipes.map((r) {
      return r.id == recipe.id ? updatedRecipe : r;
    }).toList();

    state = state.copyWith(
      savedRecipeIds: updatedSavedIds,
      selectedRecipe: updatedRecipe,
      recipes: updatedRecipes,
    );

    return _repository.saveRecipe(recipe);
  }

  // ── Reset ─────────────────────────────────────────────────────

  void reset() {
    state = const AturState();
  }
}
