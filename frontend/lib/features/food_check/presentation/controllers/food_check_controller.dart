import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/food_check_models.dart';
import '../../data/food_check_repository.dart';
import '../../data/food_check_mock_repository.dart';

/// State lengkap untuk fitur Food Check.
final class FoodCheckState {
  const FoodCheckState({
    this.selectedFoodType = FoodType.packaged,
    this.capturedImagePath,
    this.questionnaireAnswers = const FreshFoodQuestionnaireAnswers(),
    this.isAnalyzing = false,
    this.analysisProgress = 0.0,
    this.result,
    this.selectedScenario = 'packaged_safe',
    this.hasCameraPermission = true,
    this.isOffline = false,
    this.errorMessage,
  });

  final FoodType selectedFoodType;
  final String? capturedImagePath;
  final FreshFoodQuestionnaireAnswers questionnaireAnswers;
  final bool isAnalyzing;
  final double analysisProgress;
  final FoodCheckResult? result;
  final String selectedScenario;
  final bool hasCameraPermission;
  final bool isOffline;
  final String? errorMessage;

  FoodCheckState copyWith({
    FoodType? selectedFoodType,
    String? capturedImagePath,
    FreshFoodQuestionnaireAnswers? questionnaireAnswers,
    bool? isAnalyzing,
    double? analysisProgress,
    FoodCheckResult? result,
    String? selectedScenario,
    bool? hasCameraPermission,
    bool? isOffline,
    String? errorMessage,
    bool clearImage = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return FoodCheckState(
      selectedFoodType: selectedFoodType ?? this.selectedFoodType,
      capturedImagePath: clearImage ? null : (capturedImagePath ?? this.capturedImagePath),
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisProgress: analysisProgress ?? this.analysisProgress,
      result: clearResult ? null : (result ?? this.result),
      selectedScenario: selectedScenario ?? this.selectedScenario,
      hasCameraPermission: hasCameraPermission ?? this.hasCameraPermission,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider repository Food Check (default ke Mock Repository).
final foodCheckRepositoryProvider = Provider<FoodCheckRepository>((ref) {
  return const FoodCheckMockRepository();
});

/// Notifier untuk mengelola state Food Check.
final class FoodCheckNotifier extends StateNotifier<FoodCheckState> {
  FoodCheckNotifier(this._repository) : super(const FoodCheckState());

  final FoodCheckRepository _repository;

  void selectFoodType(FoodType type) {
    state = state.copyWith(
      selectedFoodType: type,
      selectedScenario: type == FoodType.packaged ? 'packaged_safe' : 'fresh_safe',
    );
  }

  void setCapturedImage(String path) {
    state = state.copyWith(capturedImagePath: path);
  }

  void clearCapturedImage() {
    state = state.copyWith(clearImage: true, clearResult: true);
  }

  void updateQuestionnaire(FreshFoodQuestionnaireAnswers answers) {
    state = state.copyWith(questionnaireAnswers: answers);
  }

  void setCameraPermission(bool granted) {
    state = state.copyWith(hasCameraPermission: granted);
  }

  void setScenario(String scenarioKey) {
    state = state.copyWith(selectedScenario: scenarioKey);
  }

  void setOfflineState(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }

  /// Menjalankan simulasi proses analisis AI dengan animasi progress.
  Future<bool> startAnalysis() async {
    if (state.isOffline) {
      return false;
    }

    state = state.copyWith(isAnalyzing: true, analysisProgress: 0.1, clearError: true);

    // Animasi progress bertahap (0.1 -> 0.4 -> 0.7 -> 1.0)
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(analysisProgress: 0.4);

    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(analysisProgress: 0.75);

    try {
      final res = await _repository.assessFood(
        imagePath: state.capturedImagePath ?? 'assets/images/il_food_check_banner.png',
        foodType: state.selectedFoodType,
        questionnaireAnswers: state.questionnaireAnswers,
        forcedScenario: state.selectedScenario,
      );

      await Future<void>.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(
        analysisProgress: 1.0,
        isAnalyzing: false,
        result: res,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Terjadi kesalahan saat memproses gambar.',
      );
      return false;
    }
  }

  void reset() {
    state = FoodCheckState(
      selectedFoodType: state.selectedFoodType,
      selectedScenario: state.selectedFoodType == FoodType.packaged ? 'packaged_safe' : 'fresh_safe',
    );
  }
}

/// Provider global Food Check.
final foodCheckControllerProvider =
    StateNotifierProvider<FoodCheckNotifier, FoodCheckState>((ref) {
  final repo = ref.watch(foodCheckRepositoryProvider);
  return FoodCheckNotifier(repo);
});
