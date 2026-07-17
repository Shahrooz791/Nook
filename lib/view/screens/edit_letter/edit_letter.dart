import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/edit_letter_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/constant/app_fonts.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/primary_button.dart';

class EditLetterScreen extends StatelessWidget {
  const EditLetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EditLetterController controller = Get.put(EditLetterController());

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
                // Top bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textHi,
                        size: 22.h,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: AppText(
                          'Edit Letter',
                          size: 15,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 22.h),
                  ],
                ),
                Gap.v(16),
                // Editable text area
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    cursorColor: AppColors.accent,
                    autofocus: true,
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
                Obx(() => PrimaryButton(
                      label: controller.isSaving.value ? 'Saving…' : 'Save Changes',
                      onTap: controller.isSaving.value ? () {} : controller.saveEdit,
                      width: double.infinity,
                    )),
                Gap.v(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
