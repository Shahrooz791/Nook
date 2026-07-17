import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/core/constant/app_fonts.dart';

/// Just the wordmark — no greeting, no date, no avatar, no app bar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.v, bottom: 12.v),
      child: ShaderMask(
        shaderCallback: (bounds) => AppColors.accentGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        ),
        blendMode: BlendMode.srcIn,
        child: Text(
          'Nook',
          style: TextStyle(
            fontFamily: AppFonts.serif,
            fontSize: 32.fSize,
            fontWeight: FontWeight.w700,
            color: Colors.white, // replaced by shader
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

