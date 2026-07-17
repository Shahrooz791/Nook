import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:nook/controller/home_controller.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/screens/home/components/home_empty_state.dart';
import 'package:nook/view/screens/home/components/home_fab.dart';
import 'package:nook/view/screens/home/components/home_header.dart';
import 'package:nook/view/screens/home/components/letter_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.bgA,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.publicBgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox.shrink();
                        }
                        if (controller.letters.isEmpty) {
                          return const HomeEmptyState();
                        }
                        return ListView.builder(
                          padding: EdgeInsets.only(top: 8.v, bottom: 110.v),
                          itemCount: controller.letters.length,
                          itemBuilder: (context, index) {
                            final letter = controller.letters[index];
                            return LetterCard(
                              letter: letter,
                              onTap: () => controller.handleLetterTap(letter),
                            ).animate().fadeIn(
                                  delay: (index * 60).ms,
                                  duration: 350.ms,
                                );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 20.h,
                bottom: 24.v,
                child: HomeFab(
                  onTap: controller.openAddLetter,
                  onHold: controller.openVault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
