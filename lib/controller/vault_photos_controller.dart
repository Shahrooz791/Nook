import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';

class VaultPhotosController extends GetxController {
  final RxList<VaultPhoto> photos = <VaultPhoto>[].obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxBool isMultiSelect = false.obs;
  final RxBool isImporting = false.obs;

  final _picker = ImagePicker();

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
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;
    isImporting.value = true;
    for (final xf in picked) {
      final bytes = await xf.readAsBytes();
      await VaultLocalData.instance.insertPhoto(bytes, originalPath: xf.path);
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
