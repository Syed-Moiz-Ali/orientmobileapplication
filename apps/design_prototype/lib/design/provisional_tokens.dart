// PROVISIONAL — do not ship; codified into `shared_core` in Phase 01.
//
// This file mirrors the values of `phases/00_DESIGN_SYSTEM_SPEC.md` §2–§4
// (colors including a full dark parity map, type scale, spacing, radii,
// shadows, motion, chart palette) so the Phase 00 prototype can render the
// 2026 direction with zero production dependencies.
//
// The spec remains the authority. Any value changed during visual review is
// edited HERE first and recorded in `phases/00_VISUAL_DIRECTION.md`.
import 'package:flutter/material.dart';

/// Semantic color tokens for one brightness. Exposed through ThemeData via
/// [ProtoPalette] as a ThemeExtension so screens never hard-code a hex value.
@immutable
class ProtoPalette extends ThemeExtension<ProtoPalette> {
  final Brightness brightness;

  // Canvas & surfaces
  final Color canvas;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceSunken;
  final Color surfaceRaised;
  final Color navy;
  final Color navyRaised;
  final Color onNavySecondary;

  // Inks
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textInverse;

  // Borders
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  // Primary
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color primarySubtle;
  final Color primaryBorder;
  final Color selected;
  final Color hover;
  final Color focus;

  // Semantics
  final Color success;
  final Color successSubtle;
  final Color successBorder;
  final Color warning;
  final Color warningSubtle;
  final Color warningBorder;
  final Color danger;
  final Color dangerSubtle;
  final Color dangerBorder;
  final Color info;
  final Color infoSubtle;
  final Color infoBorder;

  final Color scrim;

  const ProtoPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceSunken,
    required this.surfaceRaised,
    required this.navy,
    required this.navyRaised,
    required this.onNavySecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primarySubtle,
    required this.primaryBorder,
    required this.selected,
    required this.hover,
    required this.focus,
    required this.success,
    required this.successSubtle,
    required this.successBorder,
    required this.warning,
    required this.warningSubtle,
    required this.warningBorder,
    required this.danger,
    required this.dangerSubtle,
    required this.dangerBorder,
    required this.info,
    required this.infoSubtle,
    required this.infoBorder,
    required this.scrim,
  });

  static const light = ProtoPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF5F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF8FAFC),
    surfaceSunken: Color(0xFFF0F3F8),
    surfaceRaised: Color(0xFFFFFFFF),
    navy: Color(0xFF14213D),
    navyRaised: Color(0xFF1C2C50),
    onNavySecondary: Color(0xFFAAB5C8),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF394150),
    textMuted: Color(0xFF677182),
    textDisabled: Color(0xFF9AA4B2),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFF0F3F8),
    borderDefault: Color(0xFFE5EAF1),
    borderStrong: Color(0xFFCCD6E2),
    primary: Color(0xFF3157D5),
    primaryHover: Color(0xFF2848B8),
    primaryPressed: Color(0xFF203B9E),
    primarySubtle: Color(0xFFEEF3FF),
    primaryBorder: Color(0xFFC8D6FF),
    selected: Color(0xFFE8EEFF),
    hover: Color(0xFFF0F4FF),
    focus: Color(0xFF3157D5),
    success: Color(0xFF0F8B5F),
    successSubtle: Color(0xFFE9F7F1),
    successBorder: Color(0xFFB9E5D0),
    warning: Color(0xFFE09A1F),
    warningSubtle: Color(0xFFFFF8E8),
    warningBorder: Color(0xFFF3D18B),
    danger: Color(0xFFD92D43),
    dangerSubtle: Color(0xFFFFF1F3),
    dangerBorder: Color(0xFFF8C7CE),
    info: Color(0xFF6D5DF6),
    infoSubtle: Color(0xFFF1F0FF),
    infoBorder: Color(0xFFD9D5FF),
    scrim: Color(0x6B0B1526),
  );

  /// Dark parity map (spec §2.1 promises Phase 01 adds this; the prototype
  /// defines a proposal so dark mode can be reviewed now).
  static const dark = ProtoPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0C1120),
    surface: Color(0xFF151C2E),
    surfaceSubtle: Color(0xFF1A2236),
    surfaceSunken: Color(0xFF101627),
    surfaceRaised: Color(0xFF1B2439),
    navy: Color(0xFF14213D),
    navyRaised: Color(0xFF1C2C50),
    onNavySecondary: Color(0xFFAAB5C8),
    textPrimary: Color(0xFFF2F5FB),
    textSecondary: Color(0xFFC6CEDF),
    textMuted: Color(0xFF8F9AB0),
    textDisabled: Color(0xFF5E6981),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFF202A40),
    borderDefault: Color(0xFF2A354D),
    borderStrong: Color(0xFF3E4B66),
    primary: Color(0xFF6E8BFF),
    primaryHover: Color(0xFF84A0FF),
    primaryPressed: Color(0xFF5C79F0),
    primarySubtle: Color(0xFF1B2440),
    primaryBorder: Color(0xFF32406E),
    selected: Color(0xFF1D2A4D),
    hover: Color(0xFF1A2440),
    focus: Color(0xFF84A0FF),
    success: Color(0xFF3DC795),
    successSubtle: Color(0xFF11291F),
    successBorder: Color(0xFF1E4A36),
    warning: Color(0xFFF0B34C),
    warningSubtle: Color(0xFF2C2311),
    warningBorder: Color(0xFF4D3D18),
    danger: Color(0xFFF1707F),
    dangerSubtle: Color(0xFF31151B),
    dangerBorder: Color(0xFF55222B),
    info: Color(0xFF9B8DFF),
    infoSubtle: Color(0xFF1D1A3C),
    infoBorder: Color(0xFF37316E),
    scrim: Color(0xCC0B1526),
  );

  /// Chart series encoding shared by every chart in the suite (§2.1 Phase 01
  /// note): derived from primary / accent / info / warning / success / navy.
  static const List<Color> chartSeries = [
    Color(0xFF3157D5),
    Color(0xFF0FA97C),
    Color(0xFF6D5DF6),
    Color(0xFFE09A1F),
    Color(0xFF0F8B5F),
    Color(0xFF14213D),
  ];

  static const List<Color> chartSeriesDark = [
    Color(0xFF6E8BFF),
    Color(0xFF35C79A),
    Color(0xFF9B8DFF),
    Color(0xFFF0B34C),
    Color(0xFF3DC795),
    Color(0xFF93A7D8),
  ];

  bool get isDark => brightness == Brightness.dark;

  @override
  ProtoPalette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceSunken,
    Color? surfaceRaised,
    Color? navy,
    Color? navyRaised,
    Color? onNavySecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? textInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? primarySubtle,
    Color? primaryBorder,
    Color? selected,
    Color? hover,
    Color? focus,
    Color? success,
    Color? successSubtle,
    Color? successBorder,
    Color? warning,
    Color? warningSubtle,
    Color? warningBorder,
    Color? danger,
    Color? dangerSubtle,
    Color? dangerBorder,
    Color? info,
    Color? infoSubtle,
    Color? infoBorder,
    Color? scrim,
  }) {
    return ProtoPalette(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      navy: navy ?? this.navy,
      navyRaised: navyRaised ?? this.navyRaised,
      onNavySecondary: onNavySecondary ?? this.onNavySecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      primaryBorder: primaryBorder ?? this.primaryBorder,
      selected: selected ?? this.selected,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      success: success ?? this.success,
      successSubtle: successSubtle ?? this.successSubtle,
      successBorder: successBorder ?? this.successBorder,
      warning: warning ?? this.warning,
      warningSubtle: warningSubtle ?? this.warningSubtle,
      warningBorder: warningBorder ?? this.warningBorder,
      danger: danger ?? this.danger,
      dangerSubtle: dangerSubtle ?? this.dangerSubtle,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      info: info ?? this.info,
      infoSubtle: infoSubtle ?? this.infoSubtle,
      infoBorder: infoBorder ?? this.infoBorder,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  ProtoPalette lerp(ThemeExtension<ProtoPalette>? other, double t) {
    if (other is! ProtoPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return ProtoPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: c(canvas, other.canvas),
      surface: c(surface, other.surface),
      surfaceSubtle: c(surfaceSubtle, other.surfaceSubtle),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      navy: c(navy, other.navy),
      navyRaised: c(navyRaised, other.navyRaised),
      onNavySecondary: c(onNavySecondary, other.onNavySecondary),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      textDisabled: c(textDisabled, other.textDisabled),
      textInverse: c(textInverse, other.textInverse),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderDefault: c(borderDefault, other.borderDefault),
      borderStrong: c(borderStrong, other.borderStrong),
      primary: c(primary, other.primary),
      primaryHover: c(primaryHover, other.primaryHover),
      primaryPressed: c(primaryPressed, other.primaryPressed),
      primarySubtle: c(primarySubtle, other.primarySubtle),
      primaryBorder: c(primaryBorder, other.primaryBorder),
      selected: c(selected, other.selected),
      hover: c(hover, other.hover),
      focus: c(focus, other.focus),
      success: c(success, other.success),
      successSubtle: c(successSubtle, other.successSubtle),
      successBorder: c(successBorder, other.successBorder),
      warning: c(warning, other.warning),
      warningSubtle: c(warningSubtle, other.warningSubtle),
      warningBorder: c(warningBorder, other.warningBorder),
      danger: c(danger, other.danger),
      dangerSubtle: c(dangerSubtle, other.dangerSubtle),
      dangerBorder: c(dangerBorder, other.dangerBorder),
      info: c(info, other.info),
      infoSubtle: c(infoSubtle, other.infoSubtle),
      infoBorder: c(infoBorder, other.infoBorder),
      scrim: c(scrim, other.scrim),
    );
  }
}

/// Convenience accessor: `context.palette.primary`.
extension ProtoPaletteContext on BuildContext {
  ProtoPalette get palette =>
      Theme.of(this).extension<ProtoPalette>() ?? ProtoPalette.light;
}

/// Spacing / radii / elevation / motion tokens (spec §4, §11).
abstract final class ProtoSpace {
  ProtoSpace._();
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

  static const double gutterCompact = 16;
  static const double gutterMedium = 24;
  static const double gutterExpanded = 32;
  static const double sectionGap = 24;
  static const double cardGap = 16;

  static const double contentStandard = 1180;
  static const double contentWide = 1320;
  static const double formMaxWidth = 460;

  static const double touchTarget = 48;

  /// Bottom padding that clears the bottom navigation bar (spec §13).
  static const double bottomNavClearance = 96;

  /// Bottom padding that clears a sticky action bar (spec §13).
  static const double actionBarClearance = 120;
}

abstract final class ProtoRadius {
  ProtoRadius._();
  static const double xs = 4;
  static const double sm = 6;
  static const double control = 8;
  static const double input = 10;
  static const double button = 10;
  static const double card = 12;
  static const double panel = 16;
  static const double dialog = 18;
  static const double sheet = 22;
  static const double pill = 999;
}

abstract final class ProtoElevation {
  ProtoElevation._();
  static const List<BoxShadow> surface = [
    BoxShadow(color: Color(0x08111827), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0C111827), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1F111827), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> navy = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}

abstract final class ProtoMotion {
  ProtoMotion._();
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 280);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standardCurve = Curves.easeInOutCubic;
}

/// Window classes (spec §5): decisions come from available width only.
enum ProtoWindowClass { compact, medium, expanded, large }

extension ProtoWindowClassX on ProtoWindowClass {
  bool get isCompact => this == ProtoWindowClass.compact;
  bool get isMedium => this == ProtoWindowClass.medium;
  bool get isExpanded => this == ProtoWindowClass.expanded;
  bool get isLarge => this == ProtoWindowClass.large;
  bool get isDesktop => this == ProtoWindowClass.expanded || this == ProtoWindowClass.large;

  /// compact ≤599 · medium 600–1023 · expanded 1024–1439 · large ≥1440
  static ProtoWindowClass of(double width) {
    if (width >= 1440) return ProtoWindowClass.large;
    if (width >= 1024) return ProtoWindowClass.expanded;
    if (width >= 600) return ProtoWindowClass.medium;
    return ProtoWindowClass.compact;
  }
}

extension ProtoWindowContext on BuildContext {
  ProtoWindowClass get windowClass =>
      ProtoWindowClassX.of(MediaQuery.sizeOf(this).width);

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
