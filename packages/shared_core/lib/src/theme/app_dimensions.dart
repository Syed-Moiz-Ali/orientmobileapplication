import 'package:flutter/material.dart';

/// Dimensional, layout, and elevation tokens for the ORIENT design system.
///
/// Follows a disciplined 4-pt grid rhythm with distinct radii for controls,
/// inputs, cards, panels, dialogs, and sheets.
class AppDimensions {
  AppDimensions._();

  // ---------------------------------------------------------------------------
  // Semantic Radii
  // ---------------------------------------------------------------------------
  /// Extra small controls, internal badges, micro-indicators (4px).
  static const double radiusXs = 4;

  /// Small tags, filter chips, compact record badges (6px).
  static const double radiusSm = 6;

  /// Standard controls, small button toggles, segmented buttons (8px).
  static const double radiusControl = 8;

  /// Text form fields and search inputs (10px).
  static const double radiusInput = 10;

  /// Primary, secondary, and action buttons (10px).
  static const double radiusButton = 10;

  /// Standard content cards and list tiles (12px).
  static const double radiusCard = 12;

  /// High-emphasis panels, bento modules, command headers (16px).
  static const double radiusPanel = 16;

  /// Modal confirmation dialogs and alert boxes (18px).
  static const double radiusDialog = 18;

  /// Bottom sheets and persistent action drawers (22px).
  static const double radiusSheet = 22;

  /// Fully rounded pills, status badges, capsule indicators (999px).
  static const double radiusPill = 999;

  // ---------------------------------------------------------------------------
  // Standardized Spacing Scale
  // ---------------------------------------------------------------------------
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s64 = 64;

  // ---------------------------------------------------------------------------
  // Semantic Layout Spacing Helpers
  // ---------------------------------------------------------------------------
  /// Outer screen gutters by device class.
  static const double screenGutterCompact = 16;
  static const double screenGutterMedium = 24;
  static const double screenGutterExpanded = 32;

  /// Vertical gap between major page sections.
  static const double sectionGap = 24;

  /// Gap between adjacent cards in a grid or stack.
  static const double cardGap = 16;

  /// Compact internal card padding (12px) for dense data rows.
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(s12);

  /// Standard internal card padding (16px).
  static const EdgeInsets cardPaddingRegular = EdgeInsets.all(s16);

  /// Spacious internal card padding (20px) for hero and summary panels.
  static const EdgeInsets cardPaddingSpacious = EdgeInsets.all(s20);

  // ---------------------------------------------------------------------------
  // Shadow & Elevation System (Subtle, Restrained, No Colored Glow)
  // ---------------------------------------------------------------------------
  /// Subtle boundary shadow for surfaces and top/bottom bars.
  static const List<BoxShadow> shadowSurface = [
    BoxShadow(color: Color(0x08111827), blurRadius: 6, offset: Offset(0, 2)),
  ];

  /// Soft elevation shadow for standard raised cards.
  static const List<BoxShadow> shadowCard = [
    BoxShadow(color: Color(0x0C111827), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Elevation shadow for modal dialogs and bottom sheets.
  static const List<BoxShadow> shadowModal = [
    BoxShadow(color: Color(0x1F111827), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Subtle dark elevation shadow for dark navy high-emphasis panels.
  static const List<BoxShadow> shadowNavy = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  // ---------------------------------------------------------------------------
  // Optical Icon Sizing
  // ---------------------------------------------------------------------------
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ---------------------------------------------------------------------------
  // Touch Targets & Viewport Caps
  // ---------------------------------------------------------------------------
  /// Minimum touch target size according to enterprise accessibility rules.
  static const double touchTarget = 48;

  static const double contentNarrow = 560;
  static const double contentStandard = 1180;
  static const double contentWide = 1320;

  // ---------------------------------------------------------------------------
  // Backward-Compatible Numeric Radii Aliases
  // ---------------------------------------------------------------------------
  static const double r2 = 2;
  static const double r3 = 3;
  static const double r4 = 4;
  static const double r5 = 5;
  static const double r6 = 6;
  static const double r7 = 7;
  static const double r8 = 8;
  static const double r9 = 9;
  static const double r10 = 10;
  static const double r11 = 11;
  static const double r12 = 12;
  static const double r13 = 13;
  static const double r14 = 14;
  static const double r15 = 15;
  static const double r16 = 16;
  static const double r18 = 18;
  static const double r20 = 20;
  static const double r22 = 22;
  static const double r24 = 24;
  static const double r28 = 28;
  static const double rPill = 999;
}
