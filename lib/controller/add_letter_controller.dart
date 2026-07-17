import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/local_data/letters_local_data.dart';
import 'package:nook/model/letter_model.dart';

/// All Add-Letter logic lives here — the view stays pure UI.
class AddLetterController extends GetxController {
  final TextEditingController textController = TextEditingController();

  final RxBool hasUnlockTime = false.obs;
  final Rx<DateTime> unlockDate =
      DateTime.now().add(const Duration(days: 30)).obs;
  final RxBool isSealing = false.obs;

  void toggleUnlockTime(bool value) {
    hasUnlockTime.value = value;
  }

  Future<void> pickUnlockDate(BuildContext context) async {
    final now = DateTime.now();
    final firstSelectable = now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate:
          unlockDate.value.isAfter(firstSelectable) ? unlockDate.value : firstSelectable,
      firstDate: firstSelectable,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      unlockDate.value = picked;
    }
  }

  Future<void> saveLetter() async {
    final content = textController.text.trim();
    if (content.isEmpty) return;

    final now = DateTime.now();
    final unlockAt = hasUnlockTime.value ? unlockDate.value : now;

    if (hasUnlockTime.value) {
      isSealing.value = true;
      await Future.delayed(const Duration(milliseconds: 700));
    }

    await LettersLocalData.instance.insertLetter(
      LetterModel(content: content, createdAt: now, unlockAt: unlockAt),
    );

    isSealing.value = false;
    Get.back();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
