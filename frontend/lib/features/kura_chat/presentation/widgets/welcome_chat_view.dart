import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Tampilan Welcome State & Suggestion Chips untuk Kura AI Chat (Mockup State 1 & 2).
/// Ditampilkan saat obrolan masih kosong dan otomatis berganti ke daftar pesan setelah pesan pertama.
class WelcomeChatView extends StatelessWidget {
  const WelcomeChatView({
    super.key,
    required this.onSuggestionSelected,
  });

  final void Function(String text) onSuggestionSelected;

  static const List<(String title, IconData icon)> _categories = [
    ('Informasi Makanan & Nutrisi', Icons.eco_rounded),
    ('Tips Kesehatan & Pola Makan', Icons.health_and_safety_rounded),
    ('Resep & Ide Masakan', Icons.restaurant_menu_rounded),
    ('Pertanyaan Umum', Icons.chat_bubble_outline_rounded),
  ];

  static const List<String> _quickSuggestions = [
    'Makanan apa yang baik untuk daya tahan tubuh?',
    'Cara mengolah sayur agar tidak kehilangan nutrisi?',
    'Bagaimana ciri daging ayam yang masih segar?',
    'Ide masak praktis dari nasi sisa semalam',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting Header ──────────────────────────────────────
          Row(
            children: [
              Text(
                'Halo, Teman Kura! ',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text('👋', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Aku Kura, asisten AI kamu untuk pertanyaan seputar makanan, nutrisi, resep anti-mubazir, dan kesehatan.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // ── Maskot Kura AI ──────────────────────────────────────
          Center(
            child: Image.asset(
              'assets/images/mascot_home.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/mascot_analyzing.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Kategori Pilihan (Coba Tanyakan Tentang) ─────────────
          Text(
            'Coba tanyakan tentang:',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          ..._categories.map((cat) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0F2F1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cat.$2, color: const Color(0xFF00897B), size: 18),
                ),
                title: Text(
                  cat.$1,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepMidnightNavy,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF00897B),
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSuggestionSelected('Tolong jelaskan tentang ${cat.$1}');
                },
              ),
            );
          }),

          const SizedBox(height: 18),

          // ── Suggestion Chips (Atau coba pertanyaan ini) ─────────
          Text(
            'Atau coba pertanyaan ini:',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickSuggestions.map((query) {
              return ActionChip(
                backgroundColor: const Color(0xFFF2FBF9),
                side: const BorderSide(color: Color(0xFFB2DFDB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                label: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF004D40),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onSuggestionSelected(query);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
