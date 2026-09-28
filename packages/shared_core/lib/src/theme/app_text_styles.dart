import 'package:flutter/material.dart';

abstract final class AppFontFamilies {
  static const String app = 'packages/shared_core/Plus Jakarta Sans';
  static const String display = app;
  static const String body = app;
  static const String mono = app;
}

/// Disciplined typographic hierarchy for the ORIENT design system.
///
/// Designed to maintain strict visual clarity at both standard and accessibility
/// text scales (up to 1.8x).
class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Display & Hero
  // ---------------------------------------------------------------------------
  static TextStyle displayLarge({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
    color: color,
  );

  static TextStyle displaySmall({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Titles & Headings
  // ---------------------------------------------------------------------------
  /// Compact, strong, high-contrast page title (22px).
  static TextStyle pageTitle({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
    color: color,
  );

  /// Section heading (18px) for major card groupings and sheet headers.
  static TextStyle sectionTitle({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.1,
    color: color,
  );

  /// Card title (15px) for entities, vehicles, job cards, customer records.
  static TextStyle cardTitle({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Body Text
  // ---------------------------------------------------------------------------
  /// High-emphasis body copy (14px, semi-bold) for lead paragraphs and active values.
  static TextStyle bodyStrong({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0,
    color: color,
  );

  /// Standard readable body copy (14px, regular).
  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
    color: color,
  );

  /// Supporting body / caption (13px) for secondary descriptions and notes.
  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Labels, Eyebrows & Metadata
  // ---------------------------------------------------------------------------
  /// Form labels, table cells, and interactive controls (13px, semi-bold).
  static TextStyle label({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
    color: color,
  );

  /// Uppercase eyebrow / kicker label (11px, bold, tracking 0.8) for section tags.
  static TextStyle eyebrow({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.8,
    color: color,
  );

  /// Small quiet metadata (12px, medium) for timestamps, VINs, and IDs.
  static TextStyle metadata({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
    color: color,
  );

  /// Captions and helper annotations (12px, regular).
  static TextStyle caption({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0,
    color: color,
  );

  /// Table column headers (12px, bold, tracking 0.4).
  static TextStyle tableHeader({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0.4,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Numeric Metrics & Tabular Data
  // ---------------------------------------------------------------------------
  /// High-impact numeric metric value with tabular figures for telemetry.
  static TextStyle metric({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.3,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: color,
  );

  /// Button typography (14px, semi-bold, high legibility).
  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
    color: color,
  );

  // ---------------------------------------------------------------------------
  // Monospace & Code Formatting
  // ---------------------------------------------------------------------------
  static TextStyle mono({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    fontFeatures: const [FontFeature.tabularFigures()],
    color: color,
  );

  static TextStyle monoDate({Color? color}) => mono(color: color);
  static TextStyle monoTime({Color? color}) => mono(color: color);
  static TextStyle monoMetric({Color? color}) => mono(color: color);
  static TextStyle monoCode({Color? color}) => mono(color: color);
  static TextStyle monoTable({Color? color}) => mono(color: color);

  // ---------------------------------------------------------------------------
  // Backward-Compatible Aliases
  // ---------------------------------------------------------------------------
  static TextStyle title({Color? color}) => sectionTitle(color: color);
  static TextStyle subtitle({Color? color}) => cardTitle(color: color);
  static TextStyle entityTitle({Color? color}) => cardTitle(color: color);
}

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge(),
    displayMedium: AppTextStyles.displayMedium(),
    displaySmall: AppTextStyles.displaySmall(),
    headlineLarge: AppTextStyles.displayMedium(),
    headlineMedium: AppTextStyles.pageTitle(),
    headlineSmall: AppTextStyles.sectionTitle(),
    titleLarge: AppTextStyles.sectionTitle(),
    titleMedium: AppTextStyles.cardTitle(),
    titleSmall: AppTextStyles.bodyStrong(),
    bodyLarge: AppTextStyles.bodyStrong(),
    bodyMedium: AppTextStyles.body(),
    bodySmall: AppTextStyles.bodySmall(),
    labelLarge: AppTextStyles.button(),
    labelMedium: AppTextStyles.label(),
    labelSmall: AppTextStyles.metadata(),
  );
}
