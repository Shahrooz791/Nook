import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/add_letter_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/constant/app_fonts.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/screens/add_letter/components/seal_overlay.dart';
import 'package:nook/view/screens/add_letter/components/unlock_toggle_section.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/primary_button.dart';

class AddLetterScreen extends StatelessWidget {
  const AddLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddLetterController controller = Get.put(AddLetterController());

    return Scaffold(
      backgroundColor: AppColors.bgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.publicBgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                child: Column(
                  children: [
                    Gap.v(8),
                    _TopBar(),
                    Gap.v(16),
                    Expanded(
                      child: TextField(
                        controller: controller.textController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        cursorColor: AppColors.accent,
                        style: TextStyle(
                          fontFamily: AppFonts.serif,
                          fontSize: 20.fSize,
                          color: AppColors.textHi,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Dear future me...',
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.serif,
                            fontSize: 20.fSize,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textLo,
                          ),
                        ),
                      ),
                    ),
                    Gap.v(16),
                    Obx(
                      () => UnlockToggleSection(
                        enabled: controller.hasUnlockTime.value,
                        unlockDate: controller.unlockDate.value,
                        onToggle: controller.toggleUnlockTime,
                        onPickDate: () => controller.pickUnlockDate(context),
                      ),
                    ),
                    Gap.v(20),
                    Obx(
                      () => PrimaryButton(
                        label: controller.hasUnlockTime.value ? 'Seal This Letter' : 'Save Letter',
                        onTap: controller.saveLetter,
                        width: double.infinity,
                      ),
                    ),
                    Gap.v(20),
                  ],
                ),
              ),
              Obx(
                () => controller.isSealing.value ? const SealOverlay() : const SizedBox.shrink(),
              ),
            ],
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
            child: AppText('New Letter', size: 15, weight: FontWeight.w500),
          ),
        ),
        SizedBox(width: 22.h),
      ],
    );
  }
}
