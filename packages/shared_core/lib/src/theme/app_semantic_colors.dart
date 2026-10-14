import 'package:flutter/material.dart';

import 'app_colors.dart';

/// A resolved family of colors for one semantic status role.
///
/// [base] is the high-chroma accent (icons, dots, strong fills); [subtle] is the
/// pale container fill; [border] is the hairline ring; [ink] is the legible
/// text/icon ink that sits on [subtle] or directly on the canvas.
///
/// This is the single source of truth for "status" colour grammar so widgets no
/// longer branch on brightness to pick a light or dark hex.
@immutable
class AppStatusColors {
  final Color base;
  final Color subtle;
  final Color border;
  final Color ink;

  const AppStatusColors({
    required this.base,
    required this.subtle,
    required this.border,
    required this.ink,
  });

  static AppStatusColors lerp(AppStatusColors a, AppStatusColors b, double t) {
    return AppStatusColors(
      base: Color.lerp(a.base, b.base, t)!,
      subtle: Color.lerp(a.subtle, b.subtle, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      ink: Color.lerp(a.ink, b.ink, t)!,
    );
  }
}

/// Centralized **automotive / workshop** semantic palette for Concept A V2.
///
/// Standard Material roles (surface, onSurface, primary, error, outline,
/// container roles, inverses …) are supplied by [ColorScheme] and must be read
/// from `context.colors`. This [ThemeExtension] carries **only** the roles that
/// Material does not model — recessed/raised neutral surfaces, brand tint
/// containers, deep status inks, skeleton shimmers, scrims, the chart series,
/// and the domain roles (inspection findings, sync state, damage severity,
/// operational indicators) — resolved for the active brightness in **one**
/// place ([AppTheme.light] / [AppTheme.dark]).
///
/// Widgets read the resolved values through the ergonomic `context.semanticColors`
/// accessor (`app_theme_context.dart`) instead of repeatedly writing
/// `dark ? AppDarkColors.x : AppColors.x`.
///
/// **Rule (V2):** ordinary widgets must never select between `AppColors.*` and
/// `AppDarkColors.*`. Resolve once here, consume everywhere.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  // ---------------------------------------------------------------------------
  // Neutral surfaces & borders (recessed / raised / strong)
  // ---------------------------------------------------------------------------
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceSunken;
  final Color surfaceRaised;
  final Color surfaceStrong;
  final Color selectedSurface;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  // ---------------------------------------------------------------------------
  // Brand (Hyper Cobalt + tint containers)
  // ---------------------------------------------------------------------------
  final Color primary;
  final Color primarySubtle;
  final Color primaryBorder;

  /// 2 px focus ring ink.
  final Color focusRing;

  /// Ink that stays WCAG-compliant on [primary] / [danger] fills (busy spinner).
  final Color onPrimary;
  final Color onError;

  // ---------------------------------------------------------------------------
  // Global focus + disabled grammar (Phase 01.2 — single authority).
  //
  // [disabledFill] is the fill of a disabled control; [disabledInk] is the
  // label/icon ink rendered on it; [disabledBorder] is the hairline of a
  // disabled outlined control. All three are consumed by `AppTheme._buildTheme`
  // (buttons, inputs, chips, switches, checkboxes) so no widget invents its
  // own disabled greys.
  // ---------------------------------------------------------------------------
  final Color disabledFill;
  final Color disabledInk;
  final Color disabledBorder;

  // ---------------------------------------------------------------------------
  // Status families
  // ---------------------------------------------------------------------------
  final AppStatusColors neutral;
  final AppStatusColors success;
  final AppStatusColors warning;
  final AppStatusColors danger;
  final AppStatusColors info;

  // ---------------------------------------------------------------------------
  // Shimmer & scrim
  // ---------------------------------------------------------------------------
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color overlayScrim;

  // ---------------------------------------------------------------------------
  // Chart series (ordered telemetry palette, max 4 series per chart)
  // ---------------------------------------------------------------------------
  final List<Color> chartSeries;

  const AppSemanticColors({
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceSunken,
    required this.surfaceRaised,
    required this.surfaceStrong,
    required this.selectedSurface,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.primary,
    required this.primarySubtle,
    required this.primaryBorder,
    required this.focusRing,
    required this.onPrimary,
    required this.onError,
    required this.disabledFill,
    required this.disabledInk,
    required this.disabledBorder,
    required this.neutral,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.overlayScrim,
    required this.chartSeries,
  });

  // ---------------------------------------------------------------------------
  // Domain roles — resolve to the status families above (no new color values).
  // ---------------------------------------------------------------------------

  /// Offline sync: a local change that has not reached the server yet.
  AppStatusColors get syncNotSent => warning;

  /// Offline sync: a local change queued for the next sync pass.
  AppStatusColors get syncQueued => info;

  /// Offline sync: a local change whose sync attempt failed.
  AppStatusColors get syncFailed => danger;

  /// Offline sync: a local change that has been synchronized.
  AppStatusColors get syncSynced => success;

  /// Inspection finding: the checkpoint passed / item verified.
  AppStatusColors get inspectionPass => success;

  /// Inspection finding: an advisory / monitor item.
  AppStatusColors get inspectionAdvisory => warning;

  /// Inspection finding: a critical failure / safety hazard.
  AppStatusColors get inspectionFail => danger;

  /// Vehicle damage severity: cosmetic / minor.
  AppStatusColors get damageMinor => info;

  /// Vehicle damage severity: moderate / requires attention.
  AppStatusColors get damageModerate => warning;

  /// Vehicle damage severity: severe / structural.
  AppStatusColors get damageSevere => danger;

  /// Operational indicator: bay active / job in progress.
  AppStatusColors get operationalActive => success;

  /// Operational indicator: idle / unassigned.
  AppStatusColors get operationalIdle => neutral;

  /// Operational indicator: blocked / awaiting parts or approval.
  AppStatusColors get operationalBlocked => danger;

  // ---------------------------------------------------------------------------
  // Frozen Concept A light / dark resolutions.
  // ---------------------------------------------------------------------------
  static const AppSemanticColors light = AppSemanticColors(
    surface: AppColors.surface,
    surfaceSubtle: AppColors.surfaceSubtle,
    surfaceSunken: AppColors.surfaceSunken,
    surfaceRaised: AppColors.surfaceRaised,
    surfaceStrong: AppColors.surfaceStrong,
    selectedSurface: AppColors.selected,
    borderSubtle: AppColors.borderSubtle,
    borderDefault: AppColors.borderDefault,
    borderStrong: AppColors.borderStrong,
    primary: AppColors.primary,
    primarySubtle: AppColors.primarySubtle,
    primaryBorder: AppColors.primaryBorder,
    focusRing: AppColors.primary,
    onPrimary: AppColors.textInverse,
    onError: AppColors.textInverse,
    disabledFill: AppColors.disabled,
    disabledInk: AppColors.textDisabled,
    disabledBorder: AppColors.borderDefault,
    neutral: AppStatusColors(
      base: AppColors.textSecondary,
      subtle: AppColors.gray100,
      border: AppColors.borderDefault,
      ink: AppColors.textSecondary,
    ),
    success: AppStatusColors(
      base: AppColors.success,
      subtle: AppColors.successSubtle,
      border: AppColors.successBorder,
      ink: Color(0xFF166534),
    ),
    warning: AppStatusColors(
      base: AppColors.warning,
      subtle: AppColors.warningSubtle,
      border: AppColors.warningBorder,
      ink: Color(0xFF92400E),
    ),
    danger: AppStatusColors(
      base: AppColors.danger,
      subtle: AppColors.dangerSubtle,
      border: AppColors.dangerBorder,
      ink: Color(0xFFB91C1C),
    ),
    info: AppStatusColors(
      base: AppColors.info,
      subtle: AppColors.infoSubtle,
      border: AppColors.infoBorder,
      ink: Color(0xFF1D4ED8),
    ),
    skeletonBase: AppColors.skeletonBase,
    skeletonHighlight: AppColors.skeletonHighlight,
    overlayScrim: AppColors.overlayScrim,
    chartSeries: AppColors.chartSeries,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    surface: AppDarkColors.surface,
    surfaceSubtle: AppDarkColors.surfaceSubtle,
    surfaceSunken: AppDarkColors.surfaceSunken,
    surfaceRaised: AppDarkColors.surfaceRaised,
    surfaceStrong: AppDarkColors.surfaceStrong,
    selectedSurface: AppDarkColors.selected,
    borderSubtle: AppDarkColors.borderSubtle,
    borderDefault: AppDarkColors.borderDefault,
    borderStrong: AppDarkColors.borderStrong,
    primary: AppDarkColors.primary,
    primarySubtle: AppDarkColors.primarySubtle,
    primaryBorder: AppDarkColors.primaryBorder,
    focusRing: AppDarkColors.focusRing,
    onPrimary: AppDarkColors.onPrimary,
    onError: AppDarkColors.onError,
    disabledFill: AppDarkColors.surfaceSunken,
    disabledInk: AppDarkColors.textDisabled,
    disabledBorder: AppDarkColors.borderDefault,
    neutral: AppStatusColors(
      base: AppDarkColors.textSecondary,
      subtle: AppDarkColors.surfaceSubtle,
      border: AppDarkColors.borderDefault,
      ink: AppDarkColors.textSecondary,
    ),
    success: AppStatusColors(
      base: AppDarkColors.success,
      subtle: AppDarkColors.successSubtle,
      border: AppDarkColors.successBorder,
      ink: AppDarkColors.success,
    ),
    warning: AppStatusColors(
      base: AppDarkColors.warning,
      subtle: AppDarkColors.warningSubtle,
      border: AppDarkColors.warningBorder,
      ink: AppDarkColors.warning,
    ),
    danger: AppStatusColors(
      base: AppDarkColors.danger,
      subtle: AppDarkColors.dangerSubtle,
      border: AppDarkColors.dangerBorder,
      ink: AppDarkColors.danger,
    ),
    info: AppStatusColors(
      base: AppDarkColors.info,
      subtle: AppDarkColors.infoSubtle,
      border: AppDarkColors.infoBorder,
      ink: AppDarkColors.info,
    ),
    skeletonBase: AppDarkColors.skeletonBase,
    skeletonHighlight: AppDarkColors.skeletonHighlight,
    overlayScrim: AppDarkColors.overlayScrim,
    chartSeries: AppColors.chartSeriesDark,
  );

  /// Resolves the frozen palette for a brightness.
  static AppSemanticColors forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? AppSemanticColors.dark
      : AppSemanticColors.light;

  /// Status family for a [StatusColorRole].
  AppStatusColors status(StatusColorRole role) => switch (role) {
    StatusColorRole.neutral => neutral,
    StatusColorRole.success => success,
    StatusColorRole.warning => warning,
    StatusColorRole.danger => danger,
    StatusColorRole.info => info,
  };

  @override
  AppSemanticColors copyWith({
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceSunken,
    Color? surfaceRaised,
    Color? surfaceStrong,
    Color? selectedSurface,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? primary,
    Color? primarySubtle,
    Color? primaryBorder,
    Color? focusRing,
    Color? onPrimary,
    Color? onError,
    Color? disabledFill,
    Color? disabledInk,
    Color? disabledBorder,
    AppStatusColors? neutral,
    AppStatusColors? success,
    AppStatusColors? warning,
    AppStatusColors? danger,
    AppStatusColors? info,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? overlayScrim,
    List<Color>? chartSeries,
  }) {
    return AppSemanticColors(
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      primaryBorder: primaryBorder ?? this.primaryBorder,
      focusRing: focusRing ?? this.focusRing,
      onPrimary: onPrimary ?? this.onPrimary,
      onError: onError ?? this.onError,
      disabledFill: disabledFill ?? this.disabledFill,
      disabledInk: disabledInk ?? this.disabledInk,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      neutral: neutral ?? this.neutral,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      chartSeries: chartSeries ?? this.chartSeries,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      primaryBorder: Color.lerp(primaryBorder, other.primaryBorder, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      disabledFill: Color.lerp(disabledFill, other.disabledFill, t)!,
      disabledInk: Color.lerp(disabledInk, other.disabledInk, t)!,
      disabledBorder: Color.lerp(disabledBorder, other.disabledBorder, t)!,
      neutral: AppStatusColors.lerp(neutral, other.neutral, t),
      success: AppStatusColors.lerp(success, other.success, t),
      warning: AppStatusColors.lerp(warning, other.warning, t),
      danger: AppStatusColors.lerp(danger, other.danger, t),
      info: AppStatusColors.lerp(info, other.info, t),
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      chartSeries: [
        for (var i = 0; i < chartSeries.length; i++)
          Color.lerp(chartSeries[i], other.chartSeries[i], t)!,
      ],
    );
  }
}

/// The five supported semantic status families.
enum StatusColorRole { neutral, success, warning, danger, info }
