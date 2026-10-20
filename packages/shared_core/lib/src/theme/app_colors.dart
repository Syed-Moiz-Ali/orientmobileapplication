import 'package:flutter/material.dart';

/// Semantic color tokens for the ORIENT design system (Concept A — Premium Minimal Automotive).
///
/// Organized into distinct functional roles:
/// - Canvas and surfaces (clean off-white, crisp surface, high-emphasis deep navy)
/// - Typography and inks (deep slate navy, cool slate, muted text)
/// - Borders and dividers (subtle divider, hairline structural border, strong border)
/// - Brand primary (hyper cobalt blue, interaction states, pale tinted container)
/// - Restrained semantics (precision emerald, electric amber, brembo crimson, ice blue)
/// - Backward-compatible legacy aliases
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Canvas & Surfaces (Concept A Light Theme)
  // ---------------------------------------------------------------------------
  /// Main application viewport canvas (ultra-clean off-white background).
  static const Color canvas = Color(0xFFFBFBFD);

  /// Primary neutral surface for elevated cards, dialogs, sheets, and menus.
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle secondary surface for nested cards, alternating rows, input fill.
  static const Color surfaceSubtle = Color(0xFFF4F6F9);

  /// Elevated surface variant (raised cards, popovers).
  static const Color surfaceRaised = Color(0xFFFFFFFF);

  /// Sunken or recessed background for inputs and inactive slots.
  static const Color surfaceSunken = Color(0xFFF4F6F9);

  /// Secondary surface alias.
  static const Color surfaceAlt = Color(0xFFF4F6F9);

  /// High-emphasis dark slate navy surface for telemetry, hero metrics, command panels.
  static const Color surfaceStrong = Color(0xFF0F172A);

  /// Inverse surface alias (maps to high-emphasis navy).
  static const Color surfaceInverse = Color(0xFF0F172A);

  /// High-emphasis navy surface raised (cards sitting inside dark panels).
  static const Color navySurfaceRaised = Color(0xFF1E293B);

  // ---------------------------------------------------------------------------
  // Inks & Typography
  // ---------------------------------------------------------------------------
  /// Primary text ink: deep slate navy for high-contrast titles.
  static const Color textPrimary = Color(0xFF0F172A);

  /// Secondary text ink: cool slate for readable body text and technical metadata.
  static const Color textSecondary = Color(0xFF475569);

  /// Muted text ink: slate grey for timestamps, metadata, captions, disabled hints (WCAG AA ≥ 4.5:1).
  static const Color textMuted = Color(0xFF64748B);

  /// Disabled text and placeholder ink.
  static const Color textDisabled = Color(0xFF94A3B8);

  /// Inverse text ink: pure crisp white for dark panels and buttons.
  static const Color textInverse = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Borders & Dividers
  // ---------------------------------------------------------------------------
  /// Subtle 1px divider for internal card sections and quiet dividers.
  static const Color borderSubtle = Color(0xFFEDF2F7);

  /// Default 1px structural hairline border for cards, inputs, and top bars.
  static const Color borderDefault = Color(0xFFE2E8F0);

  /// Medium / strong border for focused inputs, active chips, and emphasis cards.
  static const Color borderStrong = Color(0xFFCBD5E1);

  /// Hairline divider stroke.
  static const Color stroke = Color(0xFFE2E8F0);

  /// Subtle dark border for navy panels.
  static const Color borderDark = Color(0xFF262C3D);

  // ---------------------------------------------------------------------------
  // Brand Primary: Hyper Cobalt Blue
  // ---------------------------------------------------------------------------
  /// Primary interactive brand color for buttons, active tabs, and primary accents.
  /// Tuned for WCAG AA ≥ 4.5:1 across rest, hover (8%), and pressed (10%) states.
  static const Color primary = Color(0xFF215FE6);

  /// Hover interaction state for primary elements on desktop / web.
  static const Color primaryHover = Color(0xFF1D4ED8);

  /// Pressed / active interaction state for primary elements.
  static const Color primaryPressed = Color(0xFF1E40AF);

  /// Very pale blue background for tinted primary containers and chips.
  static const Color primarySubtle = Color(0xFFDBEAFE);

  /// Subtle blue border for primary tinted cards and selected chips.
  static const Color primaryBorder = Color(0xFFBFDBFE);

  // ---------------------------------------------------------------------------
  // Semantic States (Concept A Exact Tokens)
  // ---------------------------------------------------------------------------
  /// Precision Emerald: verified inspections, completed milestones, profitable metrics.
  static const Color success = Color(0xFF10B981);
  static const Color successSubtle = Color(0xFFD1FAE5);
  static const Color successBorder = Color(0xFFA7F3D0);

  /// Electric Amber: caution checkpoints, pending estimates, follow-up queues.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSubtle = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);

  /// Brembo Crimson: critical inspection failures, urgent safety hazards, overdue leads.
  /// Tuned for WCAG AA ≥ 4.5:1 across rest, hover (8%), and pressed (10%) states
  /// (Phase 01.1 accessibility amendment: raw `#EF4444` was ≈3.76:1 with white ink).
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSubtle = Color(0xFFFEE2E2);
  static const Color dangerBorder = Color(0xFFFECACA);

  /// Ice Blue / Cyan: telemetry chips, stage indicators, scheduled operations.
  ///
  /// NOTE (phase-0b): role-picker icons, CRM channel colors and the chart
  /// series intentionally keep these ice-blue values. The *semantic* info
  /// family ([AppSemanticColors.info]) now resolves to the teal-cyan family
  /// below — see DESIGN_SYSTEM.md "info teal" before reusing these directly.
  static const Color info = Color(0xFF0284C7);
  static const Color infoSubtle = Color(0xFFE0F2FE);
  static const Color infoBorder = Color(0xFFBAE6FD);

  // ---------------------------------------------------------------------------
  // Accent family (phase-0b, additive): the #215FE6 brand with explicit
  // pressed / soft / ink roles. White on accent = 5.46:1, white on pressed =
  // 8.72:1, pressed-ink on soft = 7.3:1 (all WCAG AA, see swatch report).
  // ---------------------------------------------------------------------------
  /// Pressed state of the brand accent (buttons, active nav).
  static const Color accentPressed = Color(0xFF1E40AF);

  /// Tinted accent background (chips, selected rows, icon tiles).
  static const Color accentSoft = Color(0xFFE3ECFD);

  /// Legible ink on [accentSoft] (and pressed-state label ink).
  static const Color accentInk = Color(0xFF1E40AF);

  /// Ink for text sitting directly on [accentPressed] (white, 8.72:1).
  /// Dark filled buttons keep dark ink on the bright base but MUST flip to
  /// this ink in the pressed state (button themes adopt it in module phases;
  /// until then dark-pressed ships the pre-existing 3.81:1 pair — see
  /// DESIGN_SYSTEM.md "pressed ink").
  static const Color accentPressedInk = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Info teal-cyan family (phase-0b, additive): the new semantic-info
  // resolution. Kept visually distinct from accent (#215FE6 cobalt) and
  /// success (#10B981 emerald) — see the token swatch evaluation.
  // White on base = 5.36:1, base on canvas = 5.18:1, ink on soft = 6.45:1.
  // ---------------------------------------------------------------------------
  /// Teal-cyan base for info dots, icons and strong fills (was ice blue).
  static const Color infoTeal = Color(0xFF0E7490);

  /// Pale teal container fill for info chips and banners.
  static const Color infoTealSoft = Color(0xFFE6F4F7);

  /// Hairline ring for teal containers.
  static const Color infoTealBorder = Color(0xFF9FD0D9);

  /// Legible ink on [infoTealSoft] (and teal body text on canvas).
  static const Color infoTealInk = Color(0xFF155E75);

  // ---------------------------------------------------------------------------
  // Dark Navy High-Emphasis Tokens
  // ---------------------------------------------------------------------------
  /// Signature Orient deep slate navy tone for high-emphasis surfaces.
  static const Color navy = Color(0xFF0F172A);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color navySurface = Color(0xFF0F172A);
  static const Color navyBorder = Color(0xFF262C3D);

  // ---------------------------------------------------------------------------
  // Extended Semantic Roles
  // ---------------------------------------------------------------------------
  /// Modal / bottom-sheet / drawer scrim over page content (`#0B1526` at 42%).
  static const Color overlayScrim = Color(0x6B0B1526);

  /// Secondary ink for supporting copy on navy high-emphasis surfaces.
  static const Color onNavySecondary = Color(0xFF94A3B8);

  /// 2px focus indicator ring.
  static const Color focusRing = primary;

  /// Feedback / rating star ink (service reviews, satisfaction ratings).
  static const Color ratingStar = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Skeleton Loaders
  // ---------------------------------------------------------------------------
  static const Color skeletonBase = Color(0xFFF1F5F9);
  static const Color skeletonHighlight = Color(0xFFF8FAFC);

  // ---------------------------------------------------------------------------
  // Chart Series Palette (Concept A Ordered Telemetry)
  // ---------------------------------------------------------------------------
  static const List<Color> chartSeries = [
    Color(0xFF215FE6), // hyper cobalt
    Color(0xFF10B981), // precision emerald
    Color(0xFF0284C7), // ice blue
    Color(0xFFF59E0B), // electric amber
    Color(0xFFEF4444), // brembo crimson
    Color(0xFF64748B), // technical slate
  ];

  static const List<Color> chartSeriesDark = [
    Color(0xFF3B82F6),
    Color(0xFF34D399),
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    Color(0xFFF87171),
    Color(0xFF94A3B8),
  ];

  // ---------------------------------------------------------------------------
  // Concept A Direct Token References
  // ---------------------------------------------------------------------------
  static const Color canvasLight = canvas;
  static const Color surfaceLight = surface;
  static const Color cardBgLight = surfaceSubtle;
  static const Color borderLight = borderDefault;
  static const Color borderSubtleLight = borderSubtle;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textMutedLight = textMuted;

  static const Color hyperCobalt = primary;
  static const Color hyperCobaltHover = primaryHover;
  static const Color hyperCobaltMuted = primarySubtle;
  static const Color precisionEmerald = success;
  static const Color emeraldMuted = successSubtle;
  static const Color electricAmber = warning;
  static const Color amberMuted = warningSubtle;
  static const Color bremboCrimson = danger;
  static const Color crimsonMuted = dangerSubtle;
  static const Color iceBlue = info;
  static const Color iceBlueMuted = infoSubtle;

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
  static const Color selected = Color(0xFFDBEAFE);
  static const Color hover = Color(0xFFEFF6FF);
  static const Color pressed = Color(0xFFBFDBFE);
  static const Color focus = primary;
  static const Color disabled = Color(0xFFE2E8F0);

  static const Color successBg = successSubtle;
  static const Color dangerBg = dangerSubtle;
  static const Color warningBg = warningSubtle;
  static const Color infoBg = infoSubtle;

  static const Color accent = Color(0xFF10B981);
  static const Color cyan = Color(0xFF0284C7);
  static const Color cyanLight = Color(0xFFE0F2FE);
  static const Color cyanBright = Color(0xFF38BDF8);
  static const Color greenAccent = success;
  static const Color greenBg = successSubtle;
  static const Color purpleAccent = Color(0xFF6366F1);
  static const Color purpleLight = Color(0xFFEEF2FF);
  static const Color purpleSoft = Color(0xFFF5F3FF);
  static const Color blueBg = primarySubtle;
  static const Color red500 = danger;
  static const Color redBg = dangerSubtle;
  static const Color amberBg = warningSubtle;
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = warning;

  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray900 = Color(0xFF0F172A);
}

/// Dark-theme parity map for the ORIENT design system (Concept A Dark Parity).
class AppDarkColors {
  AppDarkColors._();

  // Canvas & surfaces
  static const Color canvas = Color(0xFF090B10);
  static const Color surface = Color(0xFF11141D);
  static const Color surfaceSubtle = Color(0xFF181C28);
  static const Color surfaceRaised = Color(0xFF181C28);
  static const Color surfaceSunken = Color(0xFF0D1017);
  static const Color surfaceStrong = Color(0xFF11141D);
  static const Color navySurfaceRaised = Color(0xFF1E2536);

  // Inks
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF8899B0);
  static const Color textDisabled = Color(0xFF475569);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color onNavySecondary = Color(0xFF94A3B8);

  // Borders
  static const Color borderSubtle = Color(0xFF1A202E);
  static const Color borderDefault = Color(0xFF262C3D);
  static const Color borderStrong = Color(0xFF384259);

  // Primary / selection
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryHover = Color(0xFF60A5FA);
  static const Color primaryPressed = Color(0xFF2563EB);
  static const Color primarySubtle = Color(0xFF1E2A4A);
  static const Color primaryBorder = Color(0xFF2D3F6E);
  static const Color selected = Color(0xFF1E2A4A);
  static const Color hover = Color(0xFF161F36);
  static const Color focus = Color(0xFF60A5FA);
  static const Color focusRing = focus;

  /// High contrast dark ink on buttons in dark mode (WCAG AA 5.35:1)
  static const Color onPrimary = Color(0xFF090B10);
  static const Color onError = Color(0xFF090B10);

  // Semantics
  static const Color success = Color(0xFF34D399);
  static const Color successSubtle = Color(0xFF064E3B);
  static const Color successBorder = Color(0xFF065F46);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningSubtle = Color(0xFF451A03);
  static const Color warningBorder = Color(0xFF78350F);
  static const Color danger = Color(0xFFF87171);
  static const Color dangerSubtle = Color(0xFF450A0A);
  static const Color dangerBorder = Color(0xFF7F1D1D);
  static const Color info = Color(0xFF38BDF8);
  static const Color infoSubtle = Color(0xFF0C4A6E);
  static const Color infoBorder = Color(0xFF075985);

  // ---------------------------------------------------------------------------
  // Dark accent + info-teal families (phase-0b, additive). Dark tokens are
  // DEFINED here but NOT wired into staff/owner/CRM (light-first; customer
  // dark must not regress). Dark base #45B7C7 on dark ink #090B10 = 8.3:1,
  // dark teal ink on dark soft = 8.63:1.
  // ---------------------------------------------------------------------------
  /// Dark pressed state of the brand accent.
  static const Color accentPressed = Color(0xFF2563EB);

  /// Dark tinted accent background.
  static const Color accentSoft = Color(0xFF1E2A4A);

  /// Legible ink on dark [accentSoft].
  static const Color accentInk = Color(0xFFD5DEFF);

  /// Ink for text on dark [accentPressed] (white, 5.07:1 — dark ink on the
  /// pressed fill is only 3.81:1, so pressed state flips ink; see light note).
  static const Color accentPressedInk = Color(0xFFFFFFFF);

  /// Dark teal-cyan base (lighter variant of the light teal for dark canvas).
  static const Color infoTeal = Color(0xFF45B7C7);

  /// Dark teal container fill.
  static const Color infoTealSoft = Color(0xFF0C3238);

  /// Dark teal hairline ring.
  static const Color infoTealBorder = Color(0xFF1E5A64);

  /// Legible ink on dark [infoTealSoft].
  static const Color infoTealInk = Color(0xFF8FD9E3);

  /// Feedback / rating star.
  static const Color ratingStar = Color(0xFFFBBF24);

  // Skeleton loaders
  static const Color skeletonBase = Color(0xFF181C28);
  static const Color skeletonHighlight = Color(0xFF262C3D);

  /// Modal scrim on dark surfaces (`#090B10` at 80%).
  static const Color overlayScrim = Color(0xCC090B10);

  // Concept A Direct Dark Tokens
  static const Color canvasDark = canvas;
  static const Color surfaceDark = surface;
  static const Color cardBgDark = surfaceSubtle;
  static const Color borderDark = borderDefault;
  static const Color borderSubtleDark = borderSubtle;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;
  static const Color textMutedDark = textMuted;

  // Chart series (dark)
  static const List<Color> chartSeriesDark = AppColors.chartSeriesDark;
}
