import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_passwords_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/widgets/primary_button.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';
import 'package:nook/view/screens/vault/vault_passwords/components/vault_password_form.dart';

class VaultPasswordsScreen extends StatelessWidget {
  const VaultPasswordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultPasswordsController controller = Get.put(VaultPasswordsController());

    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.vaultBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                        'Passwords',
                        size: 20,
                        weight: FontWeight.w600,
                        color: AppColors.vaultTextHi,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.vaultAccent),
                      onPressed: () => _openForm(context),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: Obx(() {
                  if (controller.passwords.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.password_outlined,
                              size: 64.adaptSize,
                              color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                            ),
                            Gap.v(16),
                            const AppText(
                              'No passwords saved yet',
                              size: 16,
                              color: AppColors.vaultTextLo,
                              weight: FontWeight.w500,
                            ),
                            Gap.v(24),
                            PrimaryButton(
                              label: 'Add Password',
                              isVault: true,
                              onTap: () => _openForm(context),
                              width: 180.h,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.v),
                    itemCount: controller.passwords.length,
                    itemBuilder: (context, index) {
                      final item = controller.passwords[index];
                      return _buildPasswordItem(context, item, index, controller);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordItem(
    BuildContext context,
    DecryptedPassword item,
    int index,
    VaultPasswordsController controller,
  ) {
    return Dismissible(
      key: Key(item.raw.id.toString()),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.25,
      },
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
        return await showVaultDeleteDialog(
          title: 'Delete Password',
          message: 'Are you sure you want to delete this password entry for "${item.raw.title}"?',
        );
      },
      onDismissed: (direction) {
        controller.deletePassword(item.raw.id!);
      },
      child: GestureDetector(
        onTap: () => _openForm(context, entry: item),
        child: GlassContainer(
          isVault: true,
          margin: EdgeInsets.only(bottom: 12.v),
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          item.raw.title,
                          size: 16,
                          weight: FontWeight.w600,
                          color: AppColors.vaultTextHi,
                        ),
                        Gap.v(4),
                        AppText(
                          item.username,
                          size: 13,
                          color: AppColors.vaultTextLo,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          item.isRevealed ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.vaultTextLo,
                          size: 20.adaptSize,
                        ),
                        onPressed: () => controller.toggleReveal(index),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.copy_all_outlined,
                          color: AppColors.vaultTextLo,
                          size: 20.adaptSize,
                        ),
                        onPressed: () => controller.copyPassword(index),
                      ),
                    ],
                  ),
                ],
              ),
              Gap.v(8),
              AppText(
                item.isRevealed ? item.password : '••••••••••••',
                size: 14,
                color: item.isRevealed ? AppColors.vaultAccent : AppColors.vaultTextLo,
                letterSpacing: item.isRevealed ? 0.5 : 2.0,
                weight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {DecryptedPassword? entry}) {
    Get.bottomSheet(
      VaultPasswordForm(passwordEntry: entry),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}
