import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_photos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/model/vault_models.dart';
import 'package:nook/view/widgets/app_text.dart';

class VaultPhotoViewer extends StatelessWidget {
  final VaultPhoto photo;

  const VaultPhotoViewer({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final VaultPhotosController controller = Get.find<VaultPhotosController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.vaultTextHi),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.vaultDanger),
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Photo',
                titleStyle: const TextStyle(color: AppColors.vaultTextHi),
                middleText: 'Are you sure you want to delete this photo permanently?',
                middleTextStyle: const TextStyle(color: AppColors.vaultTextLo),
                backgroundColor: AppColors.vaultBgB,
                textConfirm: 'Delete',
                confirmTextColor: AppColors.vaultTextHi,
                buttonColor: AppColors.vaultDanger,
                textCancel: 'Cancel',
                cancelTextColor: AppColors.vaultTextLo,
                onConfirm: () async {
                  Get.back(); // close dialog
                  controller.selectedIds.clear();
                  controller.selectedIds.add(photo.id!);
                  await controller.deleteSelected();
                  Get.back(); // close viewer
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: controller.decryptPhotoBytes(photo),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: AppColors.vaultAccent);
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const AppText(
                'Failed to load image',
                color: AppColors.vaultDanger,
              );
            }
            return InteractiveViewer(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
