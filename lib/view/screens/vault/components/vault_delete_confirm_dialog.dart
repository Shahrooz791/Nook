import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

Future<bool?> showVaultDeleteDialog({
  required String title,
  required String message,
  VoidCallback? onConfirm,
}) {
  return Get.dialog<bool>(
    Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        isVault: true,
        strong: true,
        padding: EdgeInsets.all(20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              title,
              size: 16,
              weight: FontWeight.w600,
              color: AppColors.vaultTextHi,
              align: TextAlign.center,
            ),
            Gap.v(10),
            AppText(
              message,
              size: 13,
              color: AppColors.vaultTextLo,
              align: TextAlign.center,
              height: 1.4,
            ),
            Gap.v(20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.v),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.vaultGlassBorder),
                        borderRadius: 100.r,
                      ),
                      child: const AppText(
                        'Cancel',
                        size: 13,
                        color: AppColors.vaultTextLo,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Gap.h(10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back(result: true);
                      onConfirm?.call();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.v),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.vaultDanger,
                        borderRadius: 100.r,
                      ),
                      child: const AppText(
                        'Delete',
                        size: 13,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
