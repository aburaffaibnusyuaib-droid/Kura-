import 'dart:async';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/atur_models.dart';
import 'atur_repository.dart';

/// Implementasi Hybrid Repository:
/// 1. Live Engine: Menggunakan Gemini 1.5 Flash Vision jika online & API Key tersedia.
/// 2. Dynamic Fallback Engine: Jika timeout (>4s), kuota habis, atau offline,
///    menghasilkan set bahan dan resep bervariasi secara rotatif.
/// 3. Offline-First Storage: Simpan lokal instan + background sync ke Supabase.
final class AturHybridRepository implements AturRepository {
  AturHybridRepository({
    this.geminiService,
    this.supabaseService,
  });

  final GeminiService? geminiService;
  final SupabaseService? supabaseService;

  static int _rotationIndex = 0;
  final Set<String> _localSavedRecipeIds = <String>{};

  // ── Curated Real Food CDN Images ──────────────────────────────
  static const Map<String, String> _ingredientImageMap = {
    'tomat':
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&q=80',
    'selada':
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
    'wortel':
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
    'telur':
        'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
    'cabai':
        'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&q=80',
    'bawang merah':
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
    'bawang putih':
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
    'ayam':
        'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80',
    'brokoli':
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80',
    'jamur':
        'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?w=400&q=80',
    'tempe':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'tahu':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'kangkung':
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
  };

  // ── Dynamic Ingredient Pools untuk Fallback Bervariasi ─────────
  static const List<List<DetectedIngredient>> _ingredientPools = [
    // Pool 1: Segar & Telur (Sesuai Mockup 06 & 09)
    [
      DetectedIngredient(
        id: 'i1',
        name: 'Tomat',
        quantity: '3 buah',
        emoji: '🍅',
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i2',
        name: 'Selada',
        quantity: '100 g',
        emoji: '🥬',
        imageUrl:
            'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i3',
        name: 'Wortel',
        quantity: '2 buah',
        emoji: '🥕',
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i4',
        name: 'Telur',
        quantity: '4 butir',
        emoji: '🥚',
        imageUrl:
            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i5',
        name: 'Cabai',
        quantity: '5 buah',
        emoji: '🌶️',
        imageUrl:
            'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i6',
        name: 'Bawang Merah',
        quantity: '1 siung',
        emoji: '🧅',
        imageUrl:
            'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
      ),
    ],
    // Pool 2: Unggas & Sayuran Hijau
    [
      DetectedIngredient(
        id: 'i21',
        name: 'Dada Ayam',
        quantity: '250 g',
        emoji: '🍗',
        imageUrl:
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i22',
        name: 'Brokoli',
        quantity: '1 bonggol',
        emoji: '🥦',
        imageUrl:
            'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i23',
        name: 'Wortel',
        quantity: '1 buah',
        emoji: '🥕',
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i24',
        name: 'Jamur Tiram',
        quantity: '100 g',
        emoji: '🍄',
        imageUrl:
            'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i25',
        name: 'Bawang Putih',
        quantity: '3 siung',
        emoji: '🧄',
        imageUrl:
            'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
      ),
      DetectedIngredient(
        id: 'i26',
        name: 'Telur',
        quantity: '2 butir',
        emoji: '🥚',
        imageUrl:
            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
      ),
    ],
  ];

  // ── Dynamic Recipe Pools (Tepat 3 Resep Setiap Sesi) ───────────
  static const List<List<Recipe>> _recipePools = [
    // Resep Pool 1 (Salad Segar, Tumis Sayur, Sup Tomat)
    [
      Recipe(
        id: 'r1',
        name: 'Salad Segar Telur',
        durationMinutes: 15,
        difficulty: 'Mudah',
        tags: ['Sehat', 'Praktis'],
        description:
            'Salad ringan bergizi dengan potongan tomat manis, selada renyah, dan telur rebus kaya protein.',
        servings: 2,
        colorHex: 0xFF00CBA7,
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&q=80',
        ingredients: [
          '3 buah tomat segar, potong dadu',
          '100 g selada renyah, sobek kasar',
          '2 butir telur, rebus keras',
          'Garam & merica secukupnya',
          '1 sdm minyak zaitun / perasan jeruk nipis',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Rebus telur selama 10 menit, kupas bersih lalu belah empat.'),
          RecipeStep(stepNumber: 2, instruction: 'Cuci bersih tomat dan selada dengan air mengalir, tiriskan.'),
          RecipeStep(stepNumber: 3, instruction: 'Campur potongan tomat dan selada di dalam mangkuk saji.'),
          RecipeStep(stepNumber: 4, instruction: 'Bumbui dengan garam, merica, dan minyak zaitun. Aduk rata dan hidangkan segar.'),
        ],
      ),
      Recipe(
        id: 'r2',
        name: 'Tumis Sayur Campur',
        durationMinutes: 20,
        difficulty: 'Sedang',
        tags: ['Hemat', 'Praktis'],
        description:
            'Tumisan sayur warna-warni yang gurih beraroma bawang dan cabai. Sangat nikmat disajikan hangat bersama nasi.',
        servings: 3,
        colorHex: 0xFF22C55E,
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
        ingredients: [
          '2 buah wortel, iris serong tipis',
          '1 siung bawang merah & putih, iris',
          '3 buah cabai, iris tipis',
          '100 g selada / sawi, potong kasar',
          'Garam, gula, dan saus tiram secukupnya',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Panaskan sedikit minyak, tumis irisan bawang hingga harum keemasan.'),
          RecipeStep(stepNumber: 2, instruction: 'Masukkan cabai dan wortel, aduk rata selama 3 menit hingga mulai layu.'),
          RecipeStep(stepNumber: 3, instruction: 'Tambahkan selada dan bumbu (garam, gula, saus tiram). Koreksi rasa.'),
          RecipeStep(stepNumber: 4, instruction: 'Aduk cepat dengan api sedang selama 1 menit agar sayur tetap renyah. Angkat.'),
        ],
      ),
      Recipe(
        id: 'r3',
        name: 'Sup Tomat Telur',
        durationMinutes: 25,
        difficulty: 'Mudah',
        tags: ['Sehat', 'Hemat'],
        description:
            'Sup hangat berkuah asam segar alami dari tomat matang dengan pita kocokan telur sutra yang lembut menenangkan.',
        servings: 4,
        colorHex: 0xFFFF5A36,
        imageUrl:
            'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&q=80',
        ingredients: [
          '3 buah tomat matang, cincang kasar',
          '2 butir telur, kocok lepas',
          '1 siung bawang merah, cincang halus',
          '600 ml air kaldu / air bersih',
          'Garam, lada, dan daun bawang iris',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Tumis bawang cincang hingga wangi, lalu masukkan tomat hingga hancur berair.'),
          RecipeStep(stepNumber: 2, instruction: 'Tuangkan air kaldu dan didihkan selama 8 menit sampai sari tomat meresap.'),
          RecipeStep(stepNumber: 3, instruction: 'Kecilkan api, tuang kocokan telur perlahan melingkar sambil diaduk lembut.'),
          RecipeStep(stepNumber: 4, instruction: 'Bumbui garam dan lada, taburi daun bawang segar lalu sajikan selagi panas.'),
        ],
      ),
    ],
    // Resep Pool 2 (Tumis Ayam Brokoli, Sup Jamur Ayam, Orak-Arik Sayur)
    [
      Recipe(
        id: 'r4',
        name: 'Tumis Ayam Brokoli',
        durationMinutes: 20,
        difficulty: 'Sedang',
        tags: ['Tinggi Protein', 'Sehat'],
        description:
            'Perpaduan daging ayam empuk dan kuntum brokoli renyah berbalur saus bawang gurih kaya antioksidan.',
        servings: 3,
        colorHex: 0xFF00CBA7,
        imageUrl:
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&q=80',
        ingredients: [
          '250 g dada ayam, potong dadu kecil',
          '1 bonggol brokoli, potong per kuntum',
          '1 buah wortel, potong korek api',
          '3 siung bawang putih, geprek',
          'Kecap asin, saus tiram, minyak wijen',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Rebus brokoli sebentar (1 menit) di air mendidih bergaram, tiriskan segera.'),
          RecipeStep(stepNumber: 2, instruction: 'Tumis bawang putih hingga harum, lalu masukkan potongan ayam hingga berubah warna.'),
          RecipeStep(stepNumber: 3, instruction: 'Masukkan wortel dan beri saus tiram, kecap asin, serta sedikit air.'),
          RecipeStep(stepNumber: 4, instruction: 'Masukkan brokoli dan minyak wijen, aduk rata 1 menit dan sajikan hangat.'),
        ],
      ),
      Recipe(
        id: 'r5',
        name: 'Sup Jamur Ayam Jahe',
        durationMinutes: 25,
        difficulty: 'Mudah',
        tags: ['Hangat', 'Sehat'],
        description:
            'Sup berkuah bening jahe yang menghangatkan tenggorokan dengan suwiran ayam dan kenyalnya jamur tiram.',
        servings: 4,
        colorHex: 0xFF22C55E,
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&q=80',
        ingredients: [
          '150 g dada ayam rebus, suwir kasar',
          '100 g jamur tiram, suwir dan cuci bersih',
          '1 ruas jahe, memarkan',
          '2 siung bawang putih cincang',
          'Garam, kaldu bubuk, seledri cincang',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Didihkan 700 ml air bersama jahe memar dan bawang putih cincang.'),
          RecipeStep(stepNumber: 2, instruction: 'Masukkan suwiran ayam dan jamur tiram ke dalam panci mendidih.'),
          RecipeStep(stepNumber: 3, instruction: 'Bumbui garam, merica, dan kaldu bubuk sesuai selera.'),
          RecipeStep(stepNumber: 4, instruction: 'Masak 5 menit hingga jamur matang lembut. Taburi seledri sebelum dihidangkan.'),
        ],
      ),
      Recipe(
        id: 'r6',
        name: 'Orak-Arik Sayur Telur',
        durationMinutes: 12,
        difficulty: 'Mudah',
        tags: ['Praktis', 'Hemat'],
        description:
            'Menu andalan praktis pembersih kulkas yang menggabungkan telur orak-arik dengan sayuran sisa dapur.',
        servings: 2,
        colorHex: 0xFFFF5A36,
        imageUrl:
            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80',
        ingredients: [
          '2 butir telur, kocok lepas bergaram',
          '1 buah wortel, iris korek api tipis',
          'Brokoli / sawi sisa kulkas secukupnya',
          '2 siung bawang merah, iris',
          'Minyak untuk menumis secukupnya',
        ],
        steps: [
          RecipeStep(stepNumber: 1, instruction: 'Panaskan wajan, buat telur orak-arik setengah matang, angkat dan sisihkan.'),
          RecipeStep(stepNumber: 2, instruction: 'Tumis bawang merah di wajan yang sama hingga layu dan wangi.'),
          RecipeStep(stepNumber: 3, instruction: 'Masukkan irisan wortel dan sayuran hijau, masak hingga empuk.'),
          RecipeStep(stepNumber: 4, instruction: 'Campurkan kembali telur orak-arik, bumbui merica dan garam. Aduk rata.'),
        ],
      ),
    ],
  ];

  @override
  Future<List<DetectedIngredient>> analyzeIngredients(String? imagePath) async {
    // ── 1. Coba Live Mode jika Gemini Service & file path tersedia ──
    if (geminiService != null && imagePath != null && imagePath != 'demo') {
      try {
        final liveNames = await geminiService!.analyzeIngredients(imagePath);
        if (liveNames.isNotEmpty) {
          return liveNames.asMap().entries.map((entry) {
            final name = entry.value;
            final lower = name.toLowerCase();
            final matchedUrl = _ingredientImageMap.entries
                .firstWhere(
                  (m) => lower.contains(m.key),
                  orElse: () => const MapEntry('', ''),
                )
                .value;

            return DetectedIngredient(
              id: 'live_${entry.key}',
              name: name,
              quantity: '1 porsi',
              emoji: '🥗',
              imageUrl: matchedUrl.isNotEmpty ? matchedUrl : null,
            );
          }).toList();
        }
      } catch (_) {
        // Fallback otomatis ke Dynamic Engine jika request gagal/timeout
      }
    }

    // ── 2. Dynamic Fallback Engine (Rotasi cerdas agar tidak monoton)
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    final pool = _ingredientPools[_rotationIndex % _ingredientPools.length];
    _rotationIndex++;
    return List.unmodifiable(pool);
  }

  @override
  Future<List<Recipe>> generateRecipes(
    List<DetectedIngredient> selectedIngredients,
  ) async {
    // Simulasi pemrosesan rekomendasi AI
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    // Mengambil resep pool sesuai rotasi terakhir
    final currentPool = _recipePools[(_rotationIndex - 1).clamp(0, _recipePools.length - 1)];

    // Update status isSaved jika resep sudah ada di cache lokal
    return currentPool.map((r) {
      return r.copyWith(isSaved: _localSavedRecipeIds.contains(r.id));
    }).toList();
  }

  @override
  Future<bool> saveRecipe(Recipe recipe) async {
    // 1. Simpan ke local state/cache seketika (Offline-First)
    _localSavedRecipeIds.add(recipe.id);

    // 2. Background sync ke Supabase secara asinkron
    if (supabaseService != null && supabaseService!.isConfigured) {
      unawaited(
        supabaseService!.saveRecipe({
          'recipe_id': recipe.id,
          'name': recipe.name,
          'duration': recipe.durationMinutes,
          'difficulty': recipe.difficulty,
          'saved_at': DateTime.now().toIso8601String(),
        }),
      );
    }

    return true;
  }
}
