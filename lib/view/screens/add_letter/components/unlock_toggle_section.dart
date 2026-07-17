import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/date_formatter.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

class UnlockToggleSection extends StatelessWidget {
  const UnlockToggleSection({
    super.key,
    required this.enabled,
    required this.unlockDate,
    required this.onToggle,
    required this.onPickDate,
  });

  final bool enabled;
  final DateTime unlockDate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText('Set an unlock time', size: 14, weight: FontWeight.w500),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: AppColors.accent,
                inactiveThumbColor: AppColors.textLo,
                inactiveTrackColor: AppColors.glassFillStrong,
              ),
            ],
          ),
          if (enabled) ...[
            Gap.v(10),
            GestureDetector(
              onTap: onPickDate,
              child: AppText(
                'Opens on ${DateFormatter.friendly(unlockDate)}',
                isSerif: true,
                size: 16,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
