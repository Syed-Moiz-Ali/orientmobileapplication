import 'package:flutter/material.dart';
import 'package:shared_core/src/branding/brand_config.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_density.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_interaction_states.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_tokens.dart';

abstract final class AppTheme {
  AppTheme._();

  /// The single authorized primary authority (Concept A §1.1).
  ///
  /// Light primary is always `#215FE6`; [BrandConfig] is logo-only and never
  /// supplies a color. A guard test fails the build if this ever diverges.
  static const Color authorizedPrimaryLight = Color(0xFF215FE6);

  /// Light theme. Pass [locale] so the typography follows the active language
  /// (Arabic → IBM Plex Sans Arabic with ×1.05 line-height, V11). Latin output
  /// is byte-identical whether [locale] is null or English.
  ///
  /// [brand] supplies logo identity only; its legacy color fields are ignored.
  static ThemeData light(
    BrandConfig brand, {
    Locale? locale,
    AppDensityMode density = AppDensityMode.comfortable,
  }) {
    // Phase 01.2: [BrandConfig] is logo-only — the primary is the single
    // `#215FE6` authority below. The legacy color fields on [brand] are
    // intentionally unread (guarded by `theme_primary_guard_test.dart`).
    const primary = authorizedPrimaryLight;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: AppColors.textInverse,
      secondary: primary,
      onSecondary: AppColors.textInverse,
      tertiary: AppColors.accent,
      onTertiary: AppColors.textInverse,
      error: AppColors.danger,
      onError: AppColors.textInverse,
      surface: AppColors.surface,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.canvas,
      surfaceContainer: AppColors.surfaceAlt,
      surfaceContainerHigh: AppColors.surfaceSunken,
      surfaceContainerHighest: AppColors.surfaceSunken,
      outline: AppColors.borderDefault,
      outlineVariant: AppColors.borderStrong,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
      inverseSurface: AppColors.surfaceInverse,
      onInverseSurface: AppColors.textInverse,
      // Accent for content sitting on the inverse (navy) brand surface; the
      // raw cobalt is too dark against navy, so the lighter dark-mode primary
      // is the authorized inverse accent (Phase 05).
      inversePrimary: AppDarkColors.primary,
      shadow: Colors.black,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      semanticColors: AppSemanticColors.light,
      density: AppDensity.forMode(density),
      scaffoldBackgroundColor: AppColors.canvas,
      inputFillColor: AppColors.surface,
      appBarBackgroundColor: AppColors.canvas,
      primary: primary,
      locale: locale,
    );
  }

  /// Dark theme built on the approved Phase 01 dark parity map
  /// ([AppDarkColors] — frozen in `00_VISUAL_DIRECTION.md` §3, 2026-10-13).
  ///
  /// Dark stays opt-in (`ThemeMode.light` is the shipped default); it must
  /// compile, render and pass tests. Component themes are produced by the same
  /// builder as [light] so both brightnesses always cover the same surface.
  ///
  /// [brand] supplies logo identity only; its legacy color fields are ignored.
  static ThemeData dark(
    BrandConfig brand, {
    Locale? locale,
    AppDensityMode density = AppDensityMode.comfortable,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppDarkColors.primary,
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      // Phase 01.1 accessibility amendment: dark ink keeps normal-sized
      // button labels at WCAG AA on the bright dark primary/danger fills
      // (white was ≈3.1:1 on #6E8BFF and ≈2.9:1 on #F1707F).
      onPrimary: AppDarkColors.onPrimary,
      primaryContainer: AppDarkColors.primarySubtle,
      onPrimaryContainer: const Color(0xFFD5DEFF),
      secondary: AppDarkColors.info,
      onSecondary: AppDarkColors.textInverse,
      secondaryContainer: AppDarkColors.infoSubtle,
      onSecondaryContainer: const Color(0xFFE4E0FF),
      tertiary: AppDarkColors.success,
      onTertiary: AppDarkColors.textInverse,
      tertiaryContainer: AppDarkColors.successSubtle,
      onTertiaryContainer: const Color(0xFFC9F2E1),
      error: AppDarkColors.danger,
      onError: AppDarkColors.onError,
      errorContainer: AppDarkColors.dangerSubtle,
      onErrorContainer: const Color(0xFFFFD9DE),
      surface: AppDarkColors.surface,
      surfaceContainerLowest: AppDarkColors.canvas,
      surfaceContainerLow: AppDarkColors.surfaceSubtle,
      surfaceContainer: AppDarkColors.surfaceSubtle,
      surfaceContainerHigh: AppDarkColors.surfaceSunken,
      surfaceContainerHighest: AppDarkColors.surfaceSunken,
      outline: AppDarkColors.borderDefault,
      outlineVariant: AppDarkColors.borderStrong,
      onSurface: AppDarkColors.textPrimary,
      onSurfaceVariant: AppDarkColors.textMuted,
      inverseSurface: AppDarkColors.surfaceStrong,
      onInverseSurface: AppDarkColors.textInverse,
      inversePrimary: AppDarkColors.primary,
      shadow: Colors.black,
      scrim: AppDarkColors.overlayScrim,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      semanticColors: AppSemanticColors.dark,
      density: AppDensity.forMode(density),
      scaffoldBackgroundColor: AppDarkColors.canvas,
      inputFillColor: AppDarkColors.surfaceSubtle,
      appBarBackgroundColor: AppDarkColors.canvas,
      primary: AppDarkColors.primary,
      locale: locale,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppSemanticColors semanticColors,
    required AppDensity density,
    required Color scaffoldBackgroundColor,
    required Color inputFillColor,
    required Color appBarBackgroundColor,
    required Color primary,
    Locale? locale,
  }) {
    final onPrimary = colorScheme.onPrimary;
    final arabic = AppTypography.isArabic(locale);
    // Phase 01.2: global focus + disabled grammar. Every interactive surface
    // resolves from the semantic tokens — no widget invents its own greys.
    final focusRing = semanticColors.focusRing;
    final disabledFill = semanticColors.disabledFill;
    final disabledInk = semanticColors.disabledInk;

    // Phase-0b (additive): AppTokens rides alongside the semantic palette.
    // Component themes below are UNCHANGED (zero geometry edits in 0b).
    final tokens = colorScheme.brightness == Brightness.dark
        ? AppTokens.dark
        : AppTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[semanticColors, density, tokens],
      // Set the family at ThemeData level so every Material component,
      // overlay, route, dialog and unstyled Text inherits the same typeface.
      fontFamily: arabic ? AppFontFamilies.arabic : AppFontFamilies.app,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      canvasColor: scaffoldBackgroundColor,
      textTheme: AppTypography.forLocale(locale).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: focusRing.withValues(alpha: 0.16),
      hoverColor: primary.withValues(alpha: 0.06),
      highlightColor: primary.withValues(alpha: 0.08),
      disabledColor: disabledFill,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.pageTitle(
          color: colorScheme.onSurface,
          arabic: arabic,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              disabledBackgroundColor: disabledFill,
              disabledForegroundColor: disabledInk,
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(0, AppDimensions.touchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: AppTextStyles.button(color: onPrimary, arabic: arabic),
            ).copyWith(
              overlayColor: AppInteractionStates.overlays(primary, onPrimary),
              side: AppInteractionStates.focusRing(focusRing),
            ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: onPrimary,
              disabledBackgroundColor: disabledFill,
              disabledForegroundColor: disabledInk,
              elevation: 0,
              shadowColor: Colors.transparent,
              minimumSize: const Size(0, AppDimensions.touchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: AppTextStyles.button(color: onPrimary, arabic: arabic),
            ).copyWith(
              overlayColor: AppInteractionStates.overlays(primary, onPrimary),
              side: AppInteractionStates.focusRing(focusRing),
            ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              disabledForegroundColor: disabledInk,
              minimumSize: const Size(0, AppDimensions.touchTarget),
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: AppTextStyles.button(
                color: colorScheme.onSurface,
                arabic: arabic,
              ),
            ).copyWith(
              overlayColor: AppInteractionStates.overlays(
                colorScheme.surface,
                colorScheme.onSurface,
              ),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return BorderSide(color: semanticColors.disabledBorder);
                }
                if (states.contains(WidgetState.focused)) {
                  return BorderSide(
                    color: focusRing,
                    width: AppInteractionStates.focusRingWidth,
                  );
                }
                return BorderSide(color: colorScheme.outlineVariant);
              }),
            ),
      ),

      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: primary,
              disabledForegroundColor: disabledInk,
              minimumSize: const Size(0, AppDimensions.touchTarget),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: AppTextStyles.button(color: primary, arabic: arabic),
            ).copyWith(
              overlayColor: AppInteractionStates.overlays(
                colorScheme.surface,
                primary,
              ),
              side: AppInteractionStates.focusRing(focusRing),
            ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: disabledInk,
          minimumSize: const Size.square(AppDimensions.touchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
        ).copyWith(
          side: AppInteractionStates.focusRing(focusRing),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: focusRing, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: semanticColors.disabledBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: AppTextStyles.body(
          color: colorScheme.onSurfaceVariant,
          arabic: arabic,
        ),
        labelStyle: AppTextStyles.label(
          color: colorScheme.onSurfaceVariant,
          arabic: arabic,
        ),
        floatingLabelStyle: AppTextStyles.label(color: primary, arabic: arabic),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.body(
          color: colorScheme.onSurface,
          arabic: arabic,
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: AppTextStyles.body(
            color: colorScheme.onSurfaceVariant,
            arabic: arabic,
          ),
          labelStyle: AppTextStyles.label(
            color: colorScheme.onSurfaceVariant,
            arabic: arabic,
          ),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        textStyle: AppTextStyles.body(
          color: colorScheme.onSurface,
          arabic: arabic,
        ),
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.body(color: colorScheme.onSurface, arabic: arabic),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),

      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
          side: BorderSide(color: colorScheme.outline),
        ),
        titleTextStyle: AppTextStyles.sectionTitle(
          color: colorScheme.onSurface,
          arabic: arabic,
        ),
        contentTextStyle: AppTextStyles.body(
          color: colorScheme.onSurfaceVariant,
          arabic: arabic,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusSheet),
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.label(
            color: selected ? primary : colorScheme.onSurfaceVariant,
            arabic: arabic,
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.12),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.label(
          color: primary,
          arabic: arabic,
        ),
        unselectedLabelTextStyle: AppTextStyles.label(
          color: colorScheme.onSurfaceVariant,
          arabic: arabic,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.08),
        selectedColor: primary,
        disabledColor: disabledFill,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        labelStyle: AppTextStyles.label(color: primary, arabic: arabic),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.body(
          color: colorScheme.onInverseSurface,
          arabic: arabic,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        // Flutter 3.35 CheckboxThemeData.side is a plain BorderSide (no
        // state resolution); disabled/focus ink still resolves via the
        // checkColor/fillColor state properties below.
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledInk;
          return onPrimary;
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFill;
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledInk;
          if (states.contains(WidgetState.selected)) return onPrimary;
          return colorScheme.outlineVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return disabledFill;
          if (states.contains(WidgetState.selected)) return primary;
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return focusRing;
          }
          return Colors.transparent;
        }),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        textStyle: AppTextStyles.bodySmall(
          color: colorScheme.onInverseSurface,
          arabic: arabic,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
