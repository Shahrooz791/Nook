import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

class VaultFilesController extends GetxController {
  final RxList<VaultFile> files = <VaultFile>[].obs;
  final RxBool isImporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final result = await VaultLocalData.instance.getAllFiles();
    files.assignAll(result);
  }

  Future<void> importFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.single.bytes == null) return;
    final pf = result.files.single;
    isImporting.value = true;
    await VaultLocalData.instance.insertFile(
      pf.bytes!,
      originalName: pf.name,
      originalPath: pf.path,
    );

    await loadFiles();
    isImporting.value = false;
  }

  Future<void> deleteFile(int id) async {
    await VaultLocalData.instance.deleteFile(id);
    await loadFiles();
  }

  Future<bool> restoreFile(VaultFile file) async {
    try {
      final bytes = await VaultLocalData.instance.decryptFile(file);
      Directory restoreDir;
      if (Platform.isAndroid) {
        restoreDir = Directory('/storage/emulated/0/Download/NookRestored');
      } else {
        final docs = await getApplicationDocumentsDirectory();
        restoreDir = Directory('${docs.path}/NookRestored');
      }
      if (!await restoreDir.exists()) {
        await restoreDir.create(recursive: true);
      }

      final restorePath = '${restoreDir.path}/${file.originalName}';
      final targetFile = File(restorePath);
      await targetFile.writeAsBytes(bytes);

      final exists = await targetFile.exists();
      final length = exists ? await targetFile.length() : 0;
      if (exists && length > 0) {
        if (Platform.isAndroid) {
          try {
            await const MethodChannel('nook/media_scanner').invokeMethod('scanFile', {'path': restorePath});
          } catch (e) {
            debugPrint('[Nook][vault] MediaScanner error: $e');
          }
        }

        await VaultLocalData.instance.deleteFile(file.id!);
        await loadFiles();
        Get.snackbar(
          'Restored',
          'File saved to Downloads/NookRestored',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.vaultGlassFillStrong,
          colorText: AppColors.vaultTextHi,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Could not restore file — please try again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.vaultDanger.withValues(alpha: 0.8),
          colorText: AppColors.vaultTextHi,
        );
        return false;
      }
    } catch (e) {
      debugPrint('[Nook][vault] restoreFile error: $e');
      Get.snackbar(
        'Error',
        'Could not restore file — please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.vaultDanger.withValues(alpha: 0.8),
        colorText: AppColors.vaultTextHi,
      );
      return false;
    }
  }
}
