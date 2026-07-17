import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/date_formatter.dart';
import 'package:nook/core/utils/size_utils.dart';
import 'package:nook/model/letter_model.dart';
import 'package:nook/view/widgets/app_text.dart';
import 'package:nook/view/widgets/glass_container.dart';

class LetterCard extends StatelessWidget {
  const LetterCard({super.key, required this.letter, required this.onTap});

  final LetterModel letter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        margin: EdgeInsets.only(bottom: 12.v),
        child: letter.isUnlocked ? _UnlockedContent(letter: letter) : _LockedContent(letter: letter),
      ),
    );
  }
}

class _UnlockedContent extends StatelessWidget {
  const _UnlockedContent({required this.letter});

  final LetterModel letter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(letter.previewTitle, isSerif: true, size: 17, weight: FontWeight.w500),
        Gap.v(6),
        AppText(
          letter.previewText,
          size: 13,
          color: AppColors.textLo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          height: 1.4,
        ),
        Gap.v(10),
        AppText(DateFormatter.short(letter.createdAt), size: 11.5, color: AppColors.textLo),
      ],
    );
  }
}

class _LockedContent extends StatelessWidget {
  const _LockedContent({required this.letter});

  final LetterModel letter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('A letter is waiting', isSerif: true, size: 17),
                    Gap.v(6),
                    AppText(
                      letter.previewText,
                      size: 13,
                      color: AppColors.textLo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Gap.h(10),
            const _SealIcon(),
          ],
        ),
        Gap.v(12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.v),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.14),
            borderRadius: 100.r,
          ),
          child: AppText(
            'Unlocks in ${letter.countdownText}',
            size: 12,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _SealIcon extends StatelessWidget {
  const _SealIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.h,
      height: 30.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withValues(alpha: 0.85),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.lock_rounded, size: 15.h, color: const Color(0xFF1A1420)),
    );
  }
}
