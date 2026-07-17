import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nook/controller/vault_files_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/local_data/vault_local_data.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/widgets/primary_button.dart';

class VaultFilesScreen extends StatelessWidget {
  const VaultFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultFilesController controller = Get.put(VaultFilesController());

    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.v),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.vaultTextHi),
                      onPressed: () => Get.back(),
                    ),
                    Gap.h(8),
                    const Expanded(
                      child: AppText(
                        'Files & Documents',
                        size: 20,
                        weight: FontWeight.w600,
                        color: AppColors.vaultTextHi,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.vaultAccent),
                      onPressed: () => controller.importFile(),
                    ),
                  ],
                ),
              ),

              // File List Area
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.files.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_outlined,
                                  size: 64.adaptSize,
                                  color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                                ),
                                Gap.v(16),
                                const AppText(
                                  'Your files vault is empty',
                                  size: 16,
                                  color: AppColors.vaultTextLo,
                                  weight: FontWeight.w500,
                                ),
                                Gap.v(24),
                                PrimaryButton(
                                  label: 'Add File',
                                  isVault: true,
                                  onTap: () => controller.importFile(),
                                  width: 180.h,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.v),
                        itemCount: controller.files.length,
                        itemBuilder: (context, index) {
                          final file = controller.files[index];
                          return _buildFileItem(context, file, controller);
                        },
                      );
                    }),

                    // Loading overlay for import
                    Obx(() {
                      if (controller.isImporting.value) {
                        return Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: AppColors.vaultAccent),
                                SizedBox(height: 16),
                                AppText(
                                  'Encrypting and importing...',
                                  color: AppColors.vaultTextHi,
                                  weight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, VaultFile file, VaultFilesController controller) {
    final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(file.addedAt));
    final icon = _getFileIcon(file.extension);

    return Dismissible(
      key: Key(file.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.h),
        decoration: BoxDecoration(
          color: AppColors.vaultDanger,
          borderRadius: 18.r,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await Get.defaultDialog<bool>(
          title: 'Delete File',
          titleStyle: const TextStyle(color: AppColors.vaultTextHi),
          middleText: 'Are you sure you want to delete "${file.originalName}"?',
          middleTextStyle: const TextStyle(color: AppColors.vaultTextLo),
          backgroundColor: AppColors.vaultBgB,
          textConfirm: 'Delete',
          confirmTextColor: AppColors.vaultTextHi,
          buttonColor: AppColors.vaultDanger,
          textCancel: 'Cancel',
          cancelTextColor: AppColors.vaultTextLo,
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        );
      },
      onDismissed: (direction) {
        controller.deleteFile(file.id!);
      },
      child: GestureDetector(
        onTap: () => _previewFile(context, file, controller),
        child: GlassContainer(
          isVault: true,
          margin: EdgeInsets.only(bottom: 12.v),
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.v),
          child: Row(
            children: [
              Container(
                width: 48.adaptSize,
                height: 48.adaptSize,
                decoration: BoxDecoration(
                  color: AppColors.vaultGlassFillStrong,
                  borderRadius: 12.r,
                ),
                child: Icon(icon, color: AppColors.vaultAccent),
              ),
              Gap.h(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      file.originalName,
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.vaultTextHi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.v(4),
                    AppText(
                      '$dateStr • ${file.fileSizeDisplay}',
                      size: 12,
                      color: AppColors.vaultTextLo,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.vaultTextLo.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext) {
      case 'PDF':
        return Icons.picture_as_pdf_outlined;
      case 'JPG':
      case 'JPEG':
      case 'PNG':
      case 'WEBP':
      case 'GIF':
        return Icons.image_outlined;
      case 'MP4':
      case 'MOV':
      case 'MKV':
      case 'AVI':
        return Icons.movie_creation_outlined;
      case 'TXT':
      case 'DOC':
      case 'DOCX':
        return Icons.article_outlined;
      case 'ZIP':
      case 'RAR':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  void _previewFile(BuildContext context, VaultFile file, VaultFilesController controller) async {
    final ext = file.extension;
    if (ext == 'TXT') {
      try {
        final data = await VaultLocalData.instance.decryptFile(file);
        final text = utf8.decode(data);
        _showTextPreview(file, text, controller);
      } catch (e) {
        _showFileInfo(file, controller);
      }
    } else {
      _showFileInfo(file, controller);
    }
  }

  void _showTextPreview(VaultFile file, String text, VaultFilesController controller) {
    Get.bottomSheet(
      GlassContainer(
        isVault: true,
        radius: 24,
        padding: EdgeInsets.all(24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    file.originalName,
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.vaultTextHi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.vaultTextLo),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Gap.v(16),
            Expanded(
              child: SingleChildScrollView(
                child: AppText(
                  text,
                  size: 14,
                  color: AppColors.vaultTextHi,
                  height: 1.5,
                ),
              ),
            ),
            Gap.v(16),
            PrimaryButton(
              label: 'Restore File',
              isVault: true,
              onTap: () async {
                Get.back();
                await controller.restoreFile(file);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _showFileInfo(VaultFile file, VaultFilesController controller) {
    final dateStr = DateFormat('MMMM dd, yyyy - HH:mm').format(DateTime.parse(file.addedAt));
    Get.bottomSheet(
      GlassContainer(
        isVault: true,
        radius: 24,
        padding: EdgeInsets.all(24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Secure File Info',
                  size: 18,
                  weight: FontWeight.w600,
                  color: AppColors.vaultTextHi,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.vaultTextLo),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            Gap.v(16),
            _buildInfoRow('File Name', file.originalName),
            _buildInfoRow('Size', file.fileSizeDisplay),
            _buildInfoRow('Date Added', dateStr),
            _buildInfoRow('Encryption', 'AES-256 (CBC) Encrypted at Rest'),
            Gap.v(24),
            const AppText(
              'For security, raw previews are disabled for this file type to prevent temporary directory leaks. The file is kept fully encrypted.',
              size: 12,
              color: AppColors.vaultTextLo,
              align: TextAlign.center,
            ),
            Gap.v(16),
            PrimaryButton(
              label: 'Restore File',
              isVault: true,
              onTap: () async {
                Get.back();
                await controller.restoreFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.v),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, color: AppColors.vaultTextLo, size: 13),
          Expanded(
            child: AppText(
              value,
              color: AppColors.vaultTextHi,
              size: 13,
              weight: FontWeight.w500,
              align: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
