import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/controller/vault_videos_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';
import 'package:nook/view/screens/vault/vault_videos/components/vault_video_player_screen.dart';

class VaultVideoGrid extends StatelessWidget {
  const VaultVideoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final VaultVideosController controller = Get.find<VaultVideosController>();

    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.all(16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.h,
          mainAxisSpacing: 12.v,
          childAspectRatio: 1.1,
        ),
        itemCount: controller.videos.length,
        itemBuilder: (context, index) {
          final video = controller.videos[index];
          final isSelected = controller.selectedIds.contains(video.id);

          return GestureDetector(
            onTap: () {
              if (controller.isMultiSelect.value) {
                controller.toggleMultiSelect(video.id!);
              } else {
                Get.to(() => VaultVideoPlayerScreen(
                      videos: controller.videos,
                      initialIndex: index,
                    ));
              }
            },
            onLongPress: () {
              controller.toggleMultiSelect(video.id!);
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: GlassContainer(
                    isVault: true,
                    strong: isSelected,
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.vaultAccent
                              : Colors.transparent,
                          width: isSelected ? 2 : 0,
                        ),
                        borderRadius: 18.r,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FutureBuilder<Uint8List?>(
                        future: controller.decryptVideoThumb(video),
                        builder: (context, snapshot) {
                          final thumbData = snapshot.data;
                          return Stack(
                            children: [
                              if (thumbData != null)
                                Positioned.fill(
                                  child: Image.memory(
                                    thumbData,
                                    fit: BoxFit.cover,
                                    cacheWidth: 320,
                                  ),
                                ),
                              if (thumbData != null)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.35),
                                  ),
                                ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 48.adaptSize,
                                      color: AppColors.vaultAccent,
                                    ),
                                    Gap.v(12),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.h,
                                        vertical: 4.v,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.vaultBgA.withValues(alpha: 0.6),
                                        borderRadius: 20.r,
                                      ),
                                      child: AppText(
                                        video.durationDisplay,
                                        color: AppColors.vaultTextHi,
                                        size: 12,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                    if (thumbData == null) ...[
                                      Gap.v(6),
                                      AppText(
                                        'Video #${index + 1}',
                                        color: AppColors.vaultTextLo,
                                        size: 11,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (controller.isMultiSelect.value)
                  Positioned(
                    top: 12.v,
                    right: 12.h,
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
