import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- PUBLIC THEME ----------
  static const Color bgA = Color(0xFF0D0D12);
  static const Color bgB = Color(0xFF1A1620);
  static const Color accent = Color(0xFFE8B96A);
  static const Color accent2 = Color(0xFFD89AA0);
  static const Color textHi = Color(0xFFF5F5F7);
  static const Color textLo = Color(0xFF9A9AA5);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color danger = Color(0xFFE27D7D);
  static Color glassFill = Colors.white.withValues(alpha: 0.07);
  static Color glassFillStrong = Colors.white.withValues(alpha: 0.10);

  // ---------- VAULT THEME ----------
  static const Color vaultBgA = Color(0xFF0A0A0D);
  static const Color vaultBgB = Color(0xFF0D1120);
  static const Color vaultAccent = Color(0xFF4DE8D0);
  static const Color vaultAccent2 = Color(0xFF6C7CFF);
  static const Color vaultTextHi = Color(0xFFFFFFFF);
  static const Color vaultTextLo = Color(0xFF7C8494);
  static const Color vaultDanger = Color(0xFFFF6B6B);
  static Color vaultGlassFill = const Color(0xFF8CB4FF).withValues(alpha: 0.05);
  static Color vaultGlassFillStrong = const Color(0xFF8CC8FF).withValues(alpha: 0.09);
  static Color vaultGlassBorder = const Color(0xFFB4D2FF).withValues(alpha: 0.14);

  // ---------- GRADIENTS ----------
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );

  static const LinearGradient vaultAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vaultAccent, vaultAccent2],
  );

  static const RadialGradient publicBgGradient = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.1,
    colors: [bgB, bgA],
  );

  static const RadialGradient vaultBgGradient = RadialGradient(
    center: Alignment(0, -0.6),
    radius: 1.1,
    colors: [vaultBgB, vaultBgA],
  );
}
