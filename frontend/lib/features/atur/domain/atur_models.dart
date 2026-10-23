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
    this.imageKeyword,
    this.category,
  });

  final String id;
  final String name;
  final String quantity;
  final bool isSelected;
  final String emoji;
  final String? imageUrl;
  final String? imageKeyword;
  final String? category;

  DetectedIngredient copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isSelected,
    String? emoji,
    String? imageUrl,
    String? imageKeyword,
    String? category,
  }) {
    return DetectedIngredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      imageKeyword: imageKeyword ?? this.imageKeyword,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'isSelected': isSelected,
    'emoji': emoji,
    'imageUrl': imageUrl,
    'imageKeyword': imageKeyword,
    'category': category,
  };

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) {
    return DetectedIngredient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '1 porsi',
      isSelected: json['isSelected'] as bool? ?? true,
      emoji: json['emoji'] as String? ?? '🥗',
      imageUrl: json['imageUrl'] as String?,
      imageKeyword: json['imageKeyword'] as String? ??
          json['image_keyword'] as String? ??
          json['image_search_keyword'] as String?,
      category: json['category'] as String?,
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

  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'instruction': instruction,
  };

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['stepNumber'] as int? ?? json['step'] as int? ?? 1,
      instruction: json['instruction'] as String? ?? '',
    );
  }
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
    this.calories = 200,
    this.zeroWasteTip = '',
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
  final int calories;
  final String zeroWasteTip;
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
    int? calories,
    String? zeroWasteTip,
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
      calories: calories ?? this.calories,
      zeroWasteTip: zeroWasteTip ?? this.zeroWasteTip,
      colorHex: colorHex ?? this.colorHex,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'durationMinutes': durationMinutes,
    'difficulty': difficulty,
    'tags': tags,
    'ingredients': ingredients,
    'steps': steps.map((s) => s.toJson()).toList(),
    'servings': servings,
    'description': description,
    'calories': calories,
    'zeroWasteTip': zeroWasteTip,
    'colorHex': colorHex,
    'imageUrl': imageUrl,
    'isSaved': isSaved,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'] as List<dynamic>? ?? const [];
    final stepsList = rawSteps.map((s) {
      if (s is String) {
        return RecipeStep(stepNumber: rawSteps.indexOf(s) + 1, instruction: s);
      }
      return RecipeStep.fromJson(s as Map<String, dynamic>);
    }).toList();

    final rawTags = json['tags'] as List<dynamic>? ?? const ['Zero Waste', 'Praktis'];
    final rawIngredients = (json['ingredients'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    int parseSafeInt(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) {
        final digits = RegExp(r'\d+').firstMatch(val)?.group(0);
        if (digits != null) return int.tryParse(digits) ?? fallback;
      }
      return fallback;
    }

    return Recipe(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? json['title'] as String? ?? 'Resep Lezat',
      durationMinutes: parseSafeInt(json['durationMinutes'] ?? json['cook_time'], 15),
      difficulty: json['difficulty'] as String? ?? 'Mudah',
      tags: rawTags.map((e) => e.toString()).toList(),
      ingredients: rawIngredients,
      steps: stepsList,
      servings: parseSafeInt(json['servings'], 2),
      description: json['description'] as String? ?? '',
      calories: parseSafeInt(json['calories'], 200),
      zeroWasteTip: json['zeroWasteTip'] as String? ?? json['zero_waste_tip'] as String? ?? '',
      colorHex: json['colorHex'] as int? ?? 0xFF00CBA7,
      imageUrl: json['imageUrl'] as String?,
      isSaved: json['isSaved'] as bool? ?? false,
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
