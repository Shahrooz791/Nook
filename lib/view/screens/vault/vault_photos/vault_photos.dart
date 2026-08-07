import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_photos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/primary_button.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';
import 'package:nook/view/screens/vault/vault_photos/components/vault_photo_grid.dart';

class VaultPhotosScreen extends StatelessWidget {
  const VaultPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultPhotosController controller = Get.put(VaultPhotosController());

    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top App Bar
              Obx(() {
                final isSelectMode = controller.isMultiSelect.value;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.v),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.vaultTextHi),
                        onPressed: () {
                          if (isSelectMode) {
                            controller.cancelMultiSelect();
                          } else {
                            Get.back();
                          }
                        },
                      ),
                      Gap.h(8),
                      Expanded(
                        child: AppText(
                          isSelectMode
                              ? '${controller.selectedIds.length} Selected'
                              : 'Photos',
                          size: 20,
                          weight: FontWeight.w600,
                          color: AppColors.vaultTextHi,
                        ),
                      ),
                      if (isSelectMode) ...[
                        IconButton(
                          icon: const Icon(Icons.restore, color: Colors.green),
                          onPressed: () {
                            Get.defaultDialog(
                              title: 'Restore Photos',
                              titleStyle: const TextStyle(color: AppColors.vaultTextHi),
                              middleText: 'Restore selected photos to Download/NookRestored?',
                              middleTextStyle: const TextStyle(color: AppColors.vaultTextLo),
                              backgroundColor: AppColors.vaultBgB,
                              textConfirm: 'Restore',
                              confirmTextColor: AppColors.vaultTextHi,
                              buttonColor: Colors.green,
                              textCancel: 'Cancel',
                              cancelTextColor: AppColors.vaultTextLo,
                              onConfirm: () async {
                                Get.back();
                                await controller.restoreSelected();
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.vaultDanger),
                          onPressed: () {
                            showVaultDeleteDialog(
                              title: 'Delete Photos',
                              message: 'Delete selected photos permanently?',
                              onConfirm: () async {
                                await controller.deleteSelected();
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.vaultTextHi),
                          onPressed: () => controller.cancelMultiSelect(),
                        ),
                      ] else ...[
                        IconButton(
                          icon: const Icon(Icons.add_photo_alternate_outlined,
                              color: AppColors.vaultAccent),
                          onPressed: () => controller.importPhotos(),
                        ),
                      ]
                    ],
                  ),
                );
              }),

              // Content Area
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      if (controller.photos.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64.adaptSize,
                                  color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                                ),
                                Gap.v(16),
                                const AppText(
                                  'Your photos vault is empty',
                                  size: 16,
                                  color: AppColors.vaultTextLo,
                                  weight: FontWeight.w500,
                                ),
                                Gap.v(24),
                                PrimaryButton(
                                  label: 'Add Photos',
                                  isVault: true,
                                  onTap: () => controller.importPhotos(),
                                  width: 180.h,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const VaultPhotoGrid();
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
}
