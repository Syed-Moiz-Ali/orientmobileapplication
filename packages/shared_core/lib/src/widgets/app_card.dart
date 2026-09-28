import 'package:flutter/material.dart';

import '../../shared_core.dart';

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

  /// Standard elevated white card with subtle 1px border and soft shadow.
  AppCard.standard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  }) : color = AppColors.surface,
       borderColor = AppColors.borderDefault,
       border = Border.all(color: AppColors.borderDefault),
       boxShadow = AppDimensions.shadowCard,
       elevation = null;

  /// Subtle card with soft tinted background and no shadow, ideal for secondary groupings.
  AppCard.subtle({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  }) : color = AppColors.surfaceSubtle,
       borderColor = AppColors.borderDefault,
       border = Border.all(color: AppColors.borderDefault),
       boxShadow = null,
       elevation = 0;

  /// Clean outlined card with transparent/surface background and crisp border.
  AppCard.outlined({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  }) : color = AppColors.surface,
       borderColor = AppColors.borderStrong,
       border = Border.all(color: AppColors.borderStrong),
       boxShadow = null,
       elevation = 0;

  /// Interactive card with guaranteed minimum touch target and hover/pressed states.
  AppCard.interactive({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  }) : color = AppColors.surface,
       borderColor = AppColors.borderDefault,
       border = Border.all(color: AppColors.borderDefault),
       boxShadow = AppDimensions.shadowCard,
       elevation = null;

  /// Selected state card with primary subtle background and electric blue border.
  AppCard.selected({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.borderRadius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
  }) : color = AppColors.primarySubtle,
       borderColor = AppColors.primary,
       border = Border.all(color: AppColors.primary, width: 1.5),
       boxShadow = null,
       elevation = 0;

  /// High-emphasis dark navy surface with white text and dark theme propagation.
  factory AppCard.navy({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppDimensions.s18),
    double borderRadius = AppDimensions.radiusPanel,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      color: AppColors.navy,
      borderColor: const Color(0xFF2A3A5E),
      borderRadius: borderRadius,
      boxShadow: AppDimensions.shadowNavy,
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Theme(
        data: ThemeData(
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(surface: AppColors.navy, primary: Color(0xFF60A5FA)),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  /// Semantic colored alert card for success, warning, danger, or info.
  factory AppCard.semantic({
    Key? key,
    required Widget child,
    required Color baseColor,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppDimensions.s14),
    double borderRadius = AppDimensions.radiusCard,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      color: baseColor.withValues(alpha: 0.08),
      borderColor: baseColor.withValues(alpha: 0.28),
      border: Border.all(color: baseColor.withValues(alpha: 0.28)),
      borderRadius: borderRadius,
      elevation: 0,
      width: width,
      height: height,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final adaptive = context.adaptive;

    final effectiveBackgroundColor = color ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline;

    final effectiveRadius = borderRadius == AppDimensions.r14 ? adaptive.radius : borderRadius;

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
