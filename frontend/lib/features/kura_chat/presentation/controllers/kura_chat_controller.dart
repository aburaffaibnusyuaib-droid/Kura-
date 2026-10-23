import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';
import '../../data/kura_chat_repository.dart';
import '../../domain/kura_chat_models.dart';

final kuraChatRepositoryProvider = Provider<KuraChatRepository>((ref) {
  return KuraChatRepositoryImpl(
    geminiService: ref.watch(geminiServiceProvider),
    localStorageService: ref.watch(localStorageServiceProvider),
  );
});

class KuraChatState {
  const KuraChatState({
    this.messages = const [],
    this.isTyping = false,
    this.selectedImagePath,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isTyping;
  final String? selectedImagePath;
  final String? errorMessage;

  bool get isEmpty => messages.isEmpty;

  KuraChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? selectedImagePath,
    String? errorMessage,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return KuraChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      selectedImagePath:
          clearImage ? null : (selectedImagePath ?? this.selectedImagePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class KuraChatNotifier extends StateNotifier<KuraChatState> {
  KuraChatNotifier(this._repository) : super(const KuraChatState()) {
    _loadInitialHistory();
  }

  final KuraChatRepository _repository;

  void _loadInitialHistory() {
    final history = _repository.loadHistory();
    state = state.copyWith(messages: history);
  }

  void setImageAttachment(String path) {
    state = state.copyWith(selectedImagePath: path);
  }

  void clearImageAttachment() {
    state = state.copyWith(clearImage: true);
  }

  Future<void> sendUserMessage(String text, [String? overrideImagePath]) async {
    final trimmed = text.trim();
    final imagePath = overrideImagePath ?? state.selectedImagePath;
    if (trimmed.isEmpty && imagePath == null) return;

    // 1. Buat pesan pengguna
    final userMessage = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      isUser: true,
      text: trimmed,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sent,
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
      isTyping: true,
      clearImage: true,
      clearError: true,
    );

    // Simpan ke local storage
    unawaited(_repository.saveHistory(updatedMessages));

    // 2. Request balasan ke Gemini
    try {
      final aiResponse = await _repository.sendMessage(
        text: trimmed,
        imagePath: imagePath,
        currentHistory: state.messages,
      );

      final finalMessages = [...state.messages, aiResponse];
      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
      );

      // Simpan ke local storage
      unawaited(_repository.saveHistory(finalMessages));
    } catch (e) {
      final failedUserMsg = userMessage.copyWith(status: ChatMessageStatus.error);
      final errorMessages = state.messages.map((m) {
        return m.id == userMessage.id ? failedUserMsg : m;
      }).toList();

      state = state.copyWith(
        messages: errorMessages,
        isTyping: false,
        errorMessage: 'Gagal mendapatkan balasan dari Kura AI. Periksa koneksi internet Anda.',
      );
    }
  }

  Future<void> retryMessage(ChatMessage message) async {
    // Cari pesan error, hapus error dan kirim ulang
    final text = message.text;
    final imagePath = message.imagePath;

    final cleanedList = state.messages.where((m) => m.id != message.id).toList();
    state = state.copyWith(messages: cleanedList);

    await sendUserMessage(text, imagePath);
  }

  Future<void> clearAll() async {
    await _repository.clearHistory();
    state = const KuraChatState();
  }
}

final kuraChatControllerProvider =
    StateNotifierProvider<KuraChatNotifier, KuraChatState>((ref) {
  return KuraChatNotifier(ref.watch(kuraChatRepositoryProvider));
});
