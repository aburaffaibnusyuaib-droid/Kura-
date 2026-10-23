import 'dart:io';
import 'dart:typed_data';

import '../../../core/services/gemini_service.dart';
import '../../../core/services/local_storage_service.dart';
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
    // 1. Baca bytes gambar jika ada lampiran
    Uint8List? imageBytes;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        imageBytes = await file.readAsBytes();
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

    // 3. Kirim ke Gemini Service
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
  }
}
