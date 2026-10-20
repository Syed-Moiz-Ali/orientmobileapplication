/// Spec-C4 breakpoints (phase-0b, additive).
///
/// compact < 600 (single column, bottom nav), medium 600–1024 (two columns,
/// side sheets), expanded > 1024 (NavigationRail or 280 drawer, content max
/// width 1200, forms/auth max 560). Use LayoutBuilder or these helpers —
/// never hardcode device checks.
abstract final class Breakpoints {
  Breakpoints._();

  /// Upper bound (exclusive) of the compact class.
  static const double compactMax = 600;

  /// Upper bound (exclusive) of the medium class.
  static const double mediumMax = 1024;

  /// Content max width on expanded screens.
  static const double contentMaxWidth = 1200;

  /// Max width for forms and auth flows on large screens.
  static const double formMaxWidth = 560;

  static bool isCompact(double width) => width < compactMax;

  static bool isMedium(double width) =>
      width >= compactMax && width < mediumMax;

  static bool isExpanded(double width) => width >= mediumMax;

  static double screenGutter(double width) {
    if (isCompact(width)) return 20;
    if (isMedium(width)) return 24;
    return 32;
  }
}
