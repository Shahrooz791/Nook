import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_videos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/primary_button.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';
import 'package:nook/view/screens/vault/vault_videos/components/vault_video_grid.dart';

class VaultVideosScreen extends StatelessWidget {
  const VaultVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultVideosController controller = Get.put(VaultVideosController());

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
                              : 'Videos',
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
                              title: 'Restore Videos',
                              titleStyle: const TextStyle(color: AppColors.vaultTextHi),
                              middleText: 'Restore selected videos to Download/NookRestored?',
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
                              title: 'Delete Videos',
                              message: 'Delete selected videos permanently?',
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
                          icon: const Icon(Icons.add_to_photos_outlined,
                              color: AppColors.vaultAccent),
                          onPressed: () => controller.importVideo(),
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
                      if (controller.videos.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 64.adaptSize,
                                  color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                                ),
                                Gap.v(16),
                                const AppText(
                                  'Your videos vault is empty',
                                  size: 16,
                                  color: AppColors.vaultTextLo,
                                  weight: FontWeight.w500,
                                ),
                                Gap.v(24),
                                PrimaryButton(
                                  label: 'Add Video',
                                  isVault: true,
                                  onTap: () => controller.importVideo(),
                                  width: 180.h,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const VaultVideoGrid();
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
