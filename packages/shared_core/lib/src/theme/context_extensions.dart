import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'breakpoints.dart';

/// Ergonomic theme access for new spec work (phase-0b, additive).
///
/// Extends (not replaces) [AppThemeContext]: `context.colors` and
/// `context.semanticColors` stay where they are. These getters cover the
/// remaining spec-C13 surface: text theme, token view, and breakpoints.
extension AppContextExtensions on BuildContext {
  /// Active Material text theme (locale-aware via AppTheme).
  TextTheme get text => Theme.of(this).textTheme;

  /// Active spec-C2 token view (accent + info-teal families, overlay,
  /// skeleton pair), resolved for the current brightness.
  AppTokens get tokens => AppTokens.of(this);

  // NOTE (phase-0b): isCompact/isMedium/isExpanded intentionally NOT
  // defined here — AppResponsive (src/layout/app_responsive.dart) already
  // owns those names and redefining them breaks every call site. Use
  // Breakpoints helpers or AppResponsive directly for window classes.
  //
  /// Logical screen width for breakpoint decisions.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Horizontal screen padding for the current breakpoint (20/24/32).
  double get gutter => Breakpoints.screenGutter(screenWidth);
}
