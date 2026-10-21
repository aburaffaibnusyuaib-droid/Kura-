import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Service untuk integrasi resmi Gemini API secara aman.
/// Tidak ada kunci API hardcoded; kunci diambil via AppConfig/dotenv.
class GeminiService {
  GeminiService({required this.apiKey});

  final String apiKey;

  /// Endpoint Gemini 1.5 Flash untuk deteksi visi dan teks yang cepat & efisien.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Menganalisis gambar dari file path lokal dan mengembalikan daftar nama bahan makanan.
  Future<List<String>> analyzeIngredients(String imagePath) async {
    if (apiKey.trim().isEmpty) {
      throw const FormatException('GEMINI_API_KEY tidak dikonfigurasi di .env');
    }

    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const FileSystemException('File gambar tidak ditemukan');
    }

    final bytes = await file.readAsBytes();
    return analyzeIngredientsFromBytes(bytes);
  }

  /// Menganalisis gambar dari raw bytes.
  Future<List<String>> analyzeIngredientsFromBytes(Uint8List imageBytes) async {
    if (apiKey.trim().isEmpty) {
      throw const FormatException('GEMINI_API_KEY tidak dikonfigurasi di .env');
    }

    final base64Image = base64Encode(imageBytes);
    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final payload = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Identifikasi bahan makanan mentah/segar atau bahan masakan yang terlihat di foto ini. '
                  'Hanya kembalikan nama bahan dalam bahasa Indonesia dipisahkan koma, contoh: Tomat, Telur, Wortel, Selada. '
                  'Jangan berikan format markdown atau kalimat pembuka/penutup.',
            },
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
        'temperature': 0.2,
        'maxOutputTokens': 150,
      },
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode != 200) {
      throw HttpException(
        'Gemini API error: ${response.statusCode} - ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return const [];
    }

    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return const [];
    }

    final text = parts.first['text'] as String? ?? '';
    final ingredients = text
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .toList();

    return ingredients;
  }
}
