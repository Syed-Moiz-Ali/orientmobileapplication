import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Calm tonal surface shared by the Customer service summary (Home) and the
/// service tracking panels (Status): one accent, one restrained radius, no
/// shadow, and only enough tint to signal importance.
class CustomerSurfacePanel extends StatelessWidget {
  final Color accent;
  final bool emphasised;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CustomerSurfacePanel({
    super.key,
    required this.accent,
    required this.child,
    this.emphasised = false,
    this.padding = const EdgeInsets.all(AppDimensions.s18),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(alpha: emphasised ? 0.08 : 0.04),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: accent.withValues(alpha: emphasised ? 0.30 : 0.18),
        ),
      ),
      child: child,
    );
  }
}
