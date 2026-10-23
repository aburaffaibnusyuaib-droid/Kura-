import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';

/// Komponen Bottom Chat Input Bar Kura AI.
/// Dirancang presisi untuk Infinix Hot 30i (Android HD+ 720x1612, 20:9)
/// dengan standar modern messaging UI (kapsul, multi-line dinamis, smart send button).
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
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textCtrl.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handleSend() {
    final text = _textCtrl.text.trim();
    final hasAttachment = widget.selectedImagePath != null;
    if (text.isEmpty && !hasAttachment) return;
    if (widget.isTyping) return;

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lampirkan Foto Makanan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih foto dari kamera atau galeri untuk dianalisis Kura AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Ambil Foto',
                    color: const Color(0xFF00B4A0),
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
    final hasText = _textCtrl.text.trim().isNotEmpty;
    final canSend = (hasText || hasImage) && !widget.isTyping;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Floating Attachment Preview (Pre-Send Thumbnail) ──
              if (hasImage) _buildAttachmentPreview(),

              // ── 2. Baris Utama (Tombol '+', Kapsul TextField, Tombol Kirim) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── A. Tombol Lampiran Kiri (Icon '+') ──────────────
                  _buildAddButton(),

                  const SizedBox(width: 8),

                  // ── B. Wadah TextField Modern (Capsule Surface) ─────
                  Expanded(
                    child: _buildCapsuleTextField(),
                  ),

                  const SizedBox(width: 8),

                  // ── C. Tombol Kirim Kanan (Smart Dynamic Action) ────
                  _buildSendButton(canSend),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Thumbnail preview foto terlampir tepat di atas input bar
  Widget _buildAttachmentPreview() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Thumbnail foto dengan tombol close
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00B4A0).withAlpha(120),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.5),
                    child: Image.file(
                      File(widget.selectedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onImageCleared();
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937).withAlpha(220),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Foto Makanan Terlampir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kura AI akan menganalisis visual makanan ini bersama pesanmu.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tombol '+' bulat modern di sisi kiri
  Widget _buildAddButton() {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: const Color(0xFFE6F7F5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _showAttachmentSheet,
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Color(0xFF00B4A0),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Wadah TextField kapsul modern dengan transisi focus border
  Widget _buildCapsuleTextField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isFocused
              ? const Color(0x6600B4A0)
              : const Color(0xFFE5E7EB),
          width: _isFocused ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _textCtrl,
        focusNode: _focusNode,
        minLines: 1,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF1F2937),
          height: 1.35,
        ),
        decoration: const InputDecoration(
          hintText: 'Tanya Kura tentang makanan...',
          hintStyle: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 2),
        ),
        onSubmitted: (_) => _handleSend(),
      ),
    );
  }

  /// Tombol Kirim Smart Dynamic Action (lingkaran 44dp)
  Widget _buildSendButton(bool canSend) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: canSend
            ? const Color(0xFF00B4A0)
            : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        boxShadow: canSend
            ? const [
                BoxShadow(
                  color: Color(0x3300B4A0),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: canSend ? _handleSend : null,
          child: Center(
            child: Icon(
              Icons.arrow_upward_rounded,
              color: canSend ? Colors.white : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ),
        ),
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
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
