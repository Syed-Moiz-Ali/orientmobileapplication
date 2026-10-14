import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ergonomic density for data surfaces (Phase 01.2).
///
/// Two frozen modes: [comfortable] (44 px rows, generous padding) and
/// [compact] (36 px rows, dense registers). The active mode is carried by the
/// [AppDensity] [ThemeExtension] so every table / record row / list surface
/// reads one authority instead of branching on screen size alone.
///
/// Wiring: [AppTheme.light]/[AppTheme.dark] register the extension; widgets
/// read it via `context.density`. A Riverpod [densityModeProvider] lets shells
/// toggle density without rebuilding the whole theme tree (see
/// [AppDensityScope]).
enum AppDensityMode { comfortable, compact }

/// Density tokens for Concept A data surfaces.
@immutable
class AppDensity extends ThemeExtension<AppDensity> {
  final AppDensityMode mode;

  /// Desktop table data-row height.
  final double rowHeight;

  /// Desktop table header height.
  final double headerHeight;

  /// Vertical padding inside a record row.
  final double rowPaddingVertical;

  /// Horizontal padding inside a record row.
  final double rowPaddingHorizontal;

  /// Gap between stacked list rows.
  final double listGap;

  const AppDensity({
    required this.mode,
    required this.rowHeight,
    required this.headerHeight,
    required this.rowPaddingVertical,
    required this.rowPaddingHorizontal,
    required this.listGap,
  });

  static const AppDensity comfortable = AppDensity(
    mode: AppDensityMode.comfortable,
    rowHeight: 44,
    headerHeight: 40,
    rowPaddingVertical: 12,
    rowPaddingHorizontal: 16,
    listGap: 8,
  );

  static const AppDensity compact = AppDensity(
    mode: AppDensityMode.compact,
    rowHeight: 36,
    headerHeight: 36,
    rowPaddingVertical: 8,
    rowPaddingHorizontal: 12,
    listGap: 4,
  );

  static AppDensity forMode(AppDensityMode mode) =>
      mode == AppDensityMode.compact ? compact : comfortable;

  bool get isCompact => mode == AppDensityMode.compact;
  bool get isComfortable => mode == AppDensityMode.comfortable;

  @override
  AppDensity copyWith({
    AppDensityMode? mode,
    double? rowHeight,
    double? headerHeight,
    double? rowPaddingVertical,
    double? rowPaddingHorizontal,
    double? listGap,
  }) {
    return AppDensity(
      mode: mode ?? this.mode,
      rowHeight: rowHeight ?? this.rowHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      rowPaddingVertical: rowPaddingVertical ?? this.rowPaddingVertical,
      rowPaddingHorizontal: rowPaddingHorizontal ?? this.rowPaddingHorizontal,
      listGap: listGap ?? this.listGap,
    );
  }

  @override
  AppDensity lerp(covariant ThemeExtension<AppDensity>? other, double t) {
    if (other is! AppDensity) return this;
    return AppDensity(
      mode: t < 0.5 ? mode : other.mode,
      rowHeight: _lerpDouble(rowHeight, other.rowHeight, t),
      headerHeight: _lerpDouble(headerHeight, other.headerHeight, t),
      rowPaddingVertical:
          _lerpDouble(rowPaddingVertical, other.rowPaddingVertical, t),
      rowPaddingHorizontal:
          _lerpDouble(rowPaddingHorizontal, other.rowPaddingHorizontal, t),
      listGap: _lerpDouble(listGap, other.listGap, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Riverpod authority for the active density mode.
///
/// Shells override per-device (e.g. compact on desktop registers) via
/// `ProviderScope(overrides: [densityModeProvider.overrideWithValue(...)])`
/// or toggle at runtime through the notifier. Defaults to comfortable.
final densityModeProvider =
    StateProvider<AppDensityMode>((ref) => AppDensityMode.comfortable);

/// Overrides the [AppDensity] extension for a subtree without rebuilding the
/// app theme (e.g. a dense register inside a comfortable page).
class AppDensityScope extends StatelessWidget {
  final AppDensityMode mode;
  final Widget child;

  const AppDensityScope({
    super.key,
    required this.mode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final density = AppDensity.forMode(mode);
    // Merge via the extensions map (instead of spreading `values` into a
    // typed literal: with the F-bounded `ThemeExtension<T>` on this Flutter
    // revision the spread triggers a bound-normalization error). Passing
    // `merged.values` through preserves every registered extension.
    final merged = Map<Object, ThemeExtension<dynamic>>.of(base.extensions);
    merged[AppDensity] = density;
    return Theme(
      data: base.copyWith(extensions: merged.values),
      child: child,
    );
  }
}

/// Null-safe density accessor. Falls back to the comfortable tokens when a
/// subtree supplies a bare [ThemeData] without the extension (widget tests).
extension AppDensityContext on BuildContext {
  AppDensity get density {
    final theme = Theme.of(this);
    return theme.extension<AppDensity>() ?? AppDensity.comfortable;
  }
}
