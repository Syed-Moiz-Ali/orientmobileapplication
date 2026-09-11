import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant.withValues(alpha: _animation.value * 0.4),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class OwnerDashboardSkeleton extends StatelessWidget {
  const OwnerDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            width: double.infinity,
            height: 150,
            borderRadius: 24,
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 140, height: 20),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 20)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 20)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 20)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(width: double.infinity, height: 90, borderRadius: 20)),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 160, height: 20),
          const SizedBox(height: 12),
          const ShimmerBox(width: double.infinity, height: 180, borderRadius: 24),
          const SizedBox(height: 24),
          const ShimmerBox(width: 130, height: 20),
          const SizedBox(height: 12),
          const ShimmerBox(width: double.infinity, height: 140, borderRadius: 20),
        ],
      ),
    );
  }
}

class KpiGridSkeleton extends StatelessWidget {
  const KpiGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(child: ShimmerBox(width: double.infinity, height: 95, borderRadius: 20)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(width: double.infinity, height: 95, borderRadius: 20)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: ShimmerBox(width: double.infinity, height: 95, borderRadius: 20)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(width: double.infinity, height: 95, borderRadius: 20)),
          ],
        ),
      ],
    );
  }
}
