import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/food_check_models.dart';
import '../controllers/food_check_controller.dart';

/// Layar Kuesioner Lanjutan untuk Makanan Segar (Mockup 10).
class FreshFoodQuestionnaireScreen extends ConsumerStatefulWidget {
  const FreshFoodQuestionnaireScreen({super.key});

  @override
  ConsumerState<FreshFoodQuestionnaireScreen> createState() =>
      _FreshFoodQuestionnaireScreenState();
}

class _FreshFoodQuestionnaireScreenState
    extends ConsumerState<FreshFoodQuestionnaireScreen> {
  int _currentStep = 0;
  String _selectedTexture = 'Lembut';
  String _selectedAroma = 'Segar alami';
  String _selectedStorage = 'Kulkas < 4 hari';

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'Sedikit pertanyaan lagi...',
      'subtitle':
          'Untuk memastikan hasil yang lebih akurat, bagaimana tekstur bahan ini?',
      'options': ['Lembut', 'Sedikit keras', 'Lembek', 'Tidak tahu'],
    },
    {
      'title': 'Bagaimana dengan aromanya?',
      'subtitle':
          'Apakah tercium aroma khas yang segar atau ada aroma menusuk/asam?',
      'options': [
        'Segar alami',
        'Sedikit menyengat',
        'Bau asam / busuk',
        'Tidak berbau'
      ],
    },
    {
      'title': 'Berapa lama sudah disimpan?',
      'subtitle':
          'Informasi penyimpanan membantu memperkirakan potensi pertumbuhan mikroba.',
      'options': [
        'Baru dibeli hari ini',
        'Kulkas < 4 hari',
        'Kulkas > 7 hari',
        'Suhu ruangan > 2 hari'
      ],
    },
  ];

  void _onNext() {
    HapticFeedback.lightImpact();
    if (_currentStep < _questions.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Simpan jawaban kuesioner ke controller
      ref.read(foodCheckControllerProvider.notifier).updateQuestionnaire(
            FreshFoodQuestionnaireAnswers(
              texture: _selectedTexture,
              aroma: _selectedAroma,
              storageDuration: _selectedStorage,
            ),
          );
      context.push(AppRoutes.foodCheckAnalyzing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentStep];
    final options = currentQ['options'] as List<String>;
    final currentVal = _currentStep == 0
        ? _selectedTexture
        : _currentStep == 1
            ? _selectedAroma
            : _selectedStorage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          '${_currentStep + 1} / ${_questions.length}',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Maskot dengan Speech Bubble (Mockup 10)
                      Center(
                        child: Image.asset(
                          'assets/images/mascot_home.png',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQ['title'] as String,
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQ['subtitle'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Daftar Pilihan Jawaban
                      ...options.map((opt) {
                        final isSelected = opt == currentVal;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.electricTeal
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                if (_currentStep == 0) _selectedTexture = opt;
                                if (_currentStep == 1) _selectedAroma = opt;
                                if (_currentStep == 2) _selectedStorage = opt;
                              });
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            title: Text(
                              opt,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.deepMidnightNavy : AppColors.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.electricTeal)
                                : const Icon(Icons.radio_button_off_rounded, color: AppColors.textHint),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Tombol Lanjut Bawah
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricTeal,
                      foregroundColor: AppColors.deepMidnightNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentStep == _questions.length - 1
                          ? 'Periksa Sekarang'
                          : 'Lanjut',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
