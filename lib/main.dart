import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/constant/app_fonts.dart';
import 'package:nook/core/utils/routes.dart';
import 'package:nook/core/utils/size_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'Nook',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.routes,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.bgA,
            fontFamily: AppFonts.poppins,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.accent,
              brightness: Brightness.dark,
            ),
          ),
        );
      },
    );
  }
}
