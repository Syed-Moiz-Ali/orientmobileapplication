import 'package:flutter/material.dart';

/// Semantic color tokens for the ORIENT design system (2026 Workshop ERP).
///
/// Organized into distinct functional roles:
/// - Canvas and surfaces (clean white, subtle cool slate, high-emphasis navy)
/// - Typography and inks (deep charcoal navy, cool slate, muted text)
/// - Borders and dividers (subtle, default hairline, strong)
/// - Brand primary (electric cobalt blue, interaction states, pale tinted container)
/// - Restrained semantics (success, warning, danger, info)
/// - Backward-compatible legacy aliases
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Canvas & Surfaces
  // ---------------------------------------------------------------------------
  /// Main application viewport canvas (very light cool grey / blue-white).
  static const Color canvas = Color(0xFFF5F7FB);

  /// Primary neutral surface for cards, dialogs, sheets, and menus.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle secondary surface for nested cards, alternating rows, sunken areas.
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  /// Elevated surface variant (raised cards, popovers).
  static const Color surfaceRaised = Color(0xFFFFFFFF);

  /// Sunken or recessed background for inputs and inactive slots.
  static const Color surfaceSunken = Color(0xFFF0F3F8);

  /// Secondary surface alias.
  static const Color surfaceAlt = Color(0xFFEEF3F8);

  /// High-emphasis dark navy surface for telemetry, hero metrics, command panels.
  static const Color surfaceStrong = Color(0xFF14213D);

  /// Inverse surface alias (maps to high-emphasis navy).
  static const Color surfaceInverse = Color(0xFF14213D);

  /// High-emphasis navy surface raised (cards sitting inside dark panels).
  static const Color navySurfaceRaised = Color(0xFF1C2C50);

  // ---------------------------------------------------------------------------
  // Inks & Typography
  // ---------------------------------------------------------------------------
  /// Primary text ink: deep charcoal navy / nearly black for high-contrast titles.
  static const Color textPrimary = Color(0xFF111827);

  /// Secondary text ink: cool slate for readable body text and secondary labels.
  static const Color textSecondary = Color(0xFF394150);

  /// Muted text ink: light slate grey for timestamps, metadata, captions.
  static const Color textMuted = Color(0xFF677182);

  /// Disabled text and placeholder ink.
  static const Color textDisabled = Color(0xFF9AA4B2);

  /// Inverse text ink: pure crisp white for dark panels and buttons.
  static const Color textInverse = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Borders & Dividers
  // ---------------------------------------------------------------------------
  /// Subtle 1px divider for internal card sections and quiet dividers.
  static const Color borderSubtle = Color(0xFFF0F3F8);

  /// Default 1px structural hairline border for cards, inputs, and top bars.
  static const Color borderDefault = Color(0xFFE5EAF1);

  /// Medium / strong border for focused inputs, active chips, and emphasis cards.
  static const Color borderStrong = Color(0xFFCCD6E2);

  /// Hairline divider stroke.
  static const Color stroke = Color(0xFFD8E0EA);

  /// Subtle dark border for navy panels.
  static const Color borderDark = Color(0xFF2A3A5E);

  // ---------------------------------------------------------------------------
  // Brand Primary (Electric Cobalt Blue)
  // ---------------------------------------------------------------------------
  /// Primary interactive brand color for buttons, active tabs, and primary accents.
  static const Color primary = Color(0xFF3157D5);

  /// Hover interaction state for primary elements on desktop / web.
  static const Color primaryHover = Color(0xFF2848B8);

  /// Pressed / active interaction state for primary elements.
  static const Color primaryPressed = Color(0xFF203B9E);

  /// Very pale blue background for tinted primary containers and chips.
  static const Color primarySubtle = Color(0xFFEEF3FF);

  /// Subtle blue border for primary tinted cards and selected chips.
  static const Color primaryBorder = Color(0xFFC8D6FF);

  // ---------------------------------------------------------------------------
  // Semantic States (Restrained)
  // ---------------------------------------------------------------------------
  /// Semantic success for completed work, verified inspections, and paid invoices.
  static const Color success = Color(0xFF0F8B5F);
  static const Color successSubtle = Color(0xFFE9F7F1);
  static const Color successBorder = Color(0xFFB9E5D0);

  /// Semantic warning for pending approvals, attention queues, and advisories.
  static const Color warning = Color(0xFFE09A1F);
  static const Color warningSubtle = Color(0xFFFFF8E8);
  static const Color warningBorder = Color(0xFFF3D18B);

  /// Semantic danger for rejections, emergency breakdowns, and destructive actions.
  static const Color danger = Color(0xFFD92D43);
  static const Color dangerSubtle = Color(0xFFFFF1F3);
  static const Color dangerBorder = Color(0xFFF8C7CE);

  /// Semantic info for notices, scheduled events, and operational telemetry.
  static const Color info = Color(0xFF6D5DF6);
  static const Color infoSubtle = Color(0xFFF1F0FF);
  static const Color infoBorder = Color(0xFFD9D5FF);

  // ---------------------------------------------------------------------------
  // Dark Navy High-Emphasis Tokens
  // ---------------------------------------------------------------------------
  /// Signature Orient dark navy tone for high-emphasis surfaces.
  static const Color navy = Color(0xFF14213D);
  static const Color darkNavy = Color(0xFF14213D);
  static const Color navySurface = Color(0xFF14213D);
  static const Color navyBorder = Color(0xFF2A3A5E);

  // ---------------------------------------------------------------------------
  // Backward-Compatible Legacy Aliases
  // ---------------------------------------------------------------------------
  static const Color bg = canvas;
  static const Color border = borderDefault;
  static const Color borderMd = borderStrong;
  static const Color line = borderSubtle;
  static const Color text2 = textSecondary;
  static const Color text3 = textMuted;
  static const Color text4 = textDisabled;
  static const Color primaryBg = primarySubtle;
  static const Color selected = Color(0xFFE8EEFF);
  static const Color hover = Color(0xFFF0F4FF);
  static const Color pressed = Color(0xFFDCE5FF);
  static const Color focus = primary;
  static const Color disabled = Color(0xFFE4E7EC);

  static const Color successBg = successSubtle;
  static const Color dangerBg = dangerSubtle;
  static const Color warningBg = warningSubtle;
  static const Color infoBg = infoSubtle;

  static const Color accent = Color(0xFF00B894);
  static const Color cyan = Color(0xFF00B894);
  static const Color cyanLight = Color(0xFFE6F7F3);
  static const Color cyanBright = Color(0xFF3DE0BF);
  static const Color greenAccent = success;
  static const Color greenBg = successSubtle;
  static const Color purpleAccent = info;
  static const Color purpleLight = infoSubtle;
  static const Color purpleSoft = Color(0xFFF6F7FF);
  static const Color blueBg = primarySubtle;
  static const Color red500 = danger;
  static const Color redBg = dangerSubtle;
  static const Color amberBg = warningSubtle;
  static const Color amber400 = Color(0xFFE9AD3A);
  static const Color amber500 = warning;

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);
}
