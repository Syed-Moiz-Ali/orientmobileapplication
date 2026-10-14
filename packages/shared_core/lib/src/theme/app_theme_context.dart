import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';

/// Ergonomic, null-safe access to the active theme's color authorities.
///
/// Concept A V2 rule: **styling reads from the active theme, never from a
/// static light/dark palette pair.**
///
/// - [colors] exposes the standard Material [ColorScheme] roles.
/// - [semanticColors] exposes the custom automotive/workshop roles carried by
///   the [AppSemanticColors] [ThemeExtension] (raises/recesses, status families,
///   sync state, inspection findings, damage severity, chart series …).
///
/// Both are guaranteed non-null: when a subtree supplies a bare [ThemeData]
/// without the extension (e.g. a widget test pumping `MaterialApp()`), the
/// frozen light/dark resolution is used so call sites never need `!` or a
/// fallback branch. This mirrors the null-safety of `Theme.of(context)`.
extension AppThemeContext on BuildContext {
  /// The active Material color scheme (standard roles).
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The active Concept A semantic palette (custom roles).
  AppSemanticColors get semanticColors {
    final theme = Theme.of(this);
    return theme.extension<AppSemanticColors>() ??
        AppSemanticColors.forBrightness(theme.brightness);
  }
}
