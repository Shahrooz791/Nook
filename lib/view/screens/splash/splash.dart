import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:nook/controller/splash_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/constant/image_assets.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.publicBgGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GlowingLogo(),
              Gap.v(18),
              AppText(
                'Nook',
                isSerif: true,
                size: 30,
                weight: FontWeight.w500,
                color: AppColors.textHi,
              ).animate().fadeIn(
                    delay: 400.ms,
                    duration: 600.ms,
                  ),
              Gap.v(10),
              AppText(
                'Letters to your future self',
                size: 13,
                color: AppColors.textLo,
                letterSpacing: 0.3,
              ).animate().fadeIn(
                    delay: 700.ms,
                    duration: 600.ms,
                  ),
              Gap.v(56),
              _LoadingBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowingLogo extends StatelessWidget {
  const _GlowingLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130.h,
          height: 130.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.45),
                AppColors.accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1.15, 1.15),
              duration: 1800.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(duration: 600.ms),
        Image.asset(
          ImagesAssets.logo,
          width: 72.h,
          height: 72.h,
        ).animate().scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
      ],
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.h,
      height: 3.v,
      decoration: BoxDecoration(
        color: AppColors.glassFillStrong,
        borderRadius: 100.r,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 24.h,
          height: 3.v,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: 100.r,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .moveX(begin: 0, end: 36.h, duration: 900.ms, curve: Curves.easeInOut)
            .then()
            .moveX(begin: 36.h, end: 0, duration: 900.ms, curve: Curves.easeInOut),
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 500.ms);
  }
}
