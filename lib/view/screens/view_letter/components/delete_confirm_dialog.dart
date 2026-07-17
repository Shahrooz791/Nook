import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

Future<void> showDeleteLetterDialog({required VoidCallback onConfirm}) {
  return Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        strong: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText('Delete this letter?', size: 16, weight: FontWeight.w600),
            Gap.v(8),
            const AppText(
              "This can't be undone.",
              size: 13,
              color: AppColors.textLo,
              align: TextAlign.center,
            ),
            Gap.v(20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.v),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: 100.r,
                      ),
                      child: const AppText('Cancel', size: 13),
                    ),
                  ),
                ),
                Gap.h(10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onConfirm();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.v),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: 100.r,
                      ),
                      child: const AppText(
                        'Delete',
                        size: 13,
                        weight: FontWeight.w600,
                        color: Color(0xFF2A0A0A),
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
