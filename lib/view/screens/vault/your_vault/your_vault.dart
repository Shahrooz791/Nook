import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/your_vault_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';
import 'package:nook/view/screens/vault/your_vault/components/vault_category_card.dart';

class YourVaultScreen extends StatelessWidget {
  const YourVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final YourVaultController controller = Get.put(YourVaultController());

    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.vaultAccent),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 16.v),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.v),
                    child: const AppText(
                      'Your Vault',
                      size: 28,
                      weight: FontWeight.w700,
                      color: AppColors.vaultTextHi,
                    ),
                  ),

                  // Categories Grid (Photos, Videos, Files, Notes)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16.h,
                    mainAxisSpacing: 16.v,
                    childAspectRatio: 1.1,
                    children: [
                      VaultCategoryCard(
                        icon: const Icon(Icons.image, color: Colors.blue),
                        title: 'Photos',
                        subtitle: '${controller.photoCount.value} items',
                        onTap: controller.goPhotos,
                      ),
                      VaultCategoryCard(
                        icon: const Icon(Icons.movie, color: Colors.purple),
                        title: 'Videos',
                        subtitle: '${controller.videoCount.value} items',
                        onTap: controller.goVideos,
                      ),
                      VaultCategoryCard(
                        icon: const Icon(Icons.description, color: Colors.teal),
                        title: 'Files/Docs',
                        subtitle: '${controller.fileCount.value} items',
                        onTap: controller.goFiles,
                      ),
                      VaultCategoryCard(
                        icon: const Icon(Icons.edit_note, color: Colors.amber),
                        title: 'Notes',
                        subtitle: '${controller.noteCount.value} items',
                        onTap: controller.goNotes,
                      ),
                    ],
                  ),
                  Gap.v(16),

                  // Passwords Card (Full Width)
                  GestureDetector(
                    onTap: controller.goPasswords,
                    child: GlassContainer(
                      isVault: true,
                      padding: EdgeInsets.all(20.h),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.h),
                              decoration: BoxDecoration(
                                color: AppColors.vaultGlassFillStrong,
                                borderRadius: 14.r,
                              ),
                            child: const Icon(Icons.key, color: Colors.orange),
                          ),
                          Gap.h(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText(
                                  'Passwords',
                                  size: 18,
                                  weight: FontWeight.w600,
                                  color: AppColors.vaultTextHi,
                                ),
                                Gap.v(4),
                                AppText(
                                  '${controller.passwordCount.value} saved logins',
                                  size: 13,
                                  color: AppColors.vaultTextLo,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.vaultTextLo,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap.v(40),

                  // Settings Actions
                  const AppText('SETTINGS', size: 12, weight: FontWeight.w600, color: AppColors.vaultTextLo, letterSpacing: 1.2),
                  Gap.v(16),
                  
                  // Change PIN
                  GestureDetector(
                    onTap: controller.changePin,
                    child: GlassContainer(
                      isVault: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
                      child: Row(
                        children: [
                          const Icon(Icons.password, color: AppColors.vaultTextHi),
                          Gap.h(12),
                          const Expanded(
                            child: AppText(
                              'Change PIN',
                              size: 14,
                              weight: FontWeight.w500,
                              color: AppColors.vaultTextHi,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.vaultTextLo, size: 16),
                        ],
                      ),
                    ),
                  ),
                  Gap.v(12),
                  
                  // Wipe Vault
                  GestureDetector(
                    onTap: () {
                      showVaultDeleteDialog(
                        title: 'Wipe Vault?',
                        message: 'This will permanently delete all encrypted photos, videos, files, notes, and passwords. This cannot be undone.',
                        onConfirm: () {
                          showVaultDeleteDialog(
                            title: 'Are you absolutely sure?',
                            message: 'There is no recovery after this point.',
                            onConfirm: () {
                              controller.wipeVaultData();
                            },
                          );
                        },
                      );
                    },
                    child: GlassContainer(
                      isVault: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 16.v),
                      child: Row(
                        children: [
                          const Icon(Icons.delete_forever, color: AppColors.vaultDanger),
                          Gap.h(12),
                          const Expanded(
                            child: AppText(
                              'Wipe Vault Data',
                              size: 14,
                              weight: FontWeight.w500,
                              color: AppColors.vaultDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap.v(40),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
