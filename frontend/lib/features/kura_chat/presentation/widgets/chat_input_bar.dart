import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

/// Bar Input Pesan Chat dengan Dukungan Multimodal Image Attachment (Mockup State 2 & 5).
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.selectedImagePath,
    required this.onImageSelected,
    required this.onImageCleared,
    this.isTyping = false,
  });

  final void Function(String text) onSend;
  final String? selectedImagePath;
  final void Function(String path) onImageSelected;
  final VoidCallback onImageCleared;
  final bool isTyping;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty && widget.selectedImagePath == null) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _textCtrl.clear();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        widget.onImageSelected(picked.path);
      }
    } catch (_) {}
  }

  void _showAttachmentSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lampirkan Foto Makanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.deepMidnightNavy,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Ambil Foto',
                    color: const Color(0xFF00CBA7),
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _AttachmentOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Pilih Galeri',
                    color: AppColors.sunsetOrange,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.selectedImagePath != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Preview Thumbnail Gambar yang Dilampirkan ────────────
          if (hasImage) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF80CBC4)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.selectedImagePath!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Foto makanan siap dianalisis Kura AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF004D40),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                    onPressed: widget.onImageCleared,
                    tooltip: 'Hapus foto',
                  ),
                ],
              ),
            ),
          ],

          // ── Baris Input Text & Tombol Kirim ──────────────────────
          Row(
            children: [
              // Tombol Lampiran (Attachment)
              IconButton(
                icon: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF00CBA7),
                  size: 22,
                ),
                onPressed: _showAttachmentSheet,
                tooltip: 'Lampirkan Foto',
              ),

              // TextField Input Pesan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesanmu...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Tombol Kirim (Toska Bulat)
              GestureDetector(
                onTap: widget.isTyping ? null : _handleSend,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.isTyping
                        ? Colors.grey.shade300
                        : const Color(0xFF00CBA7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.deepMidnightNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
