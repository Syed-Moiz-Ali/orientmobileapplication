import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Shared loading-placeholder plumbing for Customer surfaces.
///
/// One animation controller drives an entire skeleton surface and is disabled
/// when the platform asks for reduced motion, so a loading screen never burns
/// more than a single ticker.
class CustomerSkeleton extends StatefulWidget {
  final Widget Function(BuildContext context, Color blockColor) builder;

  const CustomerSkeleton({super.key, required this.builder});

  @override
  State<CustomerSkeleton> createState() => _CustomerSkeletonState();
}

class _CustomerSkeletonState extends State<CustomerSkeleton>
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

    Color blockColor(double t) => Color.lerp(
      colors.surfaceContainerHighest,
      colors.surfaceContainerHigh,
      t,
    )!;

    if (controller == null) {
      return widget.builder(context, blockColor(0));
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) =>
          widget.builder(context, blockColor(controller.value)),
    );
  }
}

class CustomerSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const CustomerSkeletonBox({
    super.key,
    required this.height,
    required this.color,
    this.width,
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
