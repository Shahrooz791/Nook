import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/local_data/letters_local_data.dart';
import 'package:nook/model/letter_model.dart';

/// All Edit-Letter logic lives here — the view stays pure UI.
/// Expects a [LetterModel] to be passed as `Get.arguments`.
class EditLetterController extends GetxController {
  late final TextEditingController textController;
  late final LetterModel original;

  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    original = Get.arguments as LetterModel;
    textController = TextEditingController(text: original.content);
  }

  Future<void> saveEdit() async {
    final content = textController.text.trim();
    if (content.isEmpty || content == original.content) {
      Get.back();
      return;
    }
    isSaving.value = true;
    final updated = LetterModel(
      id: original.id,
      content: content,
      createdAt: original.createdAt,
      unlockAt: original.unlockAt,
    );
    await LettersLocalData.instance.updateLetter(updated);
    isSaving.value = false;
    Get.back();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
