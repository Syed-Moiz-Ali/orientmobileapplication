import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Loading skeleton that mirrors the final Home composition (header, service
/// summary, quick actions, garage) so the first paint does not jump.
///
/// A single animation controller drives the whole surface and is disabled when
/// the platform asks for reduced motion.
class CustomerHomeSkeleton extends StatefulWidget {
  const CustomerHomeSkeleton({super.key});

  @override
  State<CustomerHomeSkeleton> createState() => _CustomerHomeSkeletonState();
}

class _CustomerHomeSkeletonState extends State<CustomerHomeSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = _controller;

    Widget content(double t) => _SkeletonContent(color: colors, tint: t);
    if (controller == null) return content(0);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => content(controller.value),
    );
  }
}

class _SkeletonContent extends StatelessWidget {
  final ColorScheme color;
  final double tint;

  const _SkeletonContent({required this.color, required this.tint});

  @override
  Widget build(BuildContext context) {
    final block = Color.lerp(
      color.surfaceContainerHighest,
      color.surfaceContainerHigh,
      tint,
    )!;

    return AppResponsivePage(
      maxContentWidth: 1080,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 96, height: 12, color: block),
                    const SizedBox(height: AppDimensions.s8),
                    _SkeletonBox(width: 150, height: 26, color: block),
                  ],
                ),
              ),
              _SkeletonBox(
                width: 42,
                height: 42,
                radius: AppDimensions.radiusPill,
                color: block,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          AppSplitView(
            primaryFlex: context.adaptive.isMedium ? 1 : 3,
            secondaryFlex: context.adaptive.isMedium ? 1 : 2,
            spacing: AppDimensions.s24,
            primary: _SkeletonBox(
              width: double.infinity,
              height: 190,
              radius: AppDimensions.radiusCard,
              color: block,
            ),
            secondary: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: AppDimensions.s10),
                        Expanded(
                          child: _SkeletonBox(
                            width: double.infinity,
                            height: 92,
                            radius: AppDimensions.radiusCard,
                            color: block,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.s24),
                _SkeletonBox(width: 120, height: 18, color: block),
                const SizedBox(height: AppDimensions.s12),
                _SkeletonBox(
                  width: double.infinity,
                  height: 128,
                  radius: AppDimensions.radiusCard,
                  color: block,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = AppDimensions.radiusControl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
