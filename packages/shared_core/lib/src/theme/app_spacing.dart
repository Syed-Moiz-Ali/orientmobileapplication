import 'package:flutter/widgets.dart';

/// Spec-C4 spacing scale (phase-0b, additive).
///
/// New screens use ONLY these steps. [AppDimensions] keeps its existing
/// `s*` scale untouched for current widgets; the two scales intentionally
/// overlap so migration is mechanical (s4→xs, s8→sm, s12→md, s16→lg,
/// s20→xl-ish, s24→xl). See DESIGN_SYSTEM.md for the mapping table.
abstract final class AppSpacing {
  AppSpacing._();

  /// 2px micro nudge.
  static const double xxs = 2;

  /// 4px icon-to-text gaps, dense insets.
  static const double xs = 4;

  /// 8px default small gap.
  static const double sm = 8;

  /// 12px label-to-value and list-item gaps.
  static const double md = 12;

  /// 16px field gaps, compact card padding.
  static const double lg = 16;

  /// 20–24px screen padding (phone), section gaps.
  static const double xl = 24;

  /// 32px large section gaps.
  static const double xxl = 32;

  /// 48px hero gaps.
  static const double xxxl = 48;

  /// 64px page-level whitespace.
  static const double huge = 64;

  // -- Screen & section geometry (spec C4) -----------------------------------

  /// Horizontal screen padding on phones (min 16).
  static const double screenPaddingPhone = 20;

  /// Horizontal screen padding on tablets.
  static const double screenPaddingTablet = 24;

  /// Horizontal screen padding on desktop.
  static const double screenPaddingDesktop = 32;

  /// Standard card inner padding.
  static const double cardPadding = 20;

  /// Compact card inner padding.
  static const double cardPaddingCompact = 16;

  /// Hero card inner padding.
  static const double cardPaddingHero = 24;

  /// Gap between cards / sections.
  static const double sectionGap = 24;

  /// Gap between list items.
  static const double listGap = 12;

  /// Gap between a label and its value.
  static const double labelValueGap = 4;

  /// Gap between form fields / form groups.
  static const double fieldGap = 16;
  static const double fieldGroupGap = 24;

  /// Bottom scroll padding + safe area (+80 with overlapping FAB/bar).
  static const double scrollBottom = 24;

  // -- EdgeInsets helpers -----------------------------------------------------

  static const EdgeInsets screenPaddingAll =
      EdgeInsets.symmetric(horizontal: screenPaddingPhone);

  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);

  static const EdgeInsets cardPaddingCompactAll =
      EdgeInsets.all(cardPaddingCompact);
}
