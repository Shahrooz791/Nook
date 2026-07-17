import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';

/// Edit and Delete actions shown at the bottom of an unlocked letter.
class LetterActionIcons extends StatelessWidget {
  const LetterActionIcons({
    super.key,
    required this.onDelete,
    required this.onEdit,
  });

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onEdit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16.h, color: AppColors.accent),
              Gap.h(6),
              const AppText('Edit', size: 12.5, color: AppColors.accent),
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
