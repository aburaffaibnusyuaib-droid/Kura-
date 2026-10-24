import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../features/food_check/domain/food_check_models.dart';
import '../../features/atur/domain/atur_models.dart';
import '../../features/atur/presentation/utils/food_image_resolver.dart';

/// Service untuk integrasi resmi Gemini API secara aman.
/// Tidak ada kunci API hardcoded; kunci diambil via AppConfig/dotenv.
class GeminiService {
  GeminiService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  /// Model prioritas yang didukung Google Generative Language API.
  /// Urutan fallback otomatis jika model tertentu mengalami 503 high demand atau 404:
  static const List<String> _modelHierarchy = [
    'gemini-flash-lite-latest',
    'gemini-3.8-flash',
    'gemini-flash-latest',
  ];

  static const Map<String, String> _ingredientImageMap = {
    'bawang bombay':
        'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&q=80',
    'bawang putih':
        'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=400&q=80',
    'bawang merah':
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
    'tepung':
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
    'cabai':
        'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&q=80',
    'bengkuang':
        'https://images.unsplash.com/photo-1590779033100-9f60a05a013d?w=400&q=80',
    'tomato':
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&q=80',
    'tomat':
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&q=80',
    'telur':
        'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
    'egg':
        'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
    'wortel':
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
    'carrot':
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80',
    'selada':
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
    'lettuce':
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
    'cabe':
        'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&q=80',
    'chili':
        'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&q=80',
    'shallot':
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80',
    'garlic':
        'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=400&q=80',
    'ayam':
        'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80',
    'chicken':
        'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80',
    'brokoli':
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80',
    'broccoli':
        'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=400&q=80',
    'jamur':
        'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?w=400&q=80',
    'mushroom':
        'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?w=400&q=80',
    'tempe':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'tempeh':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'tahu':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'tofu':
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'kangkung':
        'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=400&q=80',
    'bayam':
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
    'spinach':
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80',
    'kentang':
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80',
    'potato':
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80',
    'timun':
        'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=400&q=80',
    'cucumber':
        'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=400&q=80',
    'daging':
        'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=400&q=80',
    'beef':
        'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=400&q=80',
    'ikan':
        'https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=400&q=80',
    'fish':
        'https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=400&q=80',
  };

  /// Helper: Map Image URL dengan prioritas compound phrase agar tidak salah tangkap substring
  static String mapIngredientImageUrl(String keyword, String name) {
    final lowerKey = keyword.toLowerCase().trim();
    final lowerName = name.toLowerCase().trim();
    final combined = '$lowerKey $lowerName';

    // 1. Specific multi-word compounds first to avoid broad substring matching
    if (combined.contains('bombay') || combined.contains('yellow onion')) {
      return _ingredientImageMap['bawang bombay']!;
    }
    if (combined.contains('bawang putih') || combined.contains('garlic')) {
      return _ingredientImageMap['bawang putih']!;
    }
    if (combined.contains('bawang merah') ||
        combined.contains('shallot') ||
        combined.contains('red onion')) {
      return _ingredientImageMap['bawang merah']!;
    }
    if (combined.contains('tepung') ||
        combined.contains('flour') ||
        combined.contains('krispi')) {
      return _ingredientImageMap['tepung']!;
    }
    if (combined.contains('cabai') ||
        combined.contains('cabe') ||
        combined.contains('chili') ||
        combined.contains('paprika')) {
      return _ingredientImageMap['cabai']!;
    }
    if (combined.contains('bengkuang') ||
        combined.contains('jicama') ||
        combined.contains('lobak')) {
      return _ingredientImageMap['bengkuang']!;
    }

    // 2. Exact word / substring checks for single keywords
    for (final entry in _ingredientImageMap.entries) {
      if (combined.contains(entry.key)) {
        return entry.value;
      }
    }

    // 3. Clean neutral fallback (papan potong bahan segar estetik)
    return 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&q=80';
  }

  static String mapRecipeImageUrl(String title, String description) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    if (text.contains('sup') || text.contains('kuah') || text.contains('soto')) {
      return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&q=80';
    }
    if (text.contains('salad') || text.contains('segar')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&q=80';
    }
    if (text.contains('telur') || text.contains('orak')) {
      return 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800&q=80';
    }
    if (text.contains('ayam')) {
      return 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80';
  }

  /// Eksekusi POST request ke Gemini dengan fallback otomatis jika model 503/404.
  /// Batas waktu timeout jaringan tepat 30 detik sesuai standar resiliency.
  Future<String> _postGenerateContent(Map<String, dynamic> payload) async {
    if (apiKey.trim().isEmpty) {
      throw const SocketException('GEMINI_API_KEY belum dikonfigurasi di file .env');
    }

    String lastError = '';
    for (final model in _modelHierarchy) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      try {
        final response = await _client
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw TimeoutException("Batas waktu koneksi terlampaui (30 detik). Silakan coba lagi.");
              },
            );

        if (response.statusCode == 200) {
          return response.body;
        }

        lastError = 'Gemini ($model) status ${response.statusCode}: ${response.body}';
        // Lanjutkan mencoba model berikutnya jika 503 (high demand) atau 404 (sunset)
        if (response.statusCode == 503 || response.statusCode == 404) {
          continue;
        } else {
          break;
        }
      } on TimeoutException {
        lastError = 'Batas waktu koneksi terlampaui (30 detik). Silakan coba lagi.';
        rethrow;
      } on SocketException {
        rethrow;
      } on FormatException {
        rethrow;
      } catch (e) {
        lastError = e.toString();
        if (e is SocketException || e is TimeoutException || e is FormatException) {
          rethrow;
        }
      }
    }

    throw HttpException('Gagal memproses dengan Gemini API: $lastError');
  }

  // ── 1. FOOD CHECK VISION API ──────────────────────────────────

  /// Mengirim foto makanan ke Gemini Vision untuk penilaian kelayakan.
  Future<FoodCheckResult> assessFoodCheck({
    required Uint8List imageBytes,
    required String imagePath,
    FoodType? expectedCategory,
    FreshFoodQuestionnaireAnswers? questionnaireAnswers,
  }) async {
    final base64Image = base64Encode(imageBytes);

    String sensoryContext = '';
    if (questionnaireAnswers != null &&
        (questionnaireAnswers.texture.isNotEmpty ||
            questionnaireAnswers.aroma.isNotEmpty)) {
      sensoryContext =
          '\nData pemeriksaan fisik langsung dari pengguna:'
          '\n- Tekstur: ${questionnaireAnswers.texture}'
          '\n- Aroma: ${questionnaireAnswers.aroma}'
          '\n- Durasi Penyimpanan: ${questionnaireAnswers.storageDuration}';
    }

    final prompt =
        'Anda adalah asisten AI inspeksi keamanan makanan Kura AI untuk masyarakat Indonesia. '
        'Analisis foto makanan ini secara teliti dan objektif.$sensoryContext\n\n'
        'ATURAN KELUARAN (STRICT JSON FORMAT):'
        'Kembalikan HANYA JSON object tunggal dengan skema berikut tanpa tanda markdown:'
        '{\n'
        '  "food_name": "Nama spesifik makanan dalam Bahasa Indonesia (misal: Susu UHT Cokelat, Tomat Merah, Bengkuang Potong)",\n'
        '  "category": "PACKAGED" atau "FRESH",\n'
        '  "status": "SAFE" (kondisi prima/segar/kemasan utuh), "WARNING" (ada cacat ringan/penyok kecil/mulai layu tapi belum busuk), "DANGER" (berjamur/kembung/busuk/berlendir/rusak parah), atau "UNCERTAIN" (makanan segar yang visualnya belum cukup untuk memastikan dan butuh pengecekan bau/tekstur),\n'
        '  "confidence_score": 0.95,\n'
        '  "headline": "Ringkasan kesimpulan 1 kalimat padat dan jelas",\n'
        '  "visual_findings": [\n'
        '    {"aspect": "Integritas Kemasan / Fisik", "detail": "Temuan detail visual"},\n'
        '    {"aspect": "Warna & Tekstur", "detail": "Temuan detail visual"}\n'
        '  ],\n'
        '  "safety_recommendations": [\n'
        '    "Saran keamanan praktis 1",\n'
        '    "Saran keamanan praktis 2"\n'
        '  ],\n'
        '  "followup_questions": [\n'
        '    {"id": "q1", "question": "Pertanyaan sensorik jika status UNCERTAIN", "options": ["Opsi 1", "Opsi 2", "Opsi 3"]}\n'
        '  ]\n'
        '}';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.1,
      },
    };

    final responseBody = await _postGenerateContent(payload);

    final jsonResp = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = jsonResp['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const FormatException('Tidak ada kandidat hasil dari Gemini');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String? ?? '{}';

    final parsedData = jsonDecode(text) as Map<String, dynamic>;
    parsedData['imagePath'] = imagePath;
    parsedData['scannedAt'] = DateTime.now().toIso8601String();

    // Map aiAdvice dari headline & rekomendasi
    final recs = (parsedData['safety_recommendations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final headline = parsedData['headline'] as String? ?? '';
    final combinedAdvice = headline.isNotEmpty
        ? '$headline ${recs.join(". ")}'
        : recs.join('. ');
    parsedData['aiAdvice'] = combinedAdvice;

    return FoodCheckResult.fromJson(parsedData);
  }

  // ── 2. ATUR: DETECT INGREDIENTS API ───────────────────────────

  /// Mengirim foto kulkas / bahan ke Gemini untuk deteksi bahan.
  Future<List<DetectedIngredient>> detectIngredients({
    required Uint8List imageBytes,
  }) async {
    final base64Image = base64Encode(imageBytes);

    const prompt =
        'Anda adalah AI pengenal bahan makanan kulkas Indonesia. '
        'Kenali seluruh bahan makanan segar, sayuran, protein, bumbu, atau bahan dapur yang terlihat pada foto ini. '
        'Kembalikan HANYA JSON array dari objek bahan makanan berikut tanpa markdown:\n'
        '[\n'
        '  {\n'
        '    "id": "ing_1",\n'
        '    "name": "Nama Bahan dalam Bahasa Indonesia (misal: Daun Bawang, Daging Sapi, Tempe, Telur Ayam)",\n'
        '    "category": "vegetable" atau "meat" atau "fruit" atau "spice" atau "dairy" atau "grain" atau "seafood" atau "other",\n'
        '    "quantity": "Kuantitas atau takaran terlihat (misal: 2 batang, 250 gram, 3 butir)",\n'
        '    "image_search_keyword": "keyword bahasa Inggris bersih untuk foto studio makanan (misal: fresh scallions isolated, raw beef steak clean background, indonesian tempeh white background)"\n'
        '  }\n'
        ']';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.2,
      },
    };

    final responseBody = await _postGenerateContent(payload);

    final jsonResp = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = jsonResp['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const FormatException('Tidak ada kandidat hasil dari Gemini');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String? ?? '[]';

    final dynamic decoded = jsonDecode(text);
    final List<dynamic> parsedList;
    if (decoded is List) {
      parsedList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final listVal = decoded.values.firstWhere(
        (v) => v is List,
        orElse: () => <dynamic>[],
      );
      parsedList = listVal as List<dynamic>;
    } else {
      parsedList = const [];
    }

    return parsedList.asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      final name = item['name'] as String? ?? 'Bahan';
      final category = item['category'] as String?;
      final keyword = item['image_search_keyword'] as String? ??
          item['image_keyword'] as String? ??
          name;
      final mappedUrl = FoodImageResolver.resolveImageUrl(
        name: name,
        category: category,
        searchKeyword: keyword,
      );

      return DetectedIngredient(
        id: item['id'] as String? ?? 'ing_${entry.key + 1}',
        name: name,
        category: category,
        quantity: item['quantity'] as String? ?? '1 porsi',
        imageKeyword: keyword,
        imageUrl: mappedUrl,
        isSelected: true,
      );
    }).toList();
  }

  // ── 3. ATUR: GENERATE ZERO WASTE RECIPES API ──────────────────

  /// Mengirim bahan terpilih ke Gemini untuk menghasilkan 3 resep zero waste.
  Future<List<Recipe>> generateZeroWasteRecipes({
    required List<DetectedIngredient> selectedIngredients,
  }) async {
    final ingredientsListText = selectedIngredients
        .map((i) => '- ${i.name} (${i.quantity})')
        .join('\n');

    final prompt =
        'Anda adalah koki profesional Indonesia spesialis gerakan Zero Waste Food. '
        'Berdasarkan daftar bahan makanan sisa yang dimiliki pengguna berikut:\n'
        '$ingredientsListText\n\n'
        'Buatkan TEPAT 3 resep masakan Indonesia yang lezat, praktis, hemat, dan memaksimalkan bahan tanpa ada yang terbuang sia-sia. '
        'KEMBALIKAN HANYA JSON array dengan persis 3 objek resep berikut tanpa markdown:'
        '[\n'
        '  {\n'
        '    "id": "recipe_1",\n'
        '    "title": "Nama Masakan Indonesia",\n'
        '    "cook_time": 20,\n'
        '    "difficulty": "Mudah",\n'
        '    "servings": 2,\n'
        '    "calories": 210,\n'
        '    "description": "Deskripsi selera 1-2 kalimat",\n'
        '    "ingredients": ["Bahan 1 dengan takaran", "Bahan 2 dengan takaran"],\n'
        '    "steps": [\n'
        '      "Langkah 1...",\n'
        '      "Langkah 2..."\n'
        '    ],\n'
        '    "zero_waste_tip": "Tips memanfaatkan sisa batang/kulit/air rebusan agar nol sampah makanan"\n'
        '  }\n'
        ']';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.3,
      },
    };

    final responseBody = await _postGenerateContent(payload);

    final jsonResp = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = jsonResp['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const FormatException('Tidak ada kandidat hasil dari Gemini');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String? ?? '[]';

    final dynamic decoded = jsonDecode(text);
    final List<dynamic> parsedList;
    if (decoded is List) {
      parsedList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final listVal = decoded.values.firstWhere(
        (v) => v is List,
        orElse: () => <dynamic>[],
      );
      parsedList = listVal as List<dynamic>;
    } else {
      parsedList = const [];
    }

    return parsedList.take(3).map((item) {
      final map = item as Map<String, dynamic>;
      final title = map['title'] as String? ?? map['name'] as String? ?? 'Resep Lezat';
      final desc = map['description'] as String? ?? '';
      final imageUrl = mapRecipeImageUrl(title, desc);

      return Recipe.fromJson(map).copyWith(imageUrl: imageUrl);
    }).toList();
  }

  // ── 4. KURA AI CHAT: MULTI-TURN & MULTIMODAL CONVERSATION ─────

  /// Mengirim pesan percakapan ke model Kura AI dengan Persona, Guardrail,
  /// dan sliding-window context dari riwayat chat lokal.
  Future<String> sendChatMessage({
    required String prompt,
    Uint8List? imageBytes,
    List<Map<String, dynamic>> conversationHistory = const [],
  }) async {
    final contents = <Map<String, dynamic>>[];

    // 1. Sliding window context: Ambil maksimal 8 pesan riwayat percakapan terakhir
    for (final turn in conversationHistory.take(8)) {
      final role = turn['role'] as String? ?? 'user';
      final text = turn['text'] as String? ?? '';
      contents.add({
        'role': role,
        'parts': [
          {'text': text},
        ],
      });
    }

    // 2. Giliran saat ini (Current turn)
    final currentParts = <Map<String, dynamic>>[];
    if (prompt.trim().isNotEmpty) {
      currentParts.add({'text': prompt.trim()});
    } else if (imageBytes != null) {
      currentParts.add({'text': 'Tolong analisa foto makanan/bahan ini dan berikan penjelasan kelayakan serta idenya.'});
    }

    if (imageBytes != null) {
      currentParts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      });
    }

    contents.add({
      'role': 'user',
      'parts': currentParts,
    });

    const systemInstruction = '''
Kamu adalah Kura AI, asisten pintar berwujud bayi kura-kura toska yang lucu, ramah, santai, empatik, dan to-the-point.
Tugas utamamu adalah membantu pengguna seputar makanan, resep masakan, tips anti-mubazir (zero-waste), nutrisi, dan keamanan makanan.
ATURAN MUTLAK:
1. Gaya bahasa santai, hangat, gunakan sapaan akrab, selipkan emoji yang relevan sesekali.
2. Jika pengguna bertanya di luar topik makanan/minuman/diet/zero-waste (koding, matematika, politik, tugas sekolah umum), tolak dengan sopan, lucu, dan singkat (1-2 kalimat), lalu ajak kembali ke topik makanan.
3. Format penjelasan panjang wajib menggunakan bullet points ringkas agar mudah dibaca di layar HP.
4. Jika pengguna hanya mengirim foto tanpa teks: Lakukan analisis cepat terhadap bahan/makanan di foto (tebak bahan, kesegarannya, dan berikan 1 ide olahan singkat).
5. Jika hasil analisis visual makanan menunjukkan kesimpulan aman/tidak aman, sertakan di baris terpisah dengan format:
[KESIMPULAN: Kesimpulan singkat di sini (misal: Brokoli ini masih aman dikonsumsi)]
6. Jika merekomendasikan resep spesifik, kamu WAJIB menyertakan blok JSON di akhir pesanmu dengan format:
```recipe_json
{
  "id": "rec_random",
  "title": "Nama Masakan",
  "cook_time": "15 menit",
  "difficulty": "Mudah",
  "servings": "2 porsi",
  "calories": "~220 kkal",
  "image_keyword": "nama_bahan_utama",
  "zero_waste_tip": "Tips sisa bahan masakan ini",
  "ingredients": ["Bahan 1 dengan takaran", "Bahan 2 dengan takaran"],
  "steps": ["Langkah 1", "Langkah 2"]
}
```
''';

    final payload = {
      'system_instruction': {
        'parts': [
          {'text': systemInstruction},
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
      },
    };

    final responseBody = await _postGenerateContent(payload);

    final jsonResp = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = jsonResp['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const FormatException('Tidak ada jawaban dari Kura AI');
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String? ?? '';
    return text;
  }
}
