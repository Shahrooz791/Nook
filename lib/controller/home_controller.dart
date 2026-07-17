import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/routes.dart';
import 'package:nook/local_data/letters_local_data.dart';
import 'package:nook/model/letter_model.dart';

/// All Home-screen logic lives here — the view stays pure UI.
class HomeController extends GetxController {
  final RxList<LetterModel> letters = <LetterModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadLetters();
  }

  Future<void> loadLetters() async {
    isLoading.value = true;
    final result = await LettersLocalData.instance.getAllLetters();
    letters.assignAll(result);
    isLoading.value = false;
  }

  /// Locked letters only show their countdown, never navigate.
  /// Unlocked letters open View Letter.
  void handleLetterTap(LetterModel letter) {
    if (letter.isUnlocked) {
      Get.toNamed(AppRoutes.viewLetter, arguments: letter.id)
          ?.then((_) => loadLetters());
      return;
    }
    Get.snackbar(
      'Still sealed',
      'Unlocks in ${letter.countdownText}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.glassFillStrong,
      colorText: AppColors.textHi,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  void openAddLetter() {
    Get.toNamed(AppRoutes.addLetter)?.then((_) => loadLetters());
  }

  void openVault() {
    Get.toNamed(AppRoutes.vaultLocked);
  }
}
