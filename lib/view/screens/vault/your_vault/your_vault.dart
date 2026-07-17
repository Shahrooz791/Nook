import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/view/widgets/app_text.dart';

class YourVaultScreen extends StatelessWidget {
  const YourVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.vaultBgA,
      body: const Center(
        child: AppText('Your Vault — coming soon', size: 14, color: AppColors.vaultTextLo),
      ),
    );
  }
}
