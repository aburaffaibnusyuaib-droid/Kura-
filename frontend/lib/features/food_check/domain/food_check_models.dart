/// Model data untuk domain Food Check.
library;

/// Jenis makanan yang diperiksa.
enum FoodType {
  packaged('Makanan Kemasan', 'Cek tanggal kedaluwarsa, barcode, dan kondisi kemasan.'),
  fresh('Makanan Segar', 'Cek kondisi visual dan jawab pertanyaan singkat dari AI.');

  const FoodType(this.label, this.description);
  final String label;
  final String description;
}

/// Status evaluasi kelayakan makanan.
enum FoodCheckStatus {
  looksOk(
    label: 'Aman Dikonsumsi',
    code: 'LOOKS_OK',
    description: 'Tidak ditemukan tanda kerusakan visual yang mengkhawatirkan.',
  ),
  checkFurther(
    label: 'Perlu Diperiksa',
    code: 'CHECK_FURTHER',
    description: 'Terdapat tanda fisik atau tanggal yang memerlukan pemeriksaan lebih lanjut.',
  ),
  avoidEating(
    label: 'Hindari Konsumsi',
    code: 'AVOID_EATING',
    description: 'Ditemukan tanda kerusakan atau kedaluwarsa yang berisiko bagi kesehatan.',
  ),
  unableToAssess(
    label: 'Belum Dapat Dipastikan',
    code: 'UNABLE_TO_ASSESS',
    description: 'Informasi visual tidak mencukupi untuk penilaian yang akurat.',
  );

  const FoodCheckStatus({
    required this.label,
    required this.code,
    required this.description,
  });

  final String label;
  final String code;
  final String description;
}

/// Jawaban kuesioner kondisi makanan segar.
final class FreshFoodQuestionnaireAnswers {
  const FreshFoodQuestionnaireAnswers({
    this.texture = '',
    this.aroma = '',
    this.colorChange = '',
    this.storageDuration = '',
  });

  final String texture;
  final String aroma;
  final String colorChange;
  final String storageDuration;

  FreshFoodQuestionnaireAnswers copyWith({
    String? texture,
    String? aroma,
    String? colorChange,
    String? storageDuration,
  }) {
    return FreshFoodQuestionnaireAnswers(
      texture: texture ?? this.texture,
      aroma: aroma ?? this.aroma,
      colorChange: colorChange ?? this.colorChange,
      storageDuration: storageDuration ?? this.storageDuration,
    );
  }

  Map<String, dynamic> toJson() => {
    'texture': texture,
    'aroma': aroma,
    'colorChange': colorChange,
    'storageDuration': storageDuration,
  };

  factory FreshFoodQuestionnaireAnswers.fromJson(Map<String, dynamic> json) {
    return FreshFoodQuestionnaireAnswers(
      texture: json['texture'] as String? ?? '',
      aroma: json['aroma'] as String? ?? '',
      colorChange: json['colorChange'] as String? ?? '',
      storageDuration: json['storageDuration'] as String? ?? '',
    );
  }
}

/// Temuan visual hasil inspeksi AI.
final class VisualFinding {
  const VisualFinding({
    required this.aspect,
    required this.detail,
  });

  final String aspect;
  final String detail;

  Map<String, dynamic> toJson() => {
    'aspect': aspect,
    'detail': detail,
  };

  factory VisualFinding.fromJson(Map<String, dynamic> json) {
    return VisualFinding(
      aspect: json['aspect'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );
  }
}

/// Pertanyaan lanjutan sensorik jika status UNCERTAIN pada makanan segar.
final class FollowupQuestion {
  const FollowupQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  final String id;
  final String question;
  final List<String> options;

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
  };

  factory FollowupQuestion.fromJson(Map<String, dynamic> json) {
    return FollowupQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// Hasil analisis Food Check.
final class FoodCheckResult {
  const FoodCheckResult({
    required this.id,
    required this.foodType,
    required this.status,
    required this.productName,
    required this.categoryName,
    required this.imagePath,
    required this.aiAdvice,
    this.confidenceScore = 0.90,
    this.headline = '',
    this.visualFindings = const [],
    this.safetyRecommendations = const [],
    this.followupQuestions = const [],
    this.scannedAt,
    this.expiryDate,
    this.barcode,
    this.packagingCondition,
    this.composition,
    this.visualCondition,
    this.texture,
    this.aroma,
    this.storageRecommendation,
    this.shelfLifeEstimate,
    this.isDemo = false,
  });

  final String id;
  final FoodType foodType;
  final FoodCheckStatus status;
  final String productName;
  final String categoryName;
  final String imagePath;
  final String aiAdvice;
  final double confidenceScore;
  final String headline;
  final List<VisualFinding> visualFindings;
  final List<String> safetyRecommendations;
  final List<FollowupQuestion> followupQuestions;
  final DateTime? scannedAt;
  final String? expiryDate;
  final String? barcode;
  final String? packagingCondition;
  final String? composition;
  final String? visualCondition;
  final String? texture;
  final String? aroma;
  final String? storageRecommendation;
  final String? shelfLifeEstimate;
  final bool isDemo;

  FoodCheckResult copyWith({
    String? id,
    FoodType? foodType,
    FoodCheckStatus? status,
    String? productName,
    String? categoryName,
    String? imagePath,
    String? aiAdvice,
    double? confidenceScore,
    String? headline,
    List<VisualFinding>? visualFindings,
    List<String>? safetyRecommendations,
    List<FollowupQuestion>? followupQuestions,
    DateTime? scannedAt,
    String? expiryDate,
    String? barcode,
    String? packagingCondition,
    String? composition,
    String? visualCondition,
    String? texture,
    String? aroma,
    String? storageRecommendation,
    String? shelfLifeEstimate,
    bool? isDemo,
  }) {
    return FoodCheckResult(
      id: id ?? this.id,
      foodType: foodType ?? this.foodType,
      status: status ?? this.status,
      productName: productName ?? this.productName,
      categoryName: categoryName ?? this.categoryName,
      imagePath: imagePath ?? this.imagePath,
      aiAdvice: aiAdvice ?? this.aiAdvice,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      headline: headline ?? this.headline,
      visualFindings: visualFindings ?? this.visualFindings,
      safetyRecommendations: safetyRecommendations ?? this.safetyRecommendations,
      followupQuestions: followupQuestions ?? this.followupQuestions,
      scannedAt: scannedAt ?? this.scannedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      barcode: barcode ?? this.barcode,
      packagingCondition: packagingCondition ?? this.packagingCondition,
      composition: composition ?? this.composition,
      visualCondition: visualCondition ?? this.visualCondition,
      texture: texture ?? this.texture,
      aroma: aroma ?? this.aroma,
      storageRecommendation: storageRecommendation ?? this.storageRecommendation,
      shelfLifeEstimate: shelfLifeEstimate ?? this.shelfLifeEstimate,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'foodType': foodType.name,
    'status': status.code,
    'productName': productName,
    'categoryName': categoryName,
    'imagePath': imagePath,
    'aiAdvice': aiAdvice,
    'confidenceScore': confidenceScore,
    'headline': headline,
    'visualFindings': visualFindings.map((v) => v.toJson()).toList(),
    'safetyRecommendations': safetyRecommendations,
    'followupQuestions': followupQuestions.map((q) => q.toJson()).toList(),
    'scannedAt': (scannedAt ?? DateTime.now()).toIso8601String(),
    'expiryDate': expiryDate,
    'barcode': barcode,
    'packagingCondition': packagingCondition,
    'composition': composition,
    'visualCondition': visualCondition,
    'texture': texture,
    'aroma': aroma,
    'storageRecommendation': storageRecommendation,
    'shelfLifeEstimate': shelfLifeEstimate,
    'isDemo': isDemo,
  };

  factory FoodCheckResult.fromJson(Map<String, dynamic> json) {
    FoodType parsedType = FoodType.packaged;
    if (json['foodType'] == 'fresh' || json['category'] == 'FRESH') {
      parsedType = FoodType.fresh;
    }

    FoodCheckStatus parsedStatus = FoodCheckStatus.looksOk;
    final statusCode = json['status'] as String? ?? 'LOOKS_OK';
    switch (statusCode) {
      case 'SAFE':
      case 'LOOKS_OK':
        parsedStatus = FoodCheckStatus.looksOk;
      case 'WARNING':
      case 'CHECK_FURTHER':
        parsedStatus = FoodCheckStatus.checkFurther;
      case 'DANGER':
      case 'AVOID_EATING':
        parsedStatus = FoodCheckStatus.avoidEating;
      case 'UNCERTAIN':
      case 'UNABLE_TO_ASSESS':
        parsedStatus = FoodCheckStatus.unableToAssess;
    }

    final findingsJson = json['visualFindings'] as List<dynamic>? ??
        json['visual_findings'] as List<dynamic>? ??
        const [];
    final questionsJson = json['followupQuestions'] as List<dynamic>? ??
        json['followup_questions'] as List<dynamic>? ??
        const [];
    final recsJson = json['safetyRecommendations'] as List<dynamic>? ??
        json['safety_recommendations'] as List<dynamic>? ??
        const [];

    return FoodCheckResult(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      foodType: parsedType,
      status: parsedStatus,
      productName: json['productName'] as String? ?? json['food_name'] as String? ?? 'Makanan',
      categoryName: json['categoryName'] as String? ??
          (parsedType == FoodType.packaged ? 'Makanan Kemasan' : 'Makanan Segar'),
      imagePath: json['imagePath'] as String? ?? '',
      aiAdvice: json['aiAdvice'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] ?? json['confidence_score'] as num?)?.toDouble() ?? 0.9,
      headline: json['headline'] as String? ?? '',
      visualFindings: findingsJson.map((f) => VisualFinding.fromJson(f as Map<String, dynamic>)).toList(),
      safetyRecommendations: recsJson.map((r) => r.toString()).toList(),
      followupQuestions: questionsJson.map((q) => FollowupQuestion.fromJson(q as Map<String, dynamic>)).toList(),
      scannedAt: json['scannedAt'] != null ? DateTime.tryParse(json['scannedAt'].toString()) : null,
      expiryDate: json['expiryDate'] as String?,
      barcode: json['barcode'] as String?,
      packagingCondition: json['packagingCondition'] as String?,
      composition: json['composition'] as String?,
      visualCondition: json['visualCondition'] as String?,
      texture: json['texture'] as String?,
      aroma: json['aroma'] as String?,
      storageRecommendation: json['storageRecommendation'] as String?,
      shelfLifeEstimate: json['shelfLifeEstimate'] as String?,
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }
}
