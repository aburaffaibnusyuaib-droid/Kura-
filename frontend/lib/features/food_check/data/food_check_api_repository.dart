import 'dart:io';
import 'package:flutter/services.dart';

import '../../../core/services/gemini_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/image_compressor.dart';
import '../domain/food_check_models.dart';
import 'food_check_repository.dart';

/// Implementasi repository Food Check menggunakan Gemini Vision API asli.
/// Mengambil bytes foto, mengirim ke Gemini 1.5 Flash, dan menyimpan hasil ke penyimpanan lokal.
class FoodCheckApiRepository implements FoodCheckRepository {
  FoodCheckApiRepository({
    required this.geminiService,
    required this.localStorageService,
  });

  final GeminiService geminiService;
  final LocalStorageService localStorageService;

  @override
  Future<FoodCheckResult> assessFood({
    required String imagePath,
    required FoodType foodType,
    FreshFoodQuestionnaireAnswers? questionnaireAnswers,
    String? forcedScenario,
  }) async {
    // 1. Ambil bytes gambar
    Uint8List imageBytes;
    if (imagePath.startsWith('assets/')) {
      final byteData = await rootBundle.load(imagePath);
      imageBytes = byteData.buffer.asUint8List();
    } else {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw FileSystemException('File gambar tidak ditemukan di lokasi: $imagePath');
      }
      imageBytes = await file.readAsBytes();
    }

    // 2. Kompresi gambar asinkron (maks 1024px, JPEG 78%, isolate compute bila > 1.5MB)
    imageBytes = await ImageCompressor.compressBytes(imageBytes);

    // 3. Kirim ke Gemini 1.5 Flash Vision API
    final result = await geminiService.assessFoodCheck(
      imageBytes: imageBytes,
      imagePath: imagePath,
      expectedCategory: foodType,
      questionnaireAnswers: questionnaireAnswers,
    );

    // 4. Simpan hasil penilaian ke Local Storage
    try {
      await localStorageService.saveFoodCheck(result);
    } catch (_) {
      // Abaikan jika penyimpanan lokal gagal agar hasil analisis tetap tampil
    }

    return result;
  }
}
