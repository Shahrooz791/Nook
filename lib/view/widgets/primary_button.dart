import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

/// Reusable full-width gradient pill button used across every screen.
/// Pass [isVault] true to switch to the cool vault gradient.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isVault = false,
    this.textColor = const Color(0xFF1A1420),
    this.width,
  });

  final String label;
  final VoidCallback onTap;
  final bool isVault;
  final Color textColor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 16.v),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isVault ? AppColors.vaultAccentGradient : AppColors.accentGradient,
          borderRadius: 100.r,
        ),
        child: AppText(
          label,
          size: 15,
          weight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
