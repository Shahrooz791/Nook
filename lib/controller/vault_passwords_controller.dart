import 'dart:math';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

/// Decrypted password entry — lives only in memory, never persisted plain.
class DecryptedPassword {
  final VaultPassword raw;
  final String username;
  final String password;
  final String notes;
  bool isRevealed;

  DecryptedPassword({
    required this.raw,
    required this.username,
    required this.password,
    required this.notes,
    this.isRevealed = false,
  });
}

class VaultPasswordsController extends GetxController {
  final RxList<DecryptedPassword> passwords = <DecryptedPassword>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPasswords();
  }

  Future<void> loadPasswords() async {
    isLoading.value = true;
    final raw = await VaultLocalData.instance.getAllPasswords();
    final decrypted = await Future.wait(
      raw.map((vp) async {
        final username = await VaultLocalData.instance.decryptUsername(vp);
        final password = await VaultLocalData.instance.decryptPassword(vp);
        final notes = await VaultLocalData.instance.decryptNotes(vp);
        return DecryptedPassword(
          raw: vp,
          username: username,
          password: password,
          notes: notes,
        );
      }),
    );
    passwords.assignAll(decrypted);
    isLoading.value = false;
  }

  Future<void> savePassword({
    int? id,
    required String title,
    required String username,
    required String password,
    String notes = '',
  }) async {
    if (id == null) {
      await VaultLocalData.instance.insertPassword(
        title: title,
        username: username,
        password: password,
        notes: notes,
      );
    } else {
      await VaultLocalData.instance.updatePassword(
        id: id,
        title: title,
        username: username,
        password: password,
        notes: notes,
      );
    }
    await loadPasswords();
  }

  Future<void> deletePassword(int id) async {
    await VaultLocalData.instance.deletePassword(id);
    await loadPasswords();
  }

  // ── Reveal toggle ─────────────────────────────────────────────────────────

  void toggleReveal(int index) {
    passwords[index].isRevealed = !passwords[index].isRevealed;
    passwords.refresh(); // notify observers
  }

  // ── Clipboard ─────────────────────────────────────────────────────────────

  Future<void> copyPassword(int index) async {
    await Clipboard.setData(ClipboardData(text: passwords[index].password));
    Get.snackbar(
      'Copied',
      'Password copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> copyUsername(int index) async {
    await Clipboard.setData(ClipboardData(text: passwords[index].username));
    Get.snackbar(
      'Copied',
      'Username copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ── Password generator ────────────────────────────────────────────────────

  String generatePassword({int length = 16}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
