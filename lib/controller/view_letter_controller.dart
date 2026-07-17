import 'package:get/get.dart';
import 'package:nook/local_data/letters_local_data.dart';
import 'package:nook/model/letter_model.dart';

/// All View-Letter logic lives here — the view stays pure UI.
/// Expects the letter's `id` to be passed as `Get.arguments`.
class ViewLetterController extends GetxController {
  final Rx<LetterModel?> letter = Rx<LetterModel?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as int?;
    if (id != null) {
      _loadLetter(id);
    } else {
      isLoading.value = false;
    }
  }

  Future<void> _loadLetter(int id) async {
    isLoading.value = true;
    letter.value = await LettersLocalData.instance.getLetterById(id);
    isLoading.value = false;
  }

  Future<void> deleteLetter() async {
    final current = letter.value;
    if (current?.id == null) return;
    await LettersLocalData.instance.deleteLetter(current!.id!);
    Get.back();
  }
}
