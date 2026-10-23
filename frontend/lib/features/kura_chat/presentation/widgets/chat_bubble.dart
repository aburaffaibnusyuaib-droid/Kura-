import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/kura_chat_models.dart';
import 'embedded_chat_recipe_card.dart';

/// Balon Chat Kura AI & Pengguna (Mockup State 3, 5, 6, 7).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  final ChatMessage message;
  final VoidCallback? onRetry;

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble(context);
    } else {
      return _buildAiBubble(context);
    }
  }

  // ── Balon Chat Pengguna (Kanan, Toska) ──────────────────────────
  Widget _buildUserBubble(BuildContext context) {
    final hasImage = message.imagePath != null && message.imagePath!.isNotEmpty;
    final isError = message.status == ChatMessageStatus.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isError)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.statusDanger, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (onRetry != null) onRetry!();
              },
              tooltip: 'Coba Lagi',
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Lampiran Gambar Pengguna
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 180, maxWidth: 220),
                      color: Colors.black12,
                      child: File(message.imagePath!).existsSync()
                          ? Image.file(
                              File(message.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Balon Teks Toska
                if (message.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isError ? AppColors.statusDanger : const Color(0xFF00B4A0),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isError ? Icons.error_outline_rounded : Icons.done_all_rounded,
                              size: 13,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Balon Chat Kura AI (Kiri, Putih Elegan) ────────────────────
  Widget _buildAiBubble(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Kura AI
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0F2F1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/mascot_home.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.smart_toy_rounded,
                  size: 18,
                  color: Color(0xFF00CBA7),
                ),
              ),
            ),
          ),

          // Konten Balon Kura AI
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                    border: Border.all(color: const Color(0xFFE0F2F1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teks Balasan Kura AI
                      Text(
                        message.text,
                        style: const TextStyle(
                          color: AppColors.deepMidnightNavy,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),

                      // ── Kartu Kesimpulan Visual (Mockup State 5) ──
                      if (message.conclusionBadge != null &&
                          message.conclusionBadge!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF81C784).withAlpha(120),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF2E7D32),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Kesimpulan: ${message.conclusionBadge}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _formatTime(message.timestamp),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Kartu Resep yang Disematkan (Mockup State 6) ──
                if (message.embeddedRecipe != null)
                  EmbeddedChatRecipeCard(recipe: message.embeddedRecipe!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
