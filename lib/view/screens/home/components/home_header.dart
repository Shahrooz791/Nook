import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

/// Just the wordmark — no greeting, no date, no avatar, no app bar.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.v),
      child: const AppText(
        'Nook',
        isSerif: true,
        size: 18,
        weight: FontWeight.w500,
        color: AppColors.textHi,
      ),
    );
  }
}
