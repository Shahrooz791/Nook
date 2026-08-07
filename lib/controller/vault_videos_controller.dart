import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultVideosController extends GetxController {
  final RxList<VaultVideo> videos = <VaultVideo>[].obs;
  final RxSet<int> selectedIds = <int>{}.obs;
  final RxBool isMultiSelect = false.obs;
  final RxBool isImporting = false.obs;

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
    String? assetId;
    AssetEntity? pickedAsset;

    if (source == 'gallery') {
      final List<AssetEntity>? picked = await AssetPicker.pickAssets(
        Get.context!,
        pickerConfig: AssetPickerConfig(
          maxAssets: 1,
          requestType: RequestType.video,
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
      pickedAsset = picked.first;
      videoBytes = await pickedAsset.originBytes;
      if (videoBytes == null) return;
      tempFile = await pickedAsset.file;
      durationSeconds = pickedAsset.duration;
      assetId = pickedAsset.id;
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: false,
      );
      if (result == null || result.files.single.path == null) return;
      tempFile = File(result.files.single.path!);
      videoBytes = await tempFile.readAsBytes();

      // Extract duration via VideoPlayerController
      try {
        final vpc = VideoPlayerController.file(tempFile);
        await vpc.initialize();
        durationSeconds = vpc.value.duration.inSeconds;
        await vpc.dispose();
      } catch (_) {
        durationSeconds = 0;
      }
    }

    Uint8List? thumbBytes;
    // 1. Primary path — native AssetEntity thumbnail (gallery pick)
    if (pickedAsset != null) {
      try {
        thumbBytes = await pickedAsset.thumbnailDataWithSize(
          const ThumbnailSize(320, 320),
        );
        if (thumbBytes != null && thumbBytes.isNotEmpty) {
          debugPrint('[Nook][vault] AssetEntity native thumbnail extracted: ${thumbBytes.length} bytes');
        }
      } catch (e) {
        debugPrint('[Nook][vault] AssetEntity thumbnail failed: $e');
      }
    }

    // 2. Fallback path — VideoThumbnail plugin (file picker / AssetEntity fallback)
    if (thumbBytes == null && tempFile != null && await tempFile.exists()) {
      try {
        thumbBytes = await VideoThumbnail.thumbnailData(
          video: tempFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 320,
          quality: 70,
        );
        if (thumbBytes != null && thumbBytes.isNotEmpty) {
          debugPrint('[Nook][vault] VideoThumbnail plugin fallback extracted: ${thumbBytes.length} bytes');
        }
      } catch (e) {
        debugPrint('[Nook][vault] video_thumbnail fallback failed: $e');
      }
    }

    if (thumbBytes == null || thumbBytes.isEmpty) {
      debugPrint('[Nook][vault] no thumbnail available for this video — using fallback icon');
    }

    isImporting.value = true;
    await VaultLocalData.instance.insertVideo(
      videoBytes,
      originalPath: tempFile?.path,
      durationSeconds: durationSeconds,
      assetId: assetId,
      thumbBytes: thumbBytes,
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

  // ── Decrypt for playback & display ────────────────────────────────────────

  Future<Uint8List?> decryptVideoThumb(VaultVideo video) {
    return VaultLocalData.instance.decryptVideoThumb(video);
  }

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

  Future<bool> restoreVideo(VaultVideo video) async {
    try {
      final bytes = await VaultLocalData.instance.decryptVideo(video);
      final filename = 'restored_video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final tmpDir = await getTemporaryDirectory();
      final tmpFile = File('${tmpDir.path}/$filename');
      await tmpFile.writeAsBytes(bytes);

      AssetEntity? savedAsset;
      try {
        savedAsset = await PhotoManager.editor.saveVideo(
          tmpFile,
          title: filename,
          relativePath: 'Movies/NookRestored',
        );
      } catch (e) {
        debugPrint('[Nook][vault] PhotoManager saveVideo error: $e');
      } finally {
        if (await tmpFile.exists()) await tmpFile.delete();
      }

      if (savedAsset != null) {
        await VaultLocalData.instance.deleteVideo(video.id!);
        await loadVideos();
        Get.snackbar(
          'Restored',
          'Video saved to Gallery (Movies/NookRestored)',
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
          await VaultLocalData.instance.deleteVideo(video.id!);
          await loadVideos();
          Get.snackbar(
            'Restored',
            'Video saved to Downloads/NookRestored',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.vaultGlassFillStrong,
            colorText: AppColors.vaultTextHi,
          );
          return true;
        }
      }

      Get.snackbar(
        'Error',
        'Could not restore video — please try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.vaultDanger.withValues(alpha: 0.8),
        colorText: AppColors.vaultTextHi,
      );
      return false;
    } catch (e) {
      debugPrint('[Nook][vault] restoreVideo error: $e');
      Get.snackbar(
        'Error',
        'Could not restore video — please try again',
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
      final video = videos.firstWhereOrNull((v) => v.id == id);
      if (video == null) continue;
      await restoreVideo(video);
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
