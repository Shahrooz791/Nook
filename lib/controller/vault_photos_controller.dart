import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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

  // ── Decrypt for display (just-in-time, never written to disk) ─────────────

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

  Future<void> restoreSelected() async {
    final toRestoreIds = List<int>.from(selectedIds);
    for (final id in toRestoreIds) {
      final photo = photos.firstWhereOrNull((p) => p.id == id);
      if (photo == null) continue;
      
      final bytes = await VaultLocalData.instance.decryptPhoto(photo);
      
      // Determine restore directory
      final restoreDir = Directory('/storage/emulated/0/Download/NookRestored');
      if (!await restoreDir.exists()) {
        await restoreDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final restorePath = '${restoreDir.path}/restored_photo_$timestamp.jpg';
      await File(restorePath).writeAsBytes(bytes);

      // Now remove from vault
      await VaultLocalData.instance.deletePhoto(id);
    }
    selectedIds.clear();
    isMultiSelect.value = false;
    await loadPhotos();
  }
}
