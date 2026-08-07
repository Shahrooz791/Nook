import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

class VaultPhotosController extends GetxController {
  final RxList<VaultPhoto> photos = <VaultPhoto>[].obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxBool isMultiSelect = false.obs;
  final RxBool isImporting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    final result = await VaultLocalData.instance.getAllPhotos();
    photos.assignAll(result);
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<void> importPhotos() async {
    final List<AssetEntity>? picked = await AssetPicker.pickAssets(
      Get.context!,
      pickerConfig: AssetPickerConfig(
        maxAssets: 80,
        requestType: RequestType.image,
        pickerTheme: AssetPicker.themeData(AppColors.vaultAccent).copyWith(
          scaffoldBackgroundColor: AppColors.vaultBgA,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.vaultBgB,
            elevation: 0,
          ),
        ),
      ),
    );
    if (picked == null || picked.isEmpty) return;
    isImporting.value = true;
    for (final asset in picked) {
      final bytes = await asset.originBytes;
      if (bytes == null) continue;
      final file = await asset.file;
      await VaultLocalData.instance.insertPhoto(
        bytes,
        originalPath: file?.path,
        assetId: asset.id,
      );
    }
    await loadPhotos();
    isImporting.value = false;
  }

  // ── Decrypt for display ───────────────────────────────────────────────────

  Future<Uint8List> decryptPhotoBytes(VaultPhoto photo) =>
      VaultLocalData.instance.decryptPhoto(photo);

  // ── Multi-select & delete ─────────────────────────────────────────────────

  void toggleMultiSelect(int id) {
    isMultiSelect.value = true;
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) isMultiSelect.value = false;
    } else {
      selectedIds.add(id);
    }
  }

  void cancelMultiSelect() {
    selectedIds.clear();
    isMultiSelect.value = false;
  }

  Future<void> deleteSelected() async {
    final toDelete = List<int>.from(selectedIds);
    for (final id in toDelete) {
      await VaultLocalData.instance.deletePhoto(id);
    }
    selectedIds.clear();
    isMultiSelect.value = false;
    await loadPhotos();
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<bool> restorePhoto(VaultPhoto photo) async {
    try {
      final bytes = await VaultLocalData.instance.decryptPhoto(photo);
      final filename = 'restored_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      AssetEntity? savedAsset;
      try {
        savedAsset = await PhotoManager.editor.saveImage(
          bytes,
          title: filename,
          filename: filename,
          relativePath: 'Pictures/NookRestored',
        );
      } catch (e) {
        debugPrint('[Nook][vault] PhotoManager saveImage error: $e');
      }

      if (savedAsset != null) {
        await VaultLocalData.instance.deletePhoto(photo.id!);
        await loadPhotos();
        Get.snackbar(
          'Restored',
          'Photo saved to Gallery (Pictures/NookRestored)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.vaultGlassFillStrong,
          colorText: AppColors.vaultTextHi,
        );
        return true;
      }

      // Fallback: direct file write + MediaScanner scan
      if (Platform.isAndroid) {
        final restoreDir = Directory('/storage/emulated/0/Download/NookRestored');
        if (!await restoreDir.exists()) {
          await restoreDir.create(recursive: true);
        }
        final targetFile = File('${restoreDir.path}/$filename');
        await targetFile.writeAsBytes(bytes);
        if (await targetFile.exists() && await targetFile.length() > 0) {
          try {
            await const MethodChannel('nook/media_scanner').invokeMethod('scanFile', {'path': targetFile.path});
          } catch (_) {}
          await VaultLocalData.instance.deletePhoto(photo.id!);
          await loadPhotos();
          Get.snackbar(
            'Restored',
            'Photo saved to Downloads/NookRestored',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.vaultGlassFillStrong,
            colorText: AppColors.vaultTextHi,
          );
          return true;
        }
      }

      Get.snackbar(
        'Error',
        'Could not restore photo — please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.vaultDanger.withValues(alpha: 0.8),
        colorText: AppColors.vaultTextHi,
      );
      return false;
    } catch (e) {
      debugPrint('[Nook][vault] restorePhoto error: $e');
      Get.snackbar(
        'Error',
        'Could not restore photo — please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.vaultDanger.withValues(alpha: 0.8),
        colorText: AppColors.vaultTextHi,
      );
      return false;
    }
  }

  Future<void> restoreSelected() async {
    final toRestoreIds = List<int>.from(selectedIds);
    for (final id in toRestoreIds) {
      final photo = photos.firstWhereOrNull((p) => p.id == id);
      if (photo == null) continue;
      await restorePhoto(photo);
    }
    selectedIds.clear();
    isMultiSelect.value = false;
    await loadPhotos();
  }
}
