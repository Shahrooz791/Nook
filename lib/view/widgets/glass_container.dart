import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';

/// Reusable frosted-glass card used across every screen (public + vault).
/// Pass [isVault] true to automatically switch to the cool vault glass tint.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.isVault = false,
    this.strong = false,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final bool isVault;
  final bool strong;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final Color fill = isVault
        ? (strong ? AppColors.vaultGlassFillStrong : AppColors.vaultGlassFill)
        : (strong ? AppColors.glassFillStrong : AppColors.glassFill);
    final Color border = isVault ? AppColors.vaultGlassBorder : AppColors.glassBorder;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius.r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius.r,
              border: Border.all(color: border, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
