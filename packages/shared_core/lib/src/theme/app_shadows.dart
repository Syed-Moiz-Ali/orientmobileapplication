import 'package:flutter/widgets.dart';

/// Spec-C5 elevation scale (phase-0b, additive, light mode only).
///
/// Dark mode uses surface lift + borders instead of shadows (see
/// [AppDarkColors]). Border OR shadow on a card — never both.
abstract final class AppShadows {
  AppShadows._();

  /// No elevation.
  static const List<BoxShadow> e0 = [];

  /// Cards: 0 1px 2px + 0 2px 8px at 4% black.
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Floating bars, popovers: 0 4px 16px at 8% black.
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Dialogs, sheets: 0 8px 28px at 12% black.
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];
}
