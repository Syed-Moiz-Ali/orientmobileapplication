import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_motion.dart';

/// A restrained grouped surface. Prefer page structure, rows, and dividers before
/// reaching for a card.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final double? elevation;
  final double? width;
  final double? height;
  final Clip clipBehavior;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.border,
    this.borderColor,
    this.borderRadius = AppDimensions.r14,
    this.boxShadow,
    this.elevation,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  });

  const AppCard.surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.color,
    this.border,
    this.borderColor,
    this.borderRadius = AppDimensions.r14,
    this.boxShadow,
    this.elevation,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final adaptive = context.adaptive;

    final effectiveBackgroundColor = color ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;

    final effectiveRadius = borderRadius == AppDimensions.r14
        ? adaptive.radius
        : borderRadius;

    final effectivePadding = padding ?? EdgeInsets.all(adaptive.itemSpacing);

    final List<BoxShadow>? effectiveShadows = elevation == 0
        ? null
        : boxShadow ??
              (elevation == null
                  ? null
                  : [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]);

    final effectiveBorder = border ?? Border.all(color: effectiveBorderColor);

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.enter,
      width: width,
      height: height,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: effectiveBorder,
        boxShadow: effectiveShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: colorScheme.primary.withValues(alpha: 0.08),
                highlightColor: colorScheme.primary.withValues(alpha: 0.04),
                child: Padding(padding: effectivePadding, child: child),
              )
            : Padding(padding: effectivePadding, child: child),
      ),
    );
  }
}
