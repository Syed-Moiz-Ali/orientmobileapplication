import 'package:flutter/material.dart';

/// Font families of the ORIENT design system.
///
/// Latin (canonical): Plus Jakarta Sans, bundled with `shared_core`.
/// Arabic: IBM Plex Sans Arabic (SIL OFL). Phase 01 wires the family constant
/// and fallback chain; Phase 02 bundles the font assets under
/// `shared_core/assets/fonts/` and registers the family. Referencing the
/// family before its asset exists is test-safe — Flutter falls through the
/// [arabicFallback] chain to the system Arabic font.
abstract final class AppFontFamilies {
  static const String app = 'packages/shared_core/Plus Jakarta Sans';
  static const String display = app;
  static const String body = app;
  static const String mono = app;

  /// Arabic UI family (registered by Phase 02).
  static const String arabic = 'packages/shared_core/IBM Plex Sans Arabic';

  /// Arabic fallback chain (spec: IBM Plex Sans Arabic → Noto Sans Arabic →
  /// system Arabic font). Exercised even before the bundled asset exists.
  static const List<String> arabicFallback = <String>[
    'Noto Sans Arabic',
    'sans-serif',
  ];
}

/// Disciplined typographic hierarchy for the ORIENT design system.
///
/// Designed to maintain strict visual clarity at both standard and accessibility
/// text scales (up to 1.8x).
///
/// Every role takes an optional `arabic` flag (Phase 01). When true the role
/// renders in [AppFontFamilies.arabic] with the Arabic metrics frozen in
/// Phase 00: line-height ×1.05, zero letter-spacing. Latin output is
/// byte-identical whether the flag is passed or not. Roles marked
/// `latinFamilyOnly` (mono/tabular identifiers — VIN, plate, money, codes)
/// always keep the Latin family in both locales.
class AppTextStyles {
  AppTextStyles._();

  /// Shared role builder. Keeps the Arabic/Latin metric rules in one place so
  /// no role can drift.
  static TextStyle _role({
    required Color? color,
    required bool arabic,
    required String family,
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double letterSpacing = 0,
    bool tabular = false,
    bool latinFamilyOnly = false,
  }) {
    final useArabicFamily = arabic && !latinFamilyOnly;
    return TextStyle(
      fontFamily: useArabicFamily ? AppFontFamilies.arabic : family,
      fontFamilyFallback: useArabicFamily
          ? AppFontFamilies.arabicFallback
          : null,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: arabic && height != null
          ? height * AppTypography.arabicLineHeightScale
          : height,
      letterSpacing: arabic ? 0 : letterSpacing,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
      color: color,
    );
  }

  // ---------------------------------------------------------------------------
  // Display & Hero
  // ---------------------------------------------------------------------------
  static TextStyle displayLarge({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static TextStyle displaySmall({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.2,
  );

  // ---------------------------------------------------------------------------
  // Titles & Headings
  // ---------------------------------------------------------------------------
  /// Compact, strong, high-contrast page title (22px).
  static TextStyle pageTitle({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
  );

  /// Section heading (18px) for major card groupings and sheet headers.
  static TextStyle sectionTitle({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.1,
  );

  /// Card title (15px) for entities, vehicles, job cards, customer records.
  static TextStyle cardTitle({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ---------------------------------------------------------------------------
  // Body Text
  // ---------------------------------------------------------------------------
  /// High-emphasis body copy (14px, semi-bold) for lead paragraphs and active values.
  static TextStyle bodyStrong({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  /// Standard readable body copy (14px, regular).
  static TextStyle body({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  /// Supporting body / caption (13px) for secondary descriptions and notes.
  static TextStyle bodySmall({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Labels, Eyebrows & Metadata
  // ---------------------------------------------------------------------------
  /// Form labels, table cells, and interactive controls (13px, semi-bold).
  static TextStyle label({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
  );

  /// Uppercase eyebrow / kicker label (11px, bold, tracking 0.8) for section tags.
  /// Arabic: no tracking and no case transforms (V11).
  static TextStyle eyebrow({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.8,
  );

  /// Small quiet metadata (12px, medium) for timestamps, VINs, and IDs.
  static TextStyle metadata({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Captions and helper annotations (12px, regular).
  static TextStyle caption({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Table column headers (12px, bold, tracking 0.4).
  /// Arabic: no tracking (V11).
  static TextStyle tableHeader({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.body,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0.4,
  );

  // ---------------------------------------------------------------------------
  // Numeric Metrics & Tabular Data
  // ---------------------------------------------------------------------------
  /// High-impact numeric metric value with tabular figures for telemetry.
  static TextStyle metric({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.3,
    tabular: true,
  );

  /// Button typography (14px, semi-bold, high legibility).
  static TextStyle button({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // ---------------------------------------------------------------------------
  // Monospace & Code Formatting
  // ---------------------------------------------------------------------------
  /// Latin-only tabular role for plates, money, odometers, codes and VINs.
  /// Stays in the Latin family in both locales (spec §3.3).
  static TextStyle mono({Color? color, bool arabic = false}) => _role(
    color: color,
    arabic: arabic,
    family: AppFontFamilies.mono,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.35,
    tabular: true,
    latinFamilyOnly: true,
  );

  static TextStyle monoDate({Color? color, bool arabic = false}) =>
      mono(color: color, arabic: arabic);
  static TextStyle monoTime({Color? color, bool arabic = false}) =>
      mono(color: color, arabic: arabic);
  static TextStyle monoMetric({Color? color, bool arabic = false}) =>
      mono(color: color, arabic: arabic);
  static TextStyle monoCode({Color? color, bool arabic = false}) =>
      mono(color: color, arabic: arabic);
  static TextStyle monoTable({Color? color, bool arabic = false}) =>
      mono(color: color, arabic: arabic);

  // ---------------------------------------------------------------------------
  // Backward-Compatible Aliases
  // ---------------------------------------------------------------------------
  static TextStyle title({Color? color, bool arabic = false}) =>
      sectionTitle(color: color, arabic: arabic);
  static TextStyle subtitle({Color? color, bool arabic = false}) =>
      cardTitle(color: color, arabic: arabic);
  static TextStyle entityTitle({Color? color, bool arabic = false}) =>
      cardTitle(color: color, arabic: arabic);
}

class AppTypography {
  AppTypography._();

  /// Arabic line-height multiplier frozen in Phase 00 (V11 / spec §3.3):
  /// Arabic roles render at ≈1.05× the Latin line-height.
  static const double arabicLineHeightScale = 1.05;

  /// True when [locale] is Arabic (any region). Null or unknown locales fall
  /// back to the Latin stack (English fallback, spec §9 of the l10n strategy).
  static bool isArabic(Locale? locale) => locale?.languageCode == 'ar';

  /// Locale-aware letter-spacing helper (Phase 02). Arabic never receives
  /// tracking (V11) — call sites that hard-code a Latin tracking value use this
  /// so the Arabic glyphs stay correctly joined.
  static double tracking(BuildContext context, double latin) {
    return isArabic(Localizations.maybeLocaleOf(context)) ? 0 : latin;
  }

  /// Material [TextTheme] of the canonical (Latin) design language.
  static TextTheme get textTheme => forLocale(null);

  /// Locale-aware text theme: switches the family stack and line-height
  /// metrics per locale (Latin → Plus Jakarta Sans; Arabic → IBM Plex Sans
  /// Arabic with ×1.05 line-height and zero letter-spacing).
  ///
  /// Phase 02 registers the Arabic assets and wires this into the apps;
  /// call sites that consume `Theme.of(context).textTheme` need no changes.
  static TextTheme forLocale(Locale? locale) {
    final arabic = isArabic(locale);
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge(arabic: arabic),
      displayMedium: AppTextStyles.displayMedium(arabic: arabic),
      displaySmall: AppTextStyles.displaySmall(arabic: arabic),
      headlineLarge: AppTextStyles.displayMedium(arabic: arabic),
      headlineMedium: AppTextStyles.pageTitle(arabic: arabic),
      headlineSmall: AppTextStyles.sectionTitle(arabic: arabic),
      titleLarge: AppTextStyles.sectionTitle(arabic: arabic),
      titleMedium: AppTextStyles.cardTitle(arabic: arabic),
      titleSmall: AppTextStyles.bodyStrong(arabic: arabic),
      bodyLarge: AppTextStyles.bodyStrong(arabic: arabic),
      bodyMedium: AppTextStyles.body(arabic: arabic),
      bodySmall: AppTextStyles.bodySmall(arabic: arabic),
      labelLarge: AppTextStyles.button(arabic: arabic),
      labelMedium: AppTextStyles.label(arabic: arabic),
      labelSmall: AppTextStyles.metadata(arabic: arabic),
    );
  }
}
