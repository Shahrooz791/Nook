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
              const _LoadingBar(),
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
          width: 140.h,
          height: 140.h,
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
        // Use the full logo.png from assets
        Image.asset(
          ImagesAssets.logo,
          width: 88.h,
          height: 88.h,
          fit: BoxFit.contain,
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

/// A progress bar that animates from 0 → full width smoothly over the splash
/// duration (1700 ms, starting 500 ms after fadeIn so total is ~2200 ms),
/// then holds at full. No looping — it completes exactly once.
class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    // Total splash = 2200ms. Bar fades in at ~900ms, then fills over 1100ms
    // so it completes just as navigation fires.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _progress = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Start after the fade-in delay (900 ms) + a small buffer
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = 160.h;
    return SizedBox(
      width: barWidth,
      height: 3.v,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassFillStrong,
          borderRadius: 100.r,
        ),
        clipBehavior: Clip.antiAlias,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _progress.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: 100.r,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(delay: 900.ms, duration: 500.ms);
  }
}
