import 'package:flutter/material.dart';
import 'package:shared_core/src/branding/brand_config.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(BrandConfig brand) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: brand.buttonColor,
      primary: brand.buttonColor,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: AppTypography.textTheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: brand.accentColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.rajdhaniTitle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brand.buttonColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.rajdhaniButton(color: Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brand.buttonColor,
        side: BorderSide(color: brand.buttonColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brand.buttonColor,
      foregroundColor: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: brand.buttonColor,
      unselectedItemColor: AppColors.text4,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: brand.buttonColor,
      unselectedLabelColor: AppColors.text4,
      indicatorColor: brand.buttonColor,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: brand.buttonColor.withValues(alpha: 0.1),
      selectedColor: brand.buttonColor,
      labelStyle: AppTextStyles.rajdhaniLabel(color: brand.buttonColor),
    ),
  );

  static ThemeData get dark => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    textTheme: AppTypography.textTheme,
  );
}
