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
    this.expiryDate,
    this.barcode,
    this.packagingCondition,
    this.composition,
    this.visualCondition,
    this.texture,
    this.aroma,
    this.storageRecommendation,
    this.shelfLifeEstimate,
    this.isDemo = true,
  });

  final String id;
  final FoodType foodType;
  final FoodCheckStatus status;
  final String productName;
  final String categoryName;
  final String imagePath;
  final String aiAdvice;
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
}
