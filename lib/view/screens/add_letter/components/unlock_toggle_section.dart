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
                activeThumbColor: AppColors.accent,
                inactiveThumbColor: AppColors.textLo,
                inactiveTrackColor: AppColors.glassFillStrong,
              ),
            ],
          ),
          if (enabled) ...[
            Gap.v(10),
            GestureDetector(
              onTap: onPickDate,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 11.v),
                decoration: BoxDecoration(
                  color: AppColors.glassFillStrong,
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
                  borderRadius: 12.r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 17.h,
                      color: AppColors.accent,
                    ),
                    Gap.h(10),
                    AppText(
                      DateFormatter.friendly(unlockDate),
                      isSerif: true,
                      size: 15,
                      color: AppColors.accent,
                      weight: FontWeight.w500,
                    ),
                    Gap.h(8),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18.h,
                      color: AppColors.accent.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
