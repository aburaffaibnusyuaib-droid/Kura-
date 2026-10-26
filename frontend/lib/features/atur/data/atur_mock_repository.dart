// TASK-05: Atur Module — Mock Repository
// [DEMO] Seluruh data bersifat demonstrasi. Tidak ada koneksi AI nyata.

import '../domain/atur_models.dart';
import 'atur_repository.dart';

/// Implementasi mock dengan delay 2 detik untuk simulasi pemrosesan AI.
final class AturMockRepository implements AturRepository {
  // [DEMO] 6 bahan dummy yang "terdeteksi" dari foto.
  static const List<DetectedIngredient> _dummyIngredients = [
    DetectedIngredient(
      id: 'i1',
      name: 'Tomat',
      quantity: '3 buah',
      emoji: '🍅',
      imageKeyword: 'fresh red tomato raw',
      box2d: [100, 100, 400, 400],
    ),
    DetectedIngredient(
      id: 'i2',
      name: 'Selada',
      quantity: '100 g',
      emoji: '🥬',
      imageKeyword: 'crisp green lettuce leaves',
      box2d: [150, 450, 500, 850],
    ),
    DetectedIngredient(
      id: 'i3',
      name: 'Wortel',
      quantity: '2 buah',
      emoji: '🥕',
      imageKeyword: 'fresh orange carrot raw',
      box2d: [450, 100, 850, 450],
    ),
    DetectedIngredient(
      id: 'i4',
      name: 'Telur',
      quantity: '4 butir',
      emoji: '🥚',
      imageKeyword: 'white chicken egg raw',
      box2d: [500, 500, 800, 800],
    ),
    DetectedIngredient(
      id: 'i5',
      name: 'Cabai',
      quantity: '5 buah',
      emoji: '🌶️',
      imageKeyword: 'fresh red hot chili pepper',
      box2d: [200, 200, 600, 600],
    ),
    DetectedIngredient(
      id: 'i6',
      name: 'Bawang Merah',
      quantity: '1 siung',
      emoji: '🧅',
      imageKeyword: 'fresh red shallots cloves',
      box2d: [600, 200, 900, 500],
    ),
  ];

  // [DEMO] TEPAT 3 resep sesuai PRODUCT_SPEC.md.
  static const List<Recipe> _dummyRecipes = [
    Recipe(
      id: 'r1',
      name: 'Salad Segar Telur',
      durationMinutes: 15,
      difficulty: 'Mudah',
      tags: ['Sehat', 'Praktis'],
      description:
          'Salad ringan bergizi dengan tomat, selada segar, dan telur rebus '
          'sebagai sumber protein. Cocok untuk sarapan atau makan siang.',
      servings: 2,
      colorHex: 0xFF4DB6AC,
      ingredients: [
        '3 buah tomat, potong dadu',
        '100 g selada, sobek kasar',
        '2 butir telur, rebus keras',
        'Garam & merica secukupnya',
        '1 sdm minyak zaitun / minyak sayur',
      ],
      steps: [
        RecipeStep(stepNumber: 1, instruction: 'Rebus telur selama 10 menit, kupas dan belah 4.'),
        RecipeStep(stepNumber: 2, instruction: 'Cuci bersih tomat dan selada, tiriskan.'),
        RecipeStep(stepNumber: 3, instruction: 'Potong tomat menjadi dadu kecil.'),
        RecipeStep(stepNumber: 4, instruction: 'Campur semua bahan dalam mangkuk besar.'),
        RecipeStep(stepNumber: 5, instruction: 'Tambahkan garam, merica, dan minyak. Aduk rata dan sajikan.'),
      ],
    ),
    Recipe(
      id: 'r2',
      name: 'Tumis Sayur Campur',
      durationMinutes: 20,
      difficulty: 'Sedang',
      tags: ['Hemat', 'Praktis'],
      description:
          'Tumisan sayur warna-warni dengan wortel, cabai, dan bawang merah '
          'yang gurih dan lezat. Sempurna sebagai lauk nasi.',
      servings: 3,
      colorHex: 0xFF66BB6A,
      ingredients: [
        '2 buah wortel, iris tipis',
        '1 siung bawang merah, iris',
        '3 buah cabai, iris serong',
        '100 g selada, potong kasar',
        'Garam, gula, kecap manis secukupnya',
        '2 sdm minyak goreng',
      ],
      steps: [
        RecipeStep(stepNumber: 1, instruction: 'Panaskan minyak di wajan, tumis bawang merah hingga harum.'),
        RecipeStep(stepNumber: 2, instruction: 'Masukkan cabai, tumis 1 menit.'),
        RecipeStep(stepNumber: 3, instruction: 'Tambahkan wortel, masak 5 menit sambil diaduk.'),
        RecipeStep(stepNumber: 4, instruction: 'Masukkan selada, aduk rata.'),
        RecipeStep(stepNumber: 5, instruction: 'Bumbui dengan garam, gula, dan kecap manis. Koreksi rasa.'),
        RecipeStep(stepNumber: 6, instruction: 'Masak hingga sayur layu dan matang. Angkat dan sajikan.'),
      ],
    ),
    Recipe(
      id: 'r3',
      name: 'Sup Tomat Telur',
      durationMinutes: 25,
      difficulty: 'Mudah',
      tags: ['Sehat', 'Hemat'],
      description:
          'Sup hangat dengan kaldu tomat yang segar dan telur kocok yang '
          'lembut. Ideal untuk cuaca dingin atau saat kurang enak badan.',
      servings: 4,
      colorHex: 0xFFEF5350,
      ingredients: [
        '3 buah tomat, potong kasar',
        '2 butir telur, kocok lepas',
        '1 siung bawang merah, iris',
        '600 ml air',
        'Garam, merica, daun bawang secukupnya',
        '1 sdm minyak goreng',
      ],
      steps: [
        RecipeStep(stepNumber: 1, instruction: 'Tumis bawang merah dengan minyak hingga harum.'),
        RecipeStep(stepNumber: 2, instruction: 'Masukkan tomat, tumis hingga layu ± 3 menit.'),
        RecipeStep(stepNumber: 3, instruction: 'Tuang air, didihkan selama 10 menit.'),
        RecipeStep(stepNumber: 4, instruction: 'Kecilkan api, tuang telur kocok sambil diaduk perlahan membentuk "ribbon".'),
        RecipeStep(stepNumber: 5, instruction: 'Bumbui dengan garam dan merica. Taburi daun bawang dan sajikan hangat.'),
      ],
    ),
  ];

  @override
  Future<List<DetectedIngredient>> analyzeIngredients(
    String? imagePath,
  ) async {
    // [DEMO] Simulasi delay AI processing 2 detik.
    await Future<void>.delayed(const Duration(seconds: 2));
    return List.unmodifiable(_dummyIngredients);
  }

  @override
  Future<List<Recipe>> generateRecipes(
    List<DetectedIngredient> selectedIngredients,
  ) async {
    // [DEMO] Simulasi delay rekomendasi resep 2 detik.
    await Future<void>.delayed(const Duration(seconds: 2));
    // PRODUCT_SPEC constraint: selalu kembalikan tepat 3 resep.
    return List.unmodifiable(_dummyRecipes);
  }

  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    return true;
  }
}
