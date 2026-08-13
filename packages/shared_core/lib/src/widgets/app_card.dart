import 'package:flutter/material.dart';
import 'package:shared_core/src/layout/app_responsive.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// An Uber/Airbnb-grade, highly customizable card container supporting
/// ambient diffuse drop shadows, dynamic responsive corner rounding, and tap feedback.
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
    this.borderRadius = AppDimensions.r24,
    this.boxShadow,
    this.elevation,
    this.width,
    this.height,
    // Defaulting to antiAlias ensures images/backgrounds never bleed outside the luxury curved corners
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
    this.borderRadius = AppDimensions.r24,
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

    // Resolve color system strictly via Theme.of(context)
    final effectiveBackgroundColor = color ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline.withValues(alpha: 0.12);

    // Default corner radius handling: Adapts to layout unless overridden
    final effectiveRadius = (borderRadius == AppDimensions.r14 || borderRadius == AppDimensions.r18)
        ? adaptive.radius
        : borderRadius;

    final effectivePadding = padding ?? EdgeInsets.all(adaptive.itemSpacing);

    // Uber/Airbnb-grade ambient diffuse drop shadow.
    // Upgraded to a softer, deeper blur (24) and offset (8) to match the new "plush" UI.
    final List<BoxShadow>? effectiveShadows = elevation == 0
        ? null
        : (boxShadow ??
              [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]);

    final effectiveBorder = border ?? Border.all(color: effectiveBorderColor);

    // CORE STRUCTURAL FIX:
    // Container handles the Color, Border, and Shadows.
    // Material is set to transparent inside it so the InkWell ripple works CORRECTLY on top of the background.
    final Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
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
        color: Colors.transparent, // Allows the ripple to show over the Container's background
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

    return cardContent;
  }
}
