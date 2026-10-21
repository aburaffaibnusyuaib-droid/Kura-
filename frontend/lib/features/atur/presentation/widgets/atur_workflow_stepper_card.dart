import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Kartu Tunggal Berisi 4 Langkah Kerja Atur Makanan (Mockup 01).
class AturWorkflowStepperCard extends StatelessWidget {
  const AturWorkflowStepperCard({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      _WorkflowStep(
        number: 1,
        title: 'Foto Bahan Makanan',
        description: 'Foto bahan makanan yang tersisa di rumah.',
      ),
      _WorkflowStep(
        number: 2,
        title: 'AI Mengenali Bahan',
        description: 'AI mengenali bahan dan memberi rekomendasi resep.',
      ),
      _WorkflowStep(
        number: 3,
        title: 'Pilih Resep Favorit',
        description: 'Pilih resep yang kamu suka dari rekomendasi.',
      ),
      _WorkflowStep(
        number: 4,
        title: 'Mulai Memasak!',
        description: 'Dapatkan resep lengkap dan mulai memasak!',
        isLast: true,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.electricTeal.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.deepMidnightNavy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Cara Kerja',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => _StepRow(step: step)),
        ],
      ),
    );
  }
}

class _WorkflowStep {
  const _WorkflowStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final int number;
  final String title;
  final String description;
  final bool isLast;
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final _WorkflowStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Lingkaran Nomor & Garis Penghubung (Stepper) ────────
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.electricTeal,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${step.number}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.deepMidnightNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 38,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CustomPaint(
                  painter: _DashedLinePainter(
                    color: AppColors.electricTeal.withAlpha(120),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // ── Teks Judul & Deskripsi ──────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
