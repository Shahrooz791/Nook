import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

class VaultCategoryCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const VaultCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        isVault: true,
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(10.h),
              decoration: BoxDecoration(
                color: AppColors.vaultGlassFillStrong,
                borderRadius: 12.r,
              ),
              child: icon,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.vaultTextHi,
                ),
                Gap.v(4),
                AppText(
                  subtitle,
                  size: 12,
                  color: AppColors.vaultTextLo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
