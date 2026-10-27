import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Tampilan Loading AI Berkelas (Zero Dead Space) untuk Kura AI.
/// Menghadirkan maskot bernyawa (pulsing breathing + soft teal glowing shadow),
/// status ticker teks fade-switch tiap 1.5s, modern rounded gradient progress bar (8dp),
/// dan pemanfaatan dead space dengan card edukatif "Catatan Pintar Kura".
class KuraAiAnalyzingView extends StatefulWidget {
  const KuraAiAnalyzingView({
    super.key,
    required this.progress,
    this.title = 'Sedang Menganalisis Makanan...',
    this.tickerTexts,
    this.onBack,
    this.errorMessage,
    this.onRetry,
  });

  final double progress;
  final String title;
  final List<String>? tickerTexts;
  final VoidCallback? onBack;
  final String? errorMessage;
  final VoidCallback? onRetry;

  static const List<String> defaultTickers = [
    'Menghubungkan ke mata pintar Kura...',
    'Menganalisis kondisi fisik & kesegaran bahan...',
    'Menyusun evaluasi nutrisi dan rekomendasi aman...',
  ];

  static const List<String> defaultTips = [
    'Telur segar akan tenggelam mendatar di air, sedangkan telur busuk akan mengapung ke permukaan.',
    'Bungkus batang seledri dengan aluminium foil atau rendam pangkalnya di air dingin agar tetap renyah berminggu-minggu.',
    'Kemasan kaleng atau botol yang menggembung menandakan gas bakteri berbahaya (botulisme) — jangan dikonsumsi!',
    'Jangan mencuci daging ayam mentah sebelum dimasak karena percikan air menyebarkan bakteri ke peralatan dapur.',
    'Simpan kentang dan bawang bombay terpisah; gas dari bawang membuat kentang cepat bertunas dan lembek.',
    'Batang brokoli dan kembang kol kaya serat; iris tipis untuk tumisan atau rebusan kaldu sayur homemade.',
    'Minyak goreng yang berbusa tebal, berbau tengik, atau berwarna gelap pekat sebaiknya tidak digunakan kembali.',
    'Simpan tomat di suhu ruang dengan posisi tangkai di bawah agar tekstur dan rasanya tetap prima.',
    'Kumpulkan sisa kulit wortel dan batang seledri di freezer, rebus kapan saja untuk membuat kaldu sayur gurih.',
    'Roti berjamur harus dibuang seluruhnya karena akar jamur mikroskopis menembus bagian yang tampak bersih.',
    'Madu murni tidak memiliki masa kedaluwarsa jika disimpan dalam wadah tertutup rapat di tempat sejuk.',
    'Rendam potongan akar daun bawang di segelas air kecil; tunas daun baru akan tumbuh kembali dalam 3 hari.',
    'Simpan sisa makanan dalam wadah kaca kedap udara agar aroma makanan di kulkas tidak saling bercampur.',
    'Bungkus pangkal tangkai pisang dengan plastik wrap untuk memperlambat pelepasan gas etilen alami.',
    'Air cucian beras pertama kaya nutrisi vitamin B; gunakan untuk menyiram tanaman hias di rumah.',
  ];

  @override
  State<KuraAiAnalyzingView> createState() => _KuraAiAnalyzingViewState();
}

class _KuraAiAnalyzingViewState extends State<KuraAiAnalyzingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  Timer? _tickerTimer;
  Timer? _tipTimer;
  int _currentTickerIndex = 0;
  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animasi pernapasan/pulsing halus (skala 0.96 ke 1.04 dengan Curves.easeInOut)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Status Ticker berganti halus setiap 1.5 detik
    final tickers = widget.tickerTexts ?? KuraAiAnalyzingView.defaultTickers;
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) {
        setState(() {
          _currentTickerIndex = (_currentTickerIndex + 1) % tickers.length;
        });
      }
    });

    // Catatan Pintar Kura berganti setiap 4 detik
    _currentTipIndex = DateTime.now().second % KuraAiAnalyzingView.defaultTips.length;
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentTipIndex =
              (_currentTipIndex + 1) % KuraAiAnalyzingView.defaultTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tipTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickers = widget.tickerTexts ?? KuraAiAnalyzingView.defaultTickers;
    final currentTicker = tickers[_currentTickerIndex];
    final currentTip = KuraAiAnalyzingView.defaultTips[_currentTipIndex];
    final progressValue = widget.progress.clamp(0.0, 1.0);
    final percentage = (progressValue * 100).toInt();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE6F7F5), // Toska pastel lembut
            Colors.white,       // Putih bersih
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onBack!();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),

            // Main Content (Zero Dead Space atau Error State)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: (widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 180,
                              maxWidth: 180,
                            ),
                            child: Image.asset(
                              'assets/images/mascot_confused.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.error_outline_rounded,
                                size: 80,
                                color: AppColors.statusDanger,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Analisis Belum Berhasil',
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.errorMessage!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          if (widget.onRetry != null)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  widget.onRetry!();
                                },
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white),
                                label: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.onBack != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: widget.onBack,
                                style: OutlinedButton.styleFrom(
                                  side:
                                      const BorderSide(color: Color(0xFFD1D5DB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 8),

                    // ── Bagian Atas-Tengah: Maskot Bernyawa & Soft Glowing Shadow ──
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft glowing circular teal shadow
                        Container(
                          width: 170,
                          height: 170,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3300B4A0),
                                blurRadius: 36,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),

                        // Maskot Animasi Bernapas (0.96 -> 1.04)
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 180,
                          ),
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Image.asset(
                              'assets/images/mascot_analyzing.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 140,
                                height: 140,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2F1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.biotech_rounded,
                                  size: 64,
                                  color: AppColors.electricTeal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Judul & Status Ticker Teks (Fade Switch tiap 1.5s) ──
                    Column(
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontSize: 21,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 38,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              currentTicker,
                              key: ValueKey<String>(currentTicker),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF00897B),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Modern Smooth Progress Bar (Tinggi 8dp) ──
                    Column(
                      children: [
                        Stack(
                          children: [
                            // Background bar
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // Gradient Progress Bar
                            FractionallySizedBox(
                              widthFactor: progressValue,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00CBA7),
                                      Color(0xFF00E676),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4D00CBA7),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Memproses citra visual...',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: const Color(0xFF00897B),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ── Pemanfaatan Dead Space Bawah: Card "Catatan Pintar Kura" ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x1400B4A0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF00897B),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tahukah Kamu?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              currentTip,
                              key: ValueKey<String>(currentTip),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.deepMidnightNavy,
                                height: 1.45,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
