import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/services/gemini_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/image_compressor.dart';
import '../domain/kura_chat_models.dart';

abstract class KuraChatRepository {
  List<ChatMessage> loadHistory();
  Future<bool> saveHistory(List<ChatMessage> messages);
  Future<bool> clearHistory();
  Future<ChatMessage> sendMessage({
    required String text,
    String? imagePath,
    required List<ChatMessage> currentHistory,
  });
}

class KuraChatRepositoryImpl implements KuraChatRepository {
  KuraChatRepositoryImpl({
    required this.geminiService,
    required this.localStorageService,
  });

  final GeminiService geminiService;
  final LocalStorageService localStorageService;

  @override
  List<ChatMessage> loadHistory() {
    final raw = localStorageService.getChatHistory();
    return raw.map((json) => ChatMessage.fromJson(json)).toList();
  }

  @override
  Future<bool> saveHistory(List<ChatMessage> messages) async {
    final raw = messages.map((m) => m.toJson()).toList();
    return await localStorageService.saveChatHistory(raw);
  }

  @override
  Future<bool> clearHistory() async {
    return await localStorageService.clearChatHistory();
  }

  @override
  Future<ChatMessage> sendMessage({
    required String text,
    String? imagePath,
    required List<ChatMessage> currentHistory,
  }) async {
    // 1. Baca bytes gambar jika ada lampiran & kompres secara asinkron
    Uint8List? imageBytes;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        final raw = await file.readAsBytes();
        imageBytes = await ImageCompressor.compressBytes(
          raw,
          maxDim: 800,
          quality: 70,
        );
      }
    }

    // 2. Format riwayat untuk sliding-window context (ambil maksimal 8 pesan terakhir)
    final historyPayload = currentHistory
        .take(8)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    // 3. Kirim ke Gemini Service dengan pemulihan error berkelas
    try {
      final rawResponse = await geminiService.sendChatMessage(
        prompt: text,
        imageBytes: imageBytes,
        conversationHistory: historyPayload,
      );

      // 4. Parsing response untuk kesimpulan dan resep
      final (cleanText, conclusion, recipe) = ChatMessage.parseAiResponse(rawResponse);

      return ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: cleanText,
        timestamp: DateTime.now(),
        status: ChatMessageStatus.sent,
        conclusionBadge: conclusion,
        embeddedRecipe: recipe,
      );
    } on TimeoutException {
      return ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'Waktu respon habis (60 detik). Jaringan lambat, silakan coba lagi.',
        timestamp: DateTime.now(),
        status: ChatMessageStatus.error,
      );
    } on SocketException {
      return ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'Tidak ada koneksi internet. Periksa koneksi data atau Wi-Fi Anda dan coba lagi.',
        timestamp: DateTime.now(),
        status: ChatMessageStatus.error,
      );
    } catch (_) {
      return ChatMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: 'Terjadi gangguan jaringan atau server sedang sibuk. Silakan coba sesaat lagi.',
        timestamp: DateTime.now(),
        status: ChatMessageStatus.error,
      );
    }
  }
}
