import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/kura_chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/welcome_chat_view.dart';

/// Layar Utama Percakapan Pintar Kura AI Chat (7 Mockup States).
class KuraChatScreen extends ConsumerStatefulWidget {
  const KuraChatScreen({super.key});

  @override
  ConsumerState<KuraChatScreen> createState() => _KuraChatScreenState();
}

class _KuraChatScreenState extends ConsumerState<KuraChatScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kuraChatControllerProvider);
    final notifier = ref.read(kuraChatControllerProvider.notifier);

    // Auto-scroll saat pesan bertambah atau sedang mengetik
    ref.listen(kuraChatControllerProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE0F2F1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/mascot_home.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF00CBA7),
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kura AI',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  state.isTyping ? 'Mengetik...' : 'Asisten Makanan & Dapur',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: state.isTyping
                        ? const Color(0xFF00CBA7)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onSelected: (val) {
              if (val == 'clear') {
                _showClearConfirmation(context, notifier);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        color: AppColors.statusDanger, size: 18),
                    SizedBox(width: 8),
                    Text('Hapus Riwayat Chat',
                        style: TextStyle(color: AppColors.statusDanger, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Area Percakapan (Welcome View / Messages List) ────
            Expanded(
              child: state.isEmpty
                  ? WelcomeChatView(
                      onSuggestionSelected: (prompt) {
                        notifier.sendUserMessage(prompt);
                      },
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length) {
                          // Indikator Mengetik di paling bawah
                          return const TypingIndicator();
                        }
                        final msg = state.messages[index];
                        return ChatBubble(
                          message: msg,
                          onRetry: () {
                            notifier.retryMessage(msg);
                          },
                        );
                      },
                    ),
            ),

            // ── Input Bar Bawah (Keyboard Aware) ─────────────────
            ChatInputBar(
              isTyping: state.isTyping,
              selectedImagePath: state.selectedImagePath,
              onImageSelected: (path) => notifier.setImageAttachment(path),
              onImageCleared: () => notifier.clearImageAttachment(),
              onSend: (text) => notifier.sendUserMessage(text),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, KuraChatNotifier notifier) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Riwayat Chat?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          'Seluruh riwayat percakapan lokal akan dibersihkan dan memori chat akan dikosongkan.',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              notifier.clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
