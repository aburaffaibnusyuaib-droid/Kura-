// TASK-05: Atur Module — Domain Models

/// Status analisis AI untuk deteksi bahan makanan.
enum AturAnalysisStatus {
  idle,
  requestingPermission,
  scanning,
  analyzing,
  detected,
  failed,
}

/// Satu bahan makanan yang terdeteksi / dipilih oleh pengguna.
final class DetectedIngredient {
  const DetectedIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.isSelected = true,
    this.emoji = '🥗',
    this.imageUrl,
  });

  final String id;
  final String name;
  final String quantity;
  final bool isSelected;
  final String emoji;
  final String? imageUrl;

  DetectedIngredient copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isSelected,
    String? emoji,
    String? imageUrl,
  }) {
    return DetectedIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Satu langkah memasak dalam resep.
final class RecipeStep {
  const RecipeStep({
    required this.stepNumber,
    required this.instruction,
  });

  final int stepNumber;
  final String instruction;
}

/// Model resep zero-waste dengan foto masakan asli dan status simpan.
final class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.difficulty,
    required this.tags,
    required this.ingredients,
    required this.steps,
    required this.servings,
    required this.description,
    this.colorHex = 0xFF00CBA7,
    this.imageUrl,
    this.isSaved = false,
  });

  final String id;
  final String name;
  final int durationMinutes;
  final String difficulty; // 'Mudah' | 'Sedang' | 'Sulit'
  final List<String> tags;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final int servings;
  final String description;
  final int colorHex;
  final String? imageUrl;
  final bool isSaved;

  Recipe copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    String? difficulty,
    List<String>? tags,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    int? servings,
    String? description,
    int? colorHex,
    String? imageUrl,
    bool? isSaved,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      servings: servings ?? this.servings,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// State utama untuk seluruh alur modul Atur.
final class AturState {
  const AturState({
    this.status = AturAnalysisStatus.idle,
    this.detectedIngredients = const [],
    this.recipes = const [],
    this.errorMessage,
    this.capturedImagePath,
    this.selectedRecipe,
    this.hasPermission = false,
    this.savedRecipeIds = const {},
  });

  final AturAnalysisStatus status;
  final List<DetectedIngredient> detectedIngredients;
  final List<Recipe> recipes;
  final String? errorMessage;
  final String? capturedImagePath;
  final Recipe? selectedRecipe;
  final bool hasPermission;
  final Set<String> savedRecipeIds;

  /// Bahan yang aktif dipilih pengguna.
  List<DetectedIngredient> get selectedIngredients =>
      detectedIngredients.where((i) => i.isSelected).toList();

  AturState copyWith({
    AturAnalysisStatus? status,
    List<DetectedIngredient>? detectedIngredients,
    List<Recipe>? recipes,
    String? errorMessage,
    String? capturedImagePath,
    Recipe? selectedRecipe,
    bool? hasPermission,
    Set<String>? savedRecipeIds,
    bool clearError = false,
    bool clearImage = false,
    bool clearRecipe = false,
  }) {
    return AturState(
      status: status ?? this.status,
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      recipes: recipes ?? this.recipes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      capturedImagePath:
          clearImage ? null : (capturedImagePath ?? this.capturedImagePath),
      selectedRecipe:
          clearRecipe ? null : (selectedRecipe ?? this.selectedRecipe),
      hasPermission: hasPermission ?? this.hasPermission,
      savedRecipeIds: savedRecipeIds ?? this.savedRecipeIds,
    );
  }
}
