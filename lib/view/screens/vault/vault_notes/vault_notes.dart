import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nook/controller/vault_notes_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/widgets/primary_button.dart';
import 'package:nook/view/screens/vault/components/vault_delete_confirm_dialog.dart';
import 'package:nook/view/screens/vault/vault_notes/components/vault_note_editor.dart';

class VaultNotesScreen extends StatelessWidget {
  const VaultNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultNotesController controller = Get.put(VaultNotesController());

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
                        'Secure Notes',
                        size: 20,
                        weight: FontWeight.w600,
                        color: AppColors.vaultTextHi,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.vaultAccent),
                      onPressed: () => Get.to(() => const VaultNoteEditor()),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: Obx(() {
                  if (controller.notes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note_outlined,
                              size: 64.adaptSize,
                              color: AppColors.vaultTextLo.withValues(alpha: 0.5),
                            ),
                            Gap.v(16),
                            const AppText(
                              'No secure notes yet',
                              size: 16,
                              color: AppColors.vaultTextLo,
                              weight: FontWeight.w500,
                            ),
                            Gap.v(24),
                            PrimaryButton(
                              label: 'Add Note',
                              isVault: true,
                              onTap: () => Get.to(() => const VaultNoteEditor()),
                              width: 180.h,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.v),
                    itemCount: controller.notes.length,
                    itemBuilder: (context, index) {
                      final note = controller.notes[index];
                      return _buildNoteItem(context, note, controller);
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

  Widget _buildNoteItem(BuildContext context, DecryptedNote note, VaultNotesController controller) {
    final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(note.raw.updatedAt));
    final previewText = note.body.length > 60
        ? '${note.body.substring(0, 60)}...'
        : note.body.isEmpty
            ? 'Empty note'
            : note.body;

    return Dismissible(
      key: Key(note.raw.id.toString()),
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
          title: 'Delete Note',
          message: 'Are you sure you want to delete "${note.title}"?',
        );
      },
      onDismissed: (direction) {
        controller.deleteNote(note.raw.id!);
      },
      child: GestureDetector(
        onTap: () => Get.to(() => VaultNoteEditor(note: note)),
        child: GlassContainer(
          isVault: true,
          margin: EdgeInsets.only(bottom: 12.v),
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      note.title,
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.vaultTextHi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppText(
                    dateStr,
                    size: 11,
                    color: AppColors.vaultTextLo,
                  ),
                ],
              ),
              Gap.v(8),
              AppText(
                previewText,
                size: 13,
                color: AppColors.vaultTextLo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
