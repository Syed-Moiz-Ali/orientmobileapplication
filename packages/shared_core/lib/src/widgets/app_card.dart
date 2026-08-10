import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.borderRadius = AppDimensions.r14,
    this.boxShadow,
    this.onTap,
  });

  const AppCard.surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.s16),
    this.color,
    this.borderColor,
    this.borderRadius = AppDimensions.r18,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolves colors strictly from Theme.of(context)
    final effectiveBackgroundColor = color ?? colorScheme.surface;
    final effectiveBorderColor = borderColor ?? colorScheme.outline.withValues(alpha: 0.12);

    // Hyper-minimalist ambient shadow using the theme's shadow/onSurface tone
    final defaultShadow = [
      BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
    ];

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimensions.s16),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: colorScheme.primary.withValues(alpha: 0.05),
          highlightColor: colorScheme.primary.withValues(alpha: 0.02),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
