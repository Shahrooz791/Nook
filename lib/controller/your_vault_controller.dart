import 'package:get/get.dart';
import 'package:nook/core/utils/routes.dart';
import 'package:nook/local_data/vault_local_data.dart';

/// Drives the Your Vault dashboard.
/// Owns the category item counts.
class YourVaultController extends GetxController {
  // ── Counts ────────────────────────────────────────────────────────────────
  final RxInt photoCount = 0.obs;
  final RxInt videoCount = 0.obs;
  final RxInt fileCount = 0.obs;
  final RxInt noteCount = 0.obs;
  final RxInt passwordCount = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    final data = VaultLocalData.instance;
    final results = await Future.wait([
      data.countPhotos(),
      data.countVideos(),
      data.countFiles(),
      data.countNotes(),
      data.countPasswords(),
    ]);
    photoCount.value = results[0];
    videoCount.value = results[1];
    fileCount.value = results[2];
    noteCount.value = results[3];
    passwordCount.value = results[4];
    isLoading.value = false;
  }

  Future<void> refreshCounts() async {
    final data = VaultLocalData.instance;
    final results = await Future.wait([
      data.countPhotos(),
      data.countVideos(),
      data.countFiles(),
      data.countNotes(),
      data.countPasswords(),
    ]);
    photoCount.value = results[0];
    videoCount.value = results[1];
    fileCount.value = results[2];
    noteCount.value = results[3];
    passwordCount.value = results[4];
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void goPhotos() => Get.toNamed(AppRoutes.vaultPhotos)?.then((_) => refreshCounts());
  void goVideos() => Get.toNamed(AppRoutes.vaultVideos)?.then((_) => refreshCounts());
  void goFiles() => Get.toNamed(AppRoutes.vaultFiles)?.then((_) => refreshCounts());
  void goNotes() => Get.toNamed(AppRoutes.vaultNotes)?.then((_) => refreshCounts());
  void goPasswords() => Get.toNamed(AppRoutes.vaultPasswords)?.then((_) => refreshCounts());

  // ── Settings ──────────────────────────────────────────────────────────────
  void changePin() {
    Get.toNamed(AppRoutes.vaultLocked, arguments: {'isChangePin': true});
  }

  Future<void> wipeVaultData() async {
    await VaultLocalData.instance.wipeAll();
    Get.offAllNamed(AppRoutes.home);
  }
}
