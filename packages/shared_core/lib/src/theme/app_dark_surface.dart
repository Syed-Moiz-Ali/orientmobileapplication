import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

/// Selective high-emphasis dark navy panel for the ORIENT visual grammar.
///
/// Used for:
/// - Important executive summaries
/// - Hero metrics and shift telemetry
/// - High-priority workshop workflows
/// - Contextual conclusions and attention callouts
///
/// Automatically provides an inverse, high-contrast dark Theme context to
/// its children so that text, icons, and badges naturally render crisp white
/// and cyan/cobalt accents without manual color overrides.
class AppDarkPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppDarkPanel({
    super.key,
    required this.child,
    this.padding = AppDimensions.cardPaddingSpacious,
    this.borderRadius = AppDimensions.radiusPanel,
    this.backgroundColor = AppColors.navy,
    this.borderColor = AppColors.navyBorder,
    this.boxShadow = AppDimensions.shadowNavy,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panelTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3DE0BF), // Bright cyan/mint accent on dark navy
        onPrimary: AppColors.navy,
        surface: AppColors.navySurfaceRaised,
        onSurfaceVariant: Color(0xFFAAB5C8),
        outline: AppColors.navyBorder,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge(color: AppColors.textInverse),
        displayMedium: AppTextStyles.displayMedium(
          color: AppColors.textInverse,
        ),
        displaySmall: AppTextStyles.displaySmall(color: AppColors.textInverse),
        headlineLarge: AppTextStyles.displayMedium(
          color: AppColors.textInverse,
        ),
        headlineMedium: AppTextStyles.pageTitle(color: AppColors.textInverse),
        headlineSmall: AppTextStyles.sectionTitle(color: AppColors.textInverse),
        titleLarge: AppTextStyles.sectionTitle(color: AppColors.textInverse),
        titleMedium: AppTextStyles.cardTitle(color: AppColors.textInverse),
        titleSmall: AppTextStyles.bodyStrong(color: AppColors.textInverse),
        bodyLarge: AppTextStyles.bodyStrong(color: AppColors.textInverse),
        bodyMedium: AppTextStyles.body(color: const Color(0xFFEAF0FF)),
        bodySmall: AppTextStyles.bodySmall(color: const Color(0xFFAAB5C8)),
        labelLarge: AppTextStyles.button(color: AppColors.textInverse),
        labelMedium: AppTextStyles.label(color: const Color(0xFFEAF0FF)),
        labelSmall: AppTextStyles.metadata(color: const Color(0xFFAAB5C8)),
      ),
      iconTheme: const IconThemeData(color: AppColors.textInverse, size: 20),
    );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: boxShadow,
      ),
      child: Theme(data: panelTheme, child: child),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.08),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: content,
        ),
      );
    }

    return content;
  }
}
