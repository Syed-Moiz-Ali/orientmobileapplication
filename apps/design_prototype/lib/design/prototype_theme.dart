// PROVISIONAL — do not ship; codified into `shared_core` in Phase 01.
//
// Locale-aware typography (spec §3) and Material 3 themes built exclusively
// from `provisional_tokens.dart`.
import 'package:flutter/material.dart';

import 'provisional_tokens.dart';

/// Font families bundled with the prototype.
///
/// Latin : Plus Jakarta Sans (same file the workspace already bundles).
/// Arabic: IBM Plex Sans Arabic 400/500/600/700 (SIL OFL), with the documented
/// fallback chain `IBM Plex Sans Arabic → Noto Sans Arabic → system`.
abstract final class ProtoFonts {
  ProtoFonts._();
  static const latin = 'PlusJakartaSans';
  static const arabic = 'IBMPlexSansArabic';
  static const arabicFallback = <String>['Noto Sans Arabic', 'sans-serif'];
}

/// Custom design roles from spec §3.2 that Material's TextTheme does not name.
@immutable
class ProtoTextStyles extends ThemeExtension<ProtoTextStyles> {
  final TextStyle displaySmall;
  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle bodyStrong;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle eyebrow;
  final TextStyle metadata;
  final TextStyle caption;
  final TextStyle tableHeader;
  final TextStyle metric;
  final TextStyle button;
  final TextStyle mono;
  final TextStyle monoStrong;

  const ProtoTextStyles({
    required this.displaySmall,
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.bodyStrong,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.eyebrow,
    required this.metadata,
    required this.caption,
    required this.tableHeader,
    required this.metric,
    required this.button,
    required this.mono,
    required this.monoStrong,
  });

  @override
  ProtoTextStyles copyWith({
    TextStyle? displaySmall,
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? bodyStrong,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? eyebrow,
    TextStyle? metadata,
    TextStyle? caption,
    TextStyle? tableHeader,
    TextStyle? metric,
    TextStyle? button,
    TextStyle? mono,
    TextStyle? monoStrong,
  }) {
    return ProtoTextStyles(
      displaySmall: displaySmall ?? this.displaySmall,
      pageTitle: pageTitle ?? this.pageTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardTitle: cardTitle ?? this.cardTitle,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      eyebrow: eyebrow ?? this.eyebrow,
      metadata: metadata ?? this.metadata,
      caption: caption ?? this.caption,
      tableHeader: tableHeader ?? this.tableHeader,
      metric: metric ?? this.metric,
      button: button ?? this.button,
      mono: mono ?? this.mono,
      monoStrong: monoStrong ?? this.monoStrong,
    );
  }

  @override
  ProtoTextStyles lerp(ThemeExtension<ProtoTextStyles>? other, double t) {
    if (other is! ProtoTextStyles) return this;
    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return ProtoTextStyles(
      displaySmall: s(displaySmall, other.displaySmall),
      pageTitle: s(pageTitle, other.pageTitle),
      sectionTitle: s(sectionTitle, other.sectionTitle),
      cardTitle: s(cardTitle, other.cardTitle),
      bodyStrong: s(bodyStrong, other.bodyStrong),
      body: s(body, other.body),
      bodySmall: s(bodySmall, other.bodySmall),
      label: s(label, other.label),
      eyebrow: s(eyebrow, other.eyebrow),
      metadata: s(metadata, other.metadata),
      caption: s(caption, other.caption),
      tableHeader: s(tableHeader, other.tableHeader),
      metric: s(metric, other.metric),
      button: s(button, other.button),
      mono: s(mono, other.mono),
      monoStrong: s(monoStrong, other.monoStrong),
    );
  }
}

extension ProtoTextStylesContext on BuildContext {
  ProtoTextStyles get types =>
      Theme.of(this).extension<ProtoTextStyles>() ?? ProtoTypography.build(arabic: false);
}

/// Builds the full type system for a locale.
abstract final class ProtoTypography {
  ProtoTypography._();

  /// Arabic line-height multiplier (spec §3.3): ≈1.05× the Latin value.
  static const double _arScale = 1.05;

  static TextStyle _role({
    required bool arabic,
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    bool tabular = false,
    bool latinFamilyOnly = false,
  }) {
    final family = arabic && !latinFamilyOnly ? ProtoFonts.arabic : ProtoFonts.latin;
    return TextStyle(
      fontFamily: family,
      fontFamilyFallback: arabic && !latinFamilyOnly ? ProtoFonts.arabicFallback : null,
      fontSize: size,
      fontWeight: weight,
      // Variable-font safety: the bundled Plus Jakarta Sans is a variable file;
      // explicit wght variation guarantees the requested weight renders
      // identically in goldens. Ignored by static Arabic font files.
      fontVariations: latinFamilyOnly || !arabic
          ? [FontVariation('wght', weight.value.toDouble())]
          : null,
      height: arabic && height != null ? height * _arScale : height,
      letterSpacing: arabic ? 0 : letterSpacing,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  static ProtoTextStyles build({required bool arabic}) {
    return ProtoTextStyles(
      displaySmall: _role(arabic: arabic, size: 22, weight: FontWeight.w700, height: 1.2),
      pageTitle: _role(arabic: arabic, size: 22, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.2),
      sectionTitle: _role(arabic: arabic, size: 18, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.1),
      cardTitle: _role(arabic: arabic, size: 15, weight: FontWeight.w600, height: 1.3),
      bodyStrong: _role(arabic: arabic, size: 14, weight: FontWeight.w600, height: 1.4),
      body: _role(arabic: arabic, size: 14, weight: FontWeight.w400, height: 1.45),
      bodySmall: _role(arabic: arabic, size: 13, weight: FontWeight.w400, height: 1.45),
      label: _role(arabic: arabic, size: 13, weight: FontWeight.w600, height: 1.3),
      eyebrow: _role(arabic: arabic, size: 11, weight: FontWeight.w700, height: 1.3, letterSpacing: 0.8),
      metadata: _role(arabic: arabic, size: 12, weight: FontWeight.w500, height: 1.3),
      caption: _role(arabic: arabic, size: 12, weight: FontWeight.w400, height: 1.35),
      tableHeader: _role(arabic: arabic, size: 12, weight: FontWeight.w700, height: 1.2),
      metric: _role(arabic: arabic, size: 26, weight: FontWeight.w800, height: 1.1, letterSpacing: -0.4, tabular: true),
      button: _role(arabic: arabic, size: 14, weight: FontWeight.w600, height: 1.2),
      mono: _role(arabic: arabic, size: 13, weight: FontWeight.w600, height: 1.35, tabular: true, latinFamilyOnly: true),
      monoStrong: _role(arabic: arabic, size: 13, weight: FontWeight.w800, height: 1.35, tabular: true, latinFamilyOnly: true),
    );
  }

  /// Material TextTheme mapped onto the same scale so stock Material widgets
  /// stay inside the design language.
  static TextTheme textTheme({required bool arabic}) {
    return TextTheme(
      displayLarge: _role(arabic: arabic, size: 34, weight: FontWeight.w800, height: 1.12, letterSpacing: -0.6),
      displayMedium: _role(arabic: arabic, size: 28, weight: FontWeight.w700, height: 1.15, letterSpacing: -0.4),
      displaySmall: _role(arabic: arabic, size: 22, weight: FontWeight.w700, height: 1.2),
      headlineMedium: _role(arabic: arabic, size: 22, weight: FontWeight.w700, height: 1.2),
      headlineSmall: _role(arabic: arabic, size: 18, weight: FontWeight.w700, height: 1.25),
      titleLarge: _role(arabic: arabic, size: 18, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.1),
      titleMedium: _role(arabic: arabic, size: 15, weight: FontWeight.w600, height: 1.3),
      titleSmall: _role(arabic: arabic, size: 14, weight: FontWeight.w600, height: 1.3),
      bodyLarge: _role(arabic: arabic, size: 15, weight: FontWeight.w400, height: 1.45),
      bodyMedium: _role(arabic: arabic, size: 14, weight: FontWeight.w400, height: 1.45),
      bodySmall: _role(arabic: arabic, size: 13, weight: FontWeight.w400, height: 1.45),
      labelLarge: _role(arabic: arabic, size: 14, weight: FontWeight.w600, height: 1.25),
      labelMedium: _role(arabic: arabic, size: 13, weight: FontWeight.w600, height: 1.3),
      labelSmall: _role(arabic: arabic, size: 11, weight: FontWeight.w700, height: 1.3),
    );
  }
}

/// Material 3 themes assembled from the provisional tokens.
abstract final class PrototypeTheme {
  PrototypeTheme._();

  static ThemeData light({required bool arabic}) =>
      _build(ProtoPalette.light, arabic: arabic);

  static ThemeData dark({required bool arabic}) =>
      _build(ProtoPalette.dark, arabic: arabic);

  static ThemeData _build(ProtoPalette p, {required bool arabic}) {
    final types = ProtoTypography.build(arabic: arabic);
    final textTheme = ProtoTypography.textTheme(arabic: arabic);

    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primarySubtle,
      onPrimaryContainer: p.isDark ? const Color(0xFFD5DEFF) : const Color(0xFF1B2C6B),
      secondary: p.info,
      onSecondary: Colors.white,
      secondaryContainer: p.infoSubtle,
      onSecondaryContainer: p.isDark ? const Color(0xFFE4E0FF) : const Color(0xFF26205E),
      tertiary: p.success,
      onTertiary: Colors.white,
      tertiaryContainer: p.successSubtle,
      onTertiaryContainer: p.isDark ? const Color(0xFFC9F2E1) : const Color(0xFF0B3D2B),
      error: p.danger,
      onError: Colors.white,
      errorContainer: p.dangerSubtle,
      onErrorContainer: p.isDark ? const Color(0xFFFFD9DE) : const Color(0xFF5F1220),
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceSunken,
      surfaceContainerHigh: p.surfaceSunken,
      surfaceContainer: p.surfaceSubtle,
      surfaceContainerLow: p.surfaceSubtle,
      surfaceContainerLowest: p.canvas,
      onSurfaceVariant: p.textMuted,
      outline: p.borderStrong,
      outlineVariant: p.borderDefault,
      shadow: const Color(0xFF111827),
      scrim: p.scrim,
      inverseSurface: p.navy,
      onInverseSurface: p.textInverse,
      inversePrimary: p.primaryBorder,
      surfaceTint: Colors.transparent,
    );

    final isDark = p.isDark;
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ProtoRadius.button),
    );

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(ProtoRadius.input),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      fontFamily: arabic ? ProtoFonts.arabic : ProtoFonts.latin,
      fontFamilyFallback: arabic ? ProtoFonts.arabicFallback : null,
      textTheme: textTheme,
      extensions: [p, types],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.borderDefault, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: types.pageTitle.copyWith(color: p.textPrimary),
        iconTheme: IconThemeData(color: p.textSecondary, size: 22),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, ProtoSpace.touchTarget)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: ProtoSpace.s20, vertical: ProtoSpace.s12),
          ),
          shape: WidgetStatePropertyAll(controlShape),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? p.surfaceSunken : p.primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? p.textDisabled : Colors.white,
          ),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered) ? p.primaryHover.withValues(alpha: 0.9) : null,
          ),
          textStyle: WidgetStatePropertyAll(types.button),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, ProtoSpace.touchTarget)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: ProtoSpace.s20, vertical: ProtoSpace.s12),
          ),
          shape: WidgetStatePropertyAll(controlShape),
          foregroundColor: WidgetStatePropertyAll(p.textPrimary),
          side: WidgetStatePropertyAll(BorderSide(color: p.borderStrong)),
          overlayColor: WidgetStatePropertyAll(p.hover),
          textStyle: WidgetStatePropertyAll(types.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s10),
          ),
          foregroundColor: WidgetStatePropertyAll(p.primary),
          overlayColor: WidgetStatePropertyAll(p.primarySubtle),
          textStyle: WidgetStatePropertyAll(types.button.copyWith(color: p.primary)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(p.textSecondary),
          overlayColor: WidgetStatePropertyAll(p.hover),
          minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceSubtle : p.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ProtoSpace.s14,
          vertical: ProtoSpace.s14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.textDisabled) ?? TextStyle(color: p.textDisabled),
        labelStyle: types.label.copyWith(color: p.textSecondary),
        floatingLabelStyle: types.label.copyWith(color: p.primary),
        helperStyle: types.caption.copyWith(color: p.textMuted),
        errorStyle: types.caption.copyWith(color: p.danger, fontWeight: FontWeight.w600),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
        border: border(p.borderDefault),
        enabledBorder: border(p.borderDefault),
        disabledBorder: border(p.borderDefault.withValues(alpha: 0.6)),
        focusedBorder: border(p.primary, 1.5),
        errorBorder: border(p.danger, 1.2),
        focusedErrorBorder: border(p.danger, 1.5),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? p.surfaceSubtle : p.surface,
        selectedColor: p.primarySubtle,
        disabledColor: p.surfaceSunken,
        side: BorderSide(color: p.borderDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.pill)),
        labelStyle: types.label.copyWith(color: p.textSecondary),
        secondaryLabelStyle: types.label.copyWith(color: p.primary),
        padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s12, vertical: ProtoSpace.s6),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.dialog)),
        titleTextStyle: types.sectionTitle.copyWith(color: p.textPrimary),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(ProtoRadius.sheet)),
        ),
        dragHandleColor: p.borderStrong,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.navy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.textInverse),
        actionTextColor: const Color(0xFF9DB4FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.control)),
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : p.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? p.primary : p.surfaceSunken,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.transparent : p.borderStrong,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.selected,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => types.label.copyWith(
            fontSize: 12,
            color: states.contains(WidgetState.selected) ? p.primary : p.textMuted,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected) ? p.primary : p.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.selected,
        selectedIconTheme: IconThemeData(color: p.primary, size: 24),
        unselectedIconTheme: IconThemeData(color: p.textMuted, size: 24),
        selectedLabelTextStyle: types.label.copyWith(color: p.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: types.label.copyWith(color: p.textMuted, fontWeight: FontWeight.w500),
        useIndicator: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ProtoRadius.card),
          side: BorderSide(color: p.borderDefault),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: p.textPrimary),
        elevation: 8,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.navy,
          borderRadius: BorderRadius.circular(ProtoRadius.sm),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: p.textInverse),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceSunken,
        circularTrackColor: p.surfaceSunken,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textMuted,
        textColor: p.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.control)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? p.primary : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? Colors.white : p.textSecondary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: p.borderDefault)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(ProtoRadius.control)),
          ),
          textStyle: WidgetStatePropertyAll(types.label),
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.22),
        selectionHandleColor: p.primary,
      ),
    );
  }
}
