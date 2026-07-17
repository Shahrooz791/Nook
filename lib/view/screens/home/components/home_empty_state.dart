import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mail_outline_rounded,
              size: 38.h,
              color: AppColors.textLo,
            ),
            Gap.v(16),
            const AppText(
              'Write your first letter to the future.',
              isSerif: true,
              size: 16,
              align: TextAlign.center,
              color: AppColors.textLo,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
