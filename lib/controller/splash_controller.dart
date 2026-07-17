import 'package:get/get.dart';
import 'package:nook/core/utils/routes.dart';

/// All splash-screen logic lives here — the view stays pure UI.
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _goToHomeAfterDelay();
  }

  Future<void> _goToHomeAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    Get.offAllNamed(AppRoutes.home);
  }
}
