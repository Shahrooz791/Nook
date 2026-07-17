import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/view/widgets/app_text.dart';

/// Small confirmation shown for a beat while a sealed letter is saved.
class SealOverlay extends StatelessWidget {
  const SealOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.bgA.withValues(alpha: 0.88),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 44,
            color: AppColors.accent,
          )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .shake(hz: 3, duration: 250.ms),
          const SizedBox(height: 14),
          const AppText('Sealing your letter…', size: 13, color: AppColors.textLo),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
