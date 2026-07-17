import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

/// Share is a disabled no-op for this phase — Delete is the only live action.
class LetterActionIcons extends StatelessWidget {
  const LetterActionIcons({super.key, required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Opacity(
          opacity: 0.4,
          child: Row(
            children: [
              Icon(Icons.ios_share_rounded, size: 16.h, color: AppColors.textLo),
              Gap.h(6),
              const AppText('Share', size: 12.5, color: AppColors.textLo),
            ],
          ),
        ),
        Gap.h(20),
        GestureDetector(
          onTap: onDelete,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 16.h, color: AppColors.danger),
              Gap.h(6),
              const AppText('Delete', size: 12.5, color: AppColors.danger),
            ],
          ),
        ),
      ],
    );
  }
}
