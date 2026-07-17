import 'package:flutter/material.dart';
import 'package:nook/core/constant/app_colors.dart';
import 'package:nook/core/utils/size_utils.dart';

/// Single tap → Add Letter. Hold → Vault (still just a placeholder route,
/// but the gesture + navigation call are fully wired for Phase 2).
/// A thin progress ring plus a slight scale-down give the hold a visible
/// sense of "this is intentional" while it's charging.
class HomeFab extends StatefulWidget {
  const HomeFab({super.key, required this.onTap, required this.onHold});

  final VoidCallback onTap;
  final VoidCallback onHold;

  @override
  State<HomeFab> createState() => _HomeFabState();
}

class _HomeFabState extends State<HomeFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _holdTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_holdTriggered) {
          _holdTriggered = true;
          widget.onHold();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    _holdTriggered = false;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    _controller.stop();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - (_controller.value * 0.12);
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 60.h,
              height: 60.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller.value > 0)
                    SizedBox(
                      width: 60.h,
                      height: 60.h,
                      child: CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 2.5,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.textHi.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  child!,
                ],
              ),
            ),
          );
        },
        child: Container(
          width: 52.h,
          height: 52.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.add_rounded, size: 26.h, color: const Color(0xFF1A1420)),
        ),
      ),
    );
  }
}
