import 'package:flutter/material.dart';
import 'package:shared_core/src/branding/brand_config.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light(BrandConfig brand) {
    final primary = brand.buttonColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF2F6FED),
      onSecondary: Colors.white,
      tertiary: const Color(0xFF00A896),
      onTertiary: Colors.white,
      error: AppColors.danger,
      surface: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF8FAFC),
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      outline: const Color(0xFFE2E8F0),
      outlineVariant: const Color(0xFFCBD5E1),
      onSurface: const Color(0xFF111827),
      onSurfaceVariant: const Color(0xFF64748B),
      shadow: Colors.black,
    );

    return _buildTheme(
      brand: brand,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      inputFillColor: colorScheme.surfaceContainerLow,
      appBarBackgroundColor: const Color(0xFFF8FAFC),
    );
  }

  static ThemeData dark(BrandConfig brand) {
    final primary = brand.buttonColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      secondary: const Color(0xFFFFD166),
      onSecondary: const Color(0xFF171100),
      tertiary: const Color(0xFF5DE2D1),
      onTertiary: const Color(0xFF001B18),
      error: const Color(0xFFFF6B7A),
      surface: const Color(0xFF111722),
      surfaceContainerLow: const Color(0xFF0F141D),
      surfaceContainerHighest: const Color(0xFF192231),
      outline: const Color(0xFF2A3444),
      outlineVariant: const Color(0xFF344155),
      onSurface: const Color(0xFFEAF0FF),
      onSurfaceVariant: const Color(0xFFAAB5C8),
      shadow: Colors.black,
    );

    return _buildTheme(
      brand: brand,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF070A10),
      inputFillColor: const Color(0xFF0F141D),
      appBarBackgroundColor: const Color(0xFF070A10),
    );
  }

  static ThemeData _buildTheme({
    required BrandConfig brand,
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color inputFillColor,
    required Color appBarBackgroundColor,
  }) {
    final primary = brand.buttonColor;
    final onPrimary = colorScheme.onPrimary;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      canvasColor: scaffoldBackgroundColor,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: primary.withValues(alpha: 0.16),
      hoverColor: primary.withValues(alpha: 0.06),
      highlightColor: primary.withValues(alpha: 0.08),

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title(color: colorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button(color: onPrimary),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTextStyles.button(color: onPrimary),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button(color: colorScheme.onSurface),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button(color: primary),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.body(color: colorScheme.onSurfaceVariant),
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
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusDialog),
        ),
        titleTextStyle: AppTextStyles.title(color: colorScheme.onSurface),
        contentTextStyle: AppTextStyles.body(
          color: colorScheme.onSurfaceVariant,
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
          );
        }),
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.12),
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: AppTextStyles.label(color: primary),
        unselectedLabelTextStyle: AppTextStyles.label(
          color: colorScheme.onSurfaceVariant,
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
        backgroundColor: primary.withValues(alpha: 0.10),
        selectedColor: primary,
        disabledColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        ),
        labelStyle: AppTextStyles.subtitle(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.body(
          color: colorScheme.onInverseSurface,
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
    );
  }
}
