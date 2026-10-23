import 'dart:convert';
import '../../atur/domain/atur_models.dart';

/// Status pengiriman pesan chat
enum ChatMessageStatus { sending, sent, error }

/// Model data pesan obrolan Kura AI Chat.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.imagePath,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
    this.conclusionBadge,
    this.embeddedRecipe,
  });

  final String id;
  final bool isUser;
  final String text;
  final String? imagePath;
  final DateTime timestamp;
  final ChatMessageStatus status;
  final String? conclusionBadge;
  final Recipe? embeddedRecipe;

  ChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    String? imagePath,
    DateTime? timestamp,
    ChatMessageStatus? status,
    String? conclusionBadge,
    Recipe? embeddedRecipe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      conclusionBadge: conclusionBadge ?? this.conclusionBadge,
      embeddedRecipe: embeddedRecipe ?? this.embeddedRecipe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUser': isUser,
      'text': text,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'conclusionBadge': conclusionBadge,
      'embeddedRecipe': embeddedRecipe?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: json['isUser'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: ChatMessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChatMessageStatus.sent,
      ),
      conclusionBadge: json['conclusionBadge'] as String?,
      embeddedRecipe: json['embeddedRecipe'] != null
          ? Recipe.fromJson(json['embeddedRecipe'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Parser cerdas untuk mengekstrak [KESIMPULAN: ...] dan ```recipe_json ... ``` dari respons AI
  static (String cleanText, String? conclusion, Recipe? recipe) parseAiResponse(String raw) {
    String clean = raw;
    String? conclusion;
    Recipe? recipe;

    // 1. Ekstrak Kesimpulan: [KESIMPULAN: ...]
    final conclusionRegex = RegExp(r'\[KESIMPULAN:\s*([^\]]+)\]', caseSensitive: false);
    final conclusionMatch = conclusionRegex.firstMatch(raw);
    if (conclusionMatch != null) {
      conclusion = conclusionMatch.group(1)?.trim();
      clean = clean.replaceAll(conclusionMatch.group(0)!, '').trim();
    }

    // 2. Ekstrak Resep: ```recipe_json ... ```
    final recipeRegex = RegExp(r'```recipe_json\s*([\s\S]*?)\s*```', caseSensitive: false);
    final recipeMatch = recipeRegex.firstMatch(raw);
    if (recipeMatch != null) {
      final jsonString = recipeMatch.group(1)?.trim() ?? '{}';
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        recipe = Recipe.fromJson(decoded);
      } catch (_) {}
      clean = clean.replaceAll(recipeMatch.group(0)!, '').trim();
    }

    return (clean, conclusion, recipe);
  }
}
