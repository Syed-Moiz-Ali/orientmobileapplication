import 'package:flutter/material.dart';

abstract final class AppFontFamilies {
  static const String app = 'packages/shared_core/Plus Jakarta Sans';
  static const String display = app;
  static const String body = app;
  static const String mono = app;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 31,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle displaySmall({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle title({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle subtitle({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle body({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle bodyStrong({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle label({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle button({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.display,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle mono({Color? color}) => TextStyle(
    fontFamily: AppFontFamilies.mono,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: color,
  );

  static TextStyle monoDate({Color? color}) => mono(color: color);
  static TextStyle monoTime({Color? color}) => mono(color: color);
  static TextStyle monoMetric({Color? color}) => mono(color: color);
  static TextStyle monoCode({Color? color}) => mono(color: color);
  static TextStyle monoTable({Color? color}) => mono(color: color);
}

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge(),
    displayMedium: AppTextStyles.displayMedium(),
    displaySmall: AppTextStyles.displaySmall(),
    headlineLarge: AppTextStyles.displayMedium(),
    headlineMedium: AppTextStyles.displaySmall(),
    headlineSmall: AppTextStyles.title(),
    titleLarge: AppTextStyles.title(),
    titleMedium: AppTextStyles.subtitle(),
    titleSmall: AppTextStyles.bodyStrong(),
    bodyLarge: AppTextStyles.body(),
    bodyMedium: AppTextStyles.body(),
    bodySmall: AppTextStyles.bodySmall(),
    labelLarge: AppTextStyles.button(),
    labelMedium: AppTextStyles.label(),
    labelSmall: AppTextStyles.label(),
  );
}
