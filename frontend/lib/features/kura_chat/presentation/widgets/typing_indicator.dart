import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Indikator mengetik Kura AI dengan 3 titik bergerak lembut (Mockup State 4).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar Kura AI
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
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

          // Balon Chat Mengetik
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.divider),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final progress = (_ctrl.value - delay).clamp(0.0, 1.0);
                    final bounce = math.sin(progress * math.pi).abs();

                    return Transform.translate(
                      offset: Offset(0, -bounce * 4),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00CBA7).withAlpha(
                            (120 + (bounce * 135)).toInt(),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
