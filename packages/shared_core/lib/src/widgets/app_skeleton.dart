import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// Clean skeleton loader primitive with animated pulse shimmer.
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppDimensions.radiusControl,
  });

  /// Skeleton for a card container
  const AppSkeleton.card({
    super.key,
    this.width,
    this.height = 120.0,
    this.borderRadius = AppDimensions.radiusCard,
  });

  /// Skeleton for a circular avatar or icon
  const AppSkeleton.circle({
    super.key,
    double size = 40.0,
  })  : width = size,
        height = size,
        borderRadius = AppDimensions.radiusPill;

  /// Skeleton for a single line of text
  const AppSkeleton.text({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = AppDimensions.radiusXs,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.borderDefault,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.borderDefault.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
