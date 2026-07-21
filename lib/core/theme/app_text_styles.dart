import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── ORBITRON — Headings & Titles ──────────────────
  static TextStyle orbitronDisplayLarge({Color? color}) => GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: 3.0,
    color: color,
  );

  static TextStyle orbitronDisplayMedium({Color? color}) =>
      GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: color,
      );

  static TextStyle orbitronDisplaySmall({Color? color}) => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: color,
  );

  static TextStyle orbitronKpiNumber({Color? color}) => GoogleFonts.orbitron(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
    color: color,
  );

  static TextStyle orbitronHeadline({Color? color}) => GoogleFonts.orbitron(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
    color: color,
  );

  // ── RAJDHANI — Body Text & Labels ─────────────────
  static TextStyle rajdhaniTitle({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: color,
  );

  static TextStyle rajdhaniLabel({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: color,
  );

  static TextStyle rajdhaniButton({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: color,
  );

  static TextStyle rajdhaniBody({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    color: color,
  );

  static TextStyle rajdhaniBodySmall({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );

  static TextStyle rajdhaniInput({Color? color}) => GoogleFonts.rajdhani(
    fontSize: 16,
    letterSpacing: 0.4,
    color: color,
  );

  // ── JETBRAINS MONO — Technical Data ───────────────
  static TextStyle monoDate({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: color,
  );

  static TextStyle monoTime({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: color,
  );

  static TextStyle monoMetric({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: color,
  );

  static TextStyle monoCode({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: color,
  );

  static TextStyle monoTable({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: color,
  );
}

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: AppTextStyles.orbitronDisplayLarge(),
    displayMedium: AppTextStyles.orbitronDisplayMedium(),
    displaySmall: AppTextStyles.orbitronDisplaySmall(),
    headlineLarge: AppTextStyles.rajdhaniTitle(),
    headlineMedium: AppTextStyles.rajdhaniLabel(),
    headlineSmall: AppTextStyles.rajdhaniButton(),
    titleLarge: AppTextStyles.rajdhaniTitle(),
    titleMedium: AppTextStyles.rajdhaniLabel(),
    titleSmall: AppTextStyles.rajdhaniBodySmall(),
    bodyLarge: AppTextStyles.rajdhaniBody(),
    bodyMedium: AppTextStyles.rajdhaniBodySmall(),
    bodySmall: AppTextStyles.rajdhaniBodySmall(),
    labelLarge: AppTextStyles.monoTime(),
    labelMedium: AppTextStyles.monoDate(),
    labelSmall: AppTextStyles.monoCode(),
  );
}
