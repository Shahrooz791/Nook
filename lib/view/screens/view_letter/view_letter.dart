import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/view_letter_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/date_formatter.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/screens/view_letter/components/delete_confirm_dialog.dart';
import 'package:nook/view/screens/view_letter/components/letter_action_icons.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

/// Only reachable by tapping an unlocked letter from Home.
class ViewLetterScreen extends StatelessWidget {
  const ViewLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ViewLetterController controller = Get.put(ViewLetterController());

    return Scaffold(
      backgroundColor: AppColors.bgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.publicBgGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
            child: Column(
              children: [
                Gap.v(8),
                _TopBar(),
                Gap.v(16),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const SizedBox.shrink();
                    }
                    final letter = controller.letter.value;
                    if (letter == null) {
                      return const Center(
                        child: AppText('This letter no longer exists.', color: AppColors.textLo),
                      );
                    }
                    return GlassContainer(
                      strong: true,
                      padding: EdgeInsets.all(22.h),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'To: Future Me',
                              size: 12,
                              color: AppColors.accent,
                              letterSpacing: 0.6,
                            ),
                            Gap.v(6),
                            AppText(
                              'Written ${DateFormatter.short(letter.createdAt)} · '
                              'Unlocked ${DateFormatter.short(letter.unlockAt)}',
                              size: 11.5,
                              color: AppColors.textLo,
                            ),
                            Gap.v(18),
                            AppText(letter.content, isSerif: true, size: 18, height: 1.7),
                            Gap.v(28),
                            LetterActionIcons(
                              onDelete: () => showDeleteLetterDialog(
                                onConfirm: controller.deleteLetter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                Gap.v(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_rounded, color: AppColors.textHi, size: 22.h),
        ),
        const Expanded(
          child: Center(
            child: AppText('Letter', size: 15, weight: FontWeight.w500),
          ),
        ),
        SizedBox(width: 22.h),
      ],
    );
  }
}
