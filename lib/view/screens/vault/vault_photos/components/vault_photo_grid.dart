import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_photos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/screens/vault/vault_photos/components/vault_photo_viewer.dart';

class VaultPhotoGrid extends StatelessWidget {
  const VaultPhotoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultPhotosController controller = Get.find<VaultPhotosController>();

    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.all(16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.h,
          mainAxisSpacing: 10.v,
          childAspectRatio: 1,
        ),
        itemCount: controller.photos.length,
        itemBuilder: (context, index) {
          final photo = controller.photos[index];
          final isSelected = controller.selectedIds.contains(photo.id);

          return GestureDetector(
            onTap: () {
              if (controller.isMultiSelect.value) {
                controller.toggleMultiSelect(photo.id!);
              } else {
                Get.to(() => VaultPhotoViewer(photo: photo));
              }
            },
            onLongPress: () {
              controller.toggleMultiSelect(photo.id!);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: 12.r,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.vaultAccent
                            : AppColors.vaultGlassBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FutureBuilder<Uint8List>(
                      future: controller.decryptPhotoBytes(photo),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            color: AppColors.vaultGlassFill,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.vaultAccent,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            color: AppColors.vaultGlassFill,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.vaultDanger,
                            ),
                          );
                        }
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                if (controller.isMultiSelect.value)
                  Positioned(
                    top: 8.v,
                    right: 8.h,
                    child: Container(
                      padding: EdgeInsets.all(2.adaptSize),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.vaultAccent
                            : Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14.adaptSize,
                        color: isSelected ? Colors.black : Colors.transparent,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
