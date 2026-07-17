import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/constant/app_fonts.dart';
import 'package:nook/core/utils/size_utils.dart';

/// Single reusable text widget for the whole app.
/// Always use this instead of the raw [Text] widget so every screen
/// stays consistent in font, sizing (via [fSize]) and color.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.size = 14,
    this.color = AppColors.textHi,
    this.weight = FontWeight.w400,
    this.isSerif = false,
    this.align,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
    this.decoration,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight weight;

  /// True = Cormorant Garamond (letter content / warm headings).
  /// False = Poppins (everything else, the default).
  final bool isSerif;

  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: isSerif ? AppFonts.serif : AppFonts.poppins,
        fontSize: size.fSize,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      ),
    );
  }
}
