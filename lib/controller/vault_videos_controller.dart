import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultVideosController extends GetxController {
  final RxList<VaultVideo> videos = <VaultVideo>[].obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxBool isMultiSelect = false.obs;
  final RxBool isImporting = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final result = await VaultLocalData.instance.getAllVideos();
    videos.assignAll(result);
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<void> importVideo() async {
    final source = await _showSourceDialog();
    if (source == null) return;

    Uint8List? videoBytes;
    int durationSeconds = 0;
    File? tempFile;

    if (source == 'gallery') {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      videoBytes = await picked.readAsBytes();
      tempFile = File(picked.path);
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: false,
      );
      if (result == null || result.files.single.path == null) return;
      tempFile = File(result.files.single.path!);
      videoBytes = await tempFile.readAsBytes();
    }

    // Extract duration via VideoPlayerController
    try {
      final vpc = VideoPlayerController.file(tempFile);
      await vpc.initialize();
      durationSeconds = vpc.value.duration.inSeconds;
      await vpc.dispose();
    } catch (_) {
      durationSeconds = 0;
    }

    isImporting.value = true;
    await VaultLocalData.instance.insertVideo(
      videoBytes,
      originalPath: tempFile.path,
      durationSeconds: durationSeconds,
    );

    await loadVideos();
    isImporting.value = false;
  }

  Future<String?> _showSourceDialog() async {
    return await Get.dialog<String>(
      _sourceDialog(),
      barrierDismissible: true,
    );
  }

  // ── Decrypt for playback ──────────────────────────────────────────────────

  /// Decrypts a video to a temporary file (must be cleaned up after playback).
  Future<File> decryptVideoToTemp(VaultVideo video) async {
    final bytes = await VaultLocalData.instance.decryptVideo(video);
    final tmpDir = await getTemporaryDirectory();
    final tmpFile = File('${tmpDir.path}/vault_tmp_${video.id}.mp4');
    await tmpFile.writeAsBytes(bytes);
    return tmpFile;
  }

  Future<void> cleanupTempFile(File file) async {
    if (await file.exists()) await file.delete();
  }

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
    for (final id in List<int>.from(selectedIds)) {
      await VaultLocalData.instance.deleteVideo(id);
    }
    selectedIds.clear();
    isMultiSelect.value = false;
    await loadVideos();
  }

  Future<void> restoreSelected() async {
    final toRestoreIds = List<int>.from(selectedIds);
    for (final id in toRestoreIds) {
      final video = videos.firstWhereOrNull((v) => v.id == id);
      if (video == null) continue;
      
      final bytes = await VaultLocalData.instance.decryptVideo(video);
      
      final restoreDir = Directory('/storage/emulated/0/Download/NookRestored');
      if (!await restoreDir.exists()) {
        await restoreDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final restorePath = '${restoreDir.path}/restored_video_$timestamp.mp4';
      await File(restorePath).writeAsBytes(bytes);

      await VaultLocalData.instance.deleteVideo(id);
    }
    selectedIds.clear();
    isMultiSelect.value = false;
    await loadVideos();
  }
}

// Small helper widget (not a screen — just a dialog)

Widget _sourceDialog() => AlertDialog(
      backgroundColor: AppColors.vaultBgB,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const AppText('Add Video', size: 16, weight: FontWeight.w600,
          color: AppColors.vaultTextHi),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dialogOption(Icons.photo_library_outlined, 'Gallery', 'gallery'),
          const SizedBox(height: 8),
          _dialogOption(Icons.folder_outlined, 'Files', 'files'),
        ],
      ),
    );

Widget _dialogOption(IconData icon, String label, String value) =>
    ListTile(
      leading: Icon(icon, color: AppColors.vaultAccent),
      title: AppText(label, color: AppColors.vaultTextHi),
      onTap: () => Get.back(result: value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.vaultGlassFill,
    );
