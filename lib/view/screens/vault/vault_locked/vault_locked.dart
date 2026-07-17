import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_lock_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/primary_button.dart';
import 'package:nook/view/widgets/vault_keypad.dart';

class VaultLockedScreen extends StatelessWidget {
  const VaultLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultLockController controller = Get.put(VaultLockController());

    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
        child: SafeArea(
          child: Obx(() {
            final currentMode = controller.mode.value;

            // First time setup layout - showing onboarding message first
            if (controller.showOnboarding.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(32.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.h),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.vaultGlassFillStrong,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 64.adaptSize,
                          color: AppColors.vaultAccent,
                        ),
                      ),
                      Gap.v(24),
                      const AppText(
                        'Set up a lock to protect your vault',
                        size: 20,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                        color: AppColors.vaultTextHi,
                      ),
                      Gap.v(12),
                      const AppText(
                        'Create a secure 4-digit PIN to encrypt your private photos, videos, passwords and notes.',
                        size: 14,
                        align: TextAlign.center,
                        color: AppColors.vaultTextLo,
                        height: 1.5,
                      ),
                      Gap.v(40),
                      PrimaryButton(
                        label: 'Set Up Lock',
                        isVault: true,
                        onTap: () {
                          controller.startSetup();
                        },
                        width: 200.h,
                      ),
                    ],
                  ),
                ),
              );
            }

            // PIN Entry UI (Setup or Unlock)
            String headerText = 'Enter PIN';
            String subtextText = 'Enter your PIN to continue';
            if (currentMode == VaultLockMode.firstSetup) {
              headerText = 'Create PIN';
              subtextText = 'Choose a secure 4-digit PIN';
            } else if (currentMode == VaultLockMode.confirmSetup) {
              headerText = 'Confirm PIN';
              subtextText = 'Re-enter your PIN to confirm';
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap.v(24),
                  // Lock Icon
                Container(
                  padding: EdgeInsets.all(20.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.vaultGlassFillStrong,
                  ),
                  child: Icon(
                    controller.isError.value ? Icons.lock_outline : Icons.lock,
                    size: 40.adaptSize,
                    color: controller.isError.value
                        ? AppColors.vaultDanger
                        : AppColors.vaultAccent,
                  ),
                ),
                Gap.v(24),

                // Text Headers
                AppText(
                  headerText,
                  size: 24,
                  weight: FontWeight.w700,
                  color: AppColors.vaultTextHi,
                ),
                Gap.v(8),
                AppText(
                  subtextText,
                  size: 14,
                  color: AppColors.vaultTextLo,
                ),
                Gap.v(32),

                // PIN dot indicators
                Obx(() {
                  final enteredLen = controller.enteredPin.value.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < enteredLen;
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.h),
                        width: 16.adaptSize,
                        height: 16.adaptSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.isError.value
                              ? AppColors.vaultDanger
                              : isFilled
                                  ? AppColors.vaultAccent
                                  : Colors.transparent,
                          border: Border.all(
                            color: controller.isError.value
                                ? AppColors.vaultDanger
                                : isFilled
                                    ? AppColors.vaultAccent
                                    : AppColors.vaultGlassBorder,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  )
                  .animate(key: ValueKey(controller.shakeKey.value))
                  .shake(duration: 400.ms, hz: 8, curve: Curves.easeInOut);
                }),
                Gap.v(48),

                // Keypad
                VaultKeypad(
                  onDigitPressed: controller.onDigitPressed,
                  onBackspace: controller.onBackspace,
                ),
              ],
            ),
          );
        }),
        ),
      ),
    );
  }
}
