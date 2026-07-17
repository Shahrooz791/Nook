import 'package:get/get.dart';
import 'package:nook/core/utils/routes.dart';
import 'package:nook/local_data/vault_encryption.dart';
import 'package:nook/local_data/vault_local_data.dart';

enum VaultLockMode { checkingPin, firstSetup, confirmSetup, unlock }

/// Drives the Vault Locked screen.
/// Handles both first-time PIN setup (enter → confirm → save → enter vault)
/// and normal unlock (enter PIN → verify → enter vault).
class VaultLockController extends GetxController {
  final Rx<VaultLockMode> mode = VaultLockMode.checkingPin.obs;
  final RxString enteredPin = ''.obs;
  final RxBool isError = false.obs;
  final RxInt shakeKey = 0.obs; // increment to replay shake animation
  final RxBool showOnboarding = true.obs;

  /// Temporarily stores the first PIN during setup so it can be confirmed.
  String _pendingPin = '';

  @override
  void onInit() {
    super.onInit();
    _determineMode();
  }

  Future<void> _determineMode() async {
    final hasPin = await VaultLocalData.instance.hasPinSet();
    mode.value = hasPin ? VaultLockMode.unlock : VaultLockMode.firstSetup;
    showOnboarding.value = !hasPin;
  }

  void startSetup() {
    showOnboarding.value = false;
  }

  // ── Keypad input ──────────────────────────────────────────────────────────

  void onDigitPressed(String digit) {
    if (enteredPin.value.length >= 4) return;
    enteredPin.value += digit;
    if (enteredPin.value.length == 4) _onPinComplete();
  }

  void onBackspace() {
    if (enteredPin.value.isEmpty) return;
    enteredPin.value =
        enteredPin.value.substring(0, enteredPin.value.length - 1);
  }

  // ── Auto-submit when 4 digits filled ─────────────────────────────────────

  Future<void> _onPinComplete() async {
    await Future.delayed(const Duration(milliseconds: 120)); // brief visual pause
    switch (mode.value) {
      case VaultLockMode.firstSetup:
        _pendingPin = enteredPin.value;
        enteredPin.value = '';
        mode.value = VaultLockMode.confirmSetup;
      case VaultLockMode.confirmSetup:
        if (enteredPin.value == _pendingPin) {
          await VaultEncryption.instance.savePin(enteredPin.value);
          _enterVault();
        } else {
          _shakeError();
          mode.value = VaultLockMode.firstSetup;
          _pendingPin = '';
        }
      case VaultLockMode.unlock:
        final ok = await VaultEncryption.instance.verifyPin(enteredPin.value);
        if (ok) {
          _enterVault();
        } else {
          _shakeError();
        }
      case VaultLockMode.checkingPin:
        break;
    }
  }

  void _shakeError() {
    isError.value = true;
    shakeKey.value++;
    enteredPin.value = '';
    Future.delayed(const Duration(milliseconds: 700), () {
      isError.value = false;
    });
  }

  void _enterVault() {
    enteredPin.value = '';
    Get.offNamed(AppRoutes.yourVault);
  }
}
