import 'package:flutter_test/flutter_test.dart';
import 'package:kura_ai/core/services/local_storage_service.dart';
import 'package:kura_ai/features/kura_chat/domain/kura_chat_models.dart';

void main() {
  group('ChatMessage & AI Response Parser', () {
    test('parses plain AI response without conclusion or recipe', () {
      const rawText = 'Halo! Saya Kura AI. Ada yang bisa saya bantu terkait makanan Anda hari ini?';
      final (clean, conclusion, recipe) = ChatMessage.parseAiResponse(rawText);

      expect(clean, rawText);
      expect(conclusion, isNull);
      expect(recipe, isNull);
    });

    test('extracts [KESIMPULAN: ...] badge and removes it from clean text', () {
      const rawText = 'Bayam Anda masih sangat segar.\n[KESIMPULAN: Aman dan Segar]\nBagus untuk dimasak sup.';
      final (clean, conclusion, recipe) = ChatMessage.parseAiResponse(rawText);

      expect(conclusion, 'Aman dan Segar');
      expect(clean.contains('[KESIMPULAN'), isFalse);
      expect(clean.contains('Bayam Anda masih sangat segar.'), isTrue);
    });

    test('extracts ```recipe_json``` block and instantiates Recipe model', () {
      const rawText = '''
Ini resep tumis bayam yang lezat:
```recipe_json
{
  "id": "recipe_101",
  "title": "Tumis Bayam Bawang Putih",
  "cook_time": "10 menit",
  "difficulty": "Mudah",
  "servings": "2 porsi",
  "calories": "85 kkal",
  "ingredients": ["1 ikat bayam", "2 siung bawang putih"],
  "steps": ["Tumis bawang putih", "Masukkan bayam hingga layu"],
  "zero_waste_tip": "Gunakan juga batang bayam muda yang renyah"
}
```
Selamat mencoba!
''';

      final (clean, conclusion, recipe) = ChatMessage.parseAiResponse(rawText);

      expect(recipe, isNotNull);
      expect(recipe!.name, 'Tumis Bayam Bawang Putih');
      expect(recipe.durationMinutes, greaterThan(0));
      expect(recipe.difficulty, 'Mudah');
      expect(recipe.ingredients.length, 2);
      expect(recipe.steps.length, 2);
      expect(clean.contains('recipe_json'), isFalse);
      expect(clean.contains('Selamat mencoba!'), isTrue);
    });

    test('ChatMessage json round-trip preserves all fields', () {
      final original = ChatMessage(
        id: 'msg_test_1',
        isUser: false,
        text: 'Halo dari Kura AI',
        timestamp: DateTime(2026, 10, 23, 12, 0, 0),
        status: ChatMessageStatus.sent,
        conclusionBadge: 'Aman Dikonsumsi',
      );

      final json = original.toJson();
      final restored = ChatMessage.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.isUser, original.isUser);
      expect(restored.text, original.text);
      expect(restored.conclusionBadge, original.conclusionBadge);
      expect(restored.status, original.status);
    });
  });

  group('LocalStorageService Chat & Onboarding', () {
    test('saves and retrieves chat history in-memory when prefs is null', () async {
      final storage = LocalStorageService();

      expect(storage.getChatHistory(), isEmpty);

      final messages = [
        {'id': '1', 'text': 'Pesan 1', 'isUser': true},
        {'id': '2', 'text': 'Pesan 2', 'isUser': false},
      ];

      await storage.saveChatHistory(messages);
      final loaded = storage.getChatHistory();
      expect(loaded.length, 2);
      expect(loaded.first['text'], 'Pesan 1');

      await storage.clearChatHistory();
      expect(storage.getChatHistory(), isEmpty);
    });

    test('handles onboarding state properly in-memory', () async {
      final storage = LocalStorageService();

      expect(storage.isOnboardingDone(), isFalse);
      await storage.setOnboardingDone(true);
      expect(storage.isOnboardingDone(), isTrue);
    });
  });
}
