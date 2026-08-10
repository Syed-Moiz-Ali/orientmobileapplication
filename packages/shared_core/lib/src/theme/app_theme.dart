import 'package:flutter/material.dart';
import 'package:shared_core/src/branding/brand_config.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light(BrandConfig brand) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brand.buttonColor,
      primary: brand.buttonColor,
      surface: AppColors.surface,
      surfaceContainerLow: AppColors.surfaceAlt,
      outline: AppColors.border,
      outlineVariant: AppColors.borderMd,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.text3,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: AppTypography.textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          // Fixed width issue: Size(0, 52) instead of Size.fromHeight(52)
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.rajdhaniButton(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          // Fixed width issue: Size(0, 52) instead of Size.fromHeight(52)
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.rajdhaniButton(color: AppColors.textPrimary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.rajdhaniButton(color: brand.buttonColor),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: brand.buttonColor, width: 2)),
        hintStyle: AppTextStyles.rajdhaniLabel(color: AppColors.text4),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand.buttonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bg,
        elevation: 0,
        selectedItemColor: brand.buttonColor,
        unselectedItemColor: AppColors.text4,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: brand.buttonColor,
        unselectedLabelColor: AppColors.text3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: brand.buttonColor, width: 2)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: brand.buttonColor.withValues(alpha: 0.08),
        selectedColor: brand.buttonColor,
        disabledColor: AppColors.surfaceAlt,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        labelStyle: AppTextStyles.rajdhaniLabel(color: brand.buttonColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  static ThemeData dark(BrandConfig brand) {
    const darkBg = Color(0xFF0B0F17);
    const darkSurface = Color(0xFF161E2E);
    const darkBorder = Color(0xFF1E293B);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: brand.buttonColor,
      primary: brand.buttonColor,
      surface: darkSurface,
      outline: darkBorder,
      onSurface: const Color(0xFFF8FAFC),
      onSurfaceVariant: AppColors.text4,
      brightness: Brightness.dark,
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      textTheme: AppTypography.textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.rajdhaniTitle(color: colorScheme.onSurface),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          // Fixed width issue: Size(0, 52) instead of Size.fromHeight(52)
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.rajdhaniButton(color: Colors.white),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          // Fixed width issue: Size(0, 52) instead of Size.fromHeight(52)
          minimumSize: const Size(0, 52),
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.rajdhaniButton(color: colorScheme.onSurface),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: const UnderlineInputBorder(borderSide: BorderSide(color: darkBorder)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: darkBorder)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: brand.buttonColor, width: 2)),
        hintStyle: AppTextStyles.rajdhaniLabel(color: AppColors.text4),
      ),

      // P3 (audit): dark() was missing the component themes light() defines —
      // dark-mode screens rendered default M3 widgets that clashed with the
      // brand. These were added for parity.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand.buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.rajdhaniButton(color: brand.buttonColor),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand.buttonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1, space: 1),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        elevation: 0,
        selectedItemColor: brand.buttonColor,
        unselectedItemColor: AppColors.text4,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: brand.buttonColor,
        unselectedLabelColor: AppColors.text4,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: brand.buttonColor, width: 2)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: brand.buttonColor.withValues(alpha: 0.15),
        selectedColor: brand.buttonColor,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        labelStyle: AppTextStyles.rajdhaniLabel(color: Colors.white),
      ),
    );
  }
}
