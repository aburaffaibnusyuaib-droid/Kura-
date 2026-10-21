import '../domain/food_check_models.dart';
import 'food_check_repository.dart';

/// Implementasi Mock Repository untuk Food Check (DEMO).
/// Menyediakan 5 skenario hasil sesuai Mockup 06 sampai 11.
final class FoodCheckMockRepository implements FoodCheckRepository {
  const FoodCheckMockRepository();

  @override
  Future<FoodCheckResult> assessFood({
    required String imagePath,
    required FoodType foodType,
    FreshFoodQuestionnaireAnswers? questionnaireAnswers,
    String? forcedScenario,
  }) async {
    // Simulasi delay pemrosesan AI (2 detik)
    await Future<void>.delayed(const Duration(seconds: 2));

    if (forcedScenario != null) {
      return _getScenarioByName(forcedScenario, imagePath);
    }

    if (foodType == FoodType.packaged) {
      return _packagedSafe(imagePath);
    } else {
      return _freshSafe(imagePath);
    }
  }

  FoodCheckResult _getScenarioByName(String scenario, String imagePath) {
    switch (scenario) {
      case 'packaged_warning':
        return _packagedWarning(imagePath);
      case 'packaged_danger':
        return _packagedDanger(imagePath);
      case 'fresh_uncertain':
        return _freshUncertain(imagePath);
      case 'fresh_safe':
        return _freshSafe(imagePath);
      case 'packaged_safe':
      default:
        return _packagedSafe(imagePath);
    }
  }

  // Mockup 06: Makanan Kemasan - Aman Dikonsumsi
  FoodCheckResult _packagedSafe(String imagePath) => FoodCheckResult(
        id: 'mock_pkg_01',
        foodType: FoodType.packaged,
        status: FoodCheckStatus.looksOk,
        productName: 'Sarden dalam Saus Tomat',
        categoryName: 'ABC',
        imagePath: imagePath,
        expiryDate: '12 Des 2026',
        barcode: '8996001234567',
        packagingCondition: 'Baik',
        composition: 'Ikan sarden, saus tomat, garam, bumbu.',
        aiAdvice:
            'Tidak ditemukan tanda kerusakan pada kemasan. Produk aman dikonsumsi sebelum tanggal kedaluwarsa.',
        storageRecommendation: 'Simpan di tempat sejuk dan kering.',
        shelfLifeEstimate: 'Masa simpan masih panjang.',
      );

  // Mockup 07: Makanan Kemasan - Perlu Diperiksa
  FoodCheckResult _packagedWarning(String imagePath) => FoodCheckResult(
        id: 'mock_pkg_02',
        foodType: FoodType.packaged,
        status: FoodCheckStatus.checkFurther,
        productName: 'Keripik Kentang',
        categoryName: 'Chitato',
        imagePath: imagePath,
        expiryDate: '28 Okt 2025',
        barcode: '8992745632100',
        packagingCondition: 'Sedikit penyok',
        composition: 'Kentang, minyak nabati, garam.',
        aiAdvice:
            'Kemasan sedikit penyok. Periksa lebih lanjut bau dan kerenyahan sebelum dikonsumsi.',
        storageRecommendation: 'Segera habiskan setelah kemasan dibuka.',
        shelfLifeEstimate: 'Dekat tanggal kedaluwarsa.',
      );

  // Mockup 08: Makanan Kemasan - Hindari Konsumsi
  FoodCheckResult _packagedDanger(String imagePath) => FoodCheckResult(
        id: 'mock_pkg_03',
        foodType: FoodType.packaged,
        status: FoodCheckStatus.avoidEating,
        productName: 'Susu UHT',
        categoryName: 'Ultra Milk',
        imagePath: imagePath,
        expiryDate: '01 Sep 2025',
        barcode: '8992691100112',
        packagingCondition: 'Rusak',
        composition: 'Susu sapi segar, vitamin D3.',
        aiAdvice:
            'Produk sudah melewati tanggal kedaluwarsa atau kemasan rusak parah. Jangan dikonsumsi.',
        storageRecommendation: 'Segera buang produk ke tempat sampah.',
        shelfLifeEstimate: 'Kedaluwarsa terlewati.',
      );

  // Mockup 09: Makanan Segar - Segar & Aman
  FoodCheckResult _freshSafe(String imagePath) => FoodCheckResult(
        id: 'mock_frs_01',
        foodType: FoodType.fresh,
        status: FoodCheckStatus.looksOk,
        productName: 'Bayam',
        categoryName: 'Sayur segar',
        imagePath: imagePath,
        visualCondition: 'Segar, warna hijau cerah',
        texture: 'Renyah',
        aroma: 'Tidak ada bau tidak normal',
        aiAdvice:
            'Sayuran terlihat segar dan aman dikonsumsi. Cuci bersih dengan air mengalir sebelum diolah.',
        storageRecommendation: 'Simpan di kulkas suhu 4-7°C dibungkus tisu/kertas.',
        shelfLifeEstimate: 'Baik dikonsumsi dalam 2-3 hari.',
      );

  // Mockup 11: Makanan Segar - Belum Dapat Dipastikan
  FoodCheckResult _freshUncertain(String imagePath) => FoodCheckResult(
        id: 'mock_frs_02',
        foodType: FoodType.fresh,
        status: FoodCheckStatus.unableToAssess,
        productName: 'Buah Berry',
        categoryName: 'Buah segar',
        imagePath: imagePath,
        visualCondition: 'Beberapa bagian tampak lunak',
        texture: 'Campuran',
        aroma: 'Samar',
        aiAdvice:
            'AI tidak dapat memastikan kondisi buah ini sepenuhnya dari gambar saja. Periksa langsung kondisi fisik, seperti tekstur, bau, dan warna.',
        storageRecommendation: 'Pilah bagian yang masih keras dan segar.',
        shelfLifeEstimate: 'Pemeriksaan manual diperlukan.',
      );
}
