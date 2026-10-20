import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Spec-C2 token view (phase-0b, additive) exposed as a
/// `ThemeExtension<AppTokens>`.
///
/// This is a *naming* layer over the frozen Concept-A authorities — it
/// introduces no new color values itself. `info*` resolve to the teal-cyan
/// family ([AppColors.infoTeal]*); direct ice-blue users (role icons, CRM
/// channels, chart series) intentionally keep the legacy constants.
/// See DESIGN_SYSTEM.md "info teal".
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final Color accent;
  final Color accentPressed;
  final Color accentPressedInk;
  final Color accentSoft;
  final Color accentInk;
  final Color infoBase;
  final Color infoSoft;
  final Color infoBorder;
  final Color infoInk;
  final Color overlay;
  final Color skeletonBase;
  final Color skeletonHighlight;

  const AppTokens({
    required this.accent,
    required this.accentPressed,
    required this.accentPressedInk,
    required this.accentSoft,
    required this.accentInk,
    required this.infoBase,
    required this.infoSoft,
    required this.infoBorder,
    required this.infoInk,
    required this.overlay,
    required this.skeletonBase,
    required this.skeletonHighlight,
  });

  static const AppTokens light = AppTokens(
    accent: AppColors.primary,
    accentPressed: AppColors.accentPressed,
    accentPressedInk: AppColors.accentPressedInk,
    accentSoft: AppColors.accentSoft,
    accentInk: AppColors.accentInk,
    infoBase: AppColors.infoTeal,
    infoSoft: AppColors.infoTealSoft,
    infoBorder: AppColors.infoTealBorder,
    infoInk: AppColors.infoTealInk,
    overlay: Color(0x66000000),
    skeletonBase: AppColors.skeletonBase,
    skeletonHighlight: AppColors.skeletonHighlight,
  );

  static const AppTokens dark = AppTokens(
    accent: AppDarkColors.primary,
    accentPressed: AppDarkColors.accentPressed,
    accentPressedInk: AppDarkColors.accentPressedInk,
    accentSoft: AppDarkColors.accentSoft,
    accentInk: AppDarkColors.accentInk,
    infoBase: AppDarkColors.infoTeal,
    infoSoft: AppDarkColors.infoTealSoft,
    infoBorder: AppDarkColors.infoTealBorder,
    infoInk: AppDarkColors.infoTealInk,
    overlay: Color(0x99000000),
    skeletonBase: AppDarkColors.skeletonBase,
    skeletonHighlight: AppDarkColors.skeletonHighlight,
  );

  static AppTokens of(BuildContext context) =>
      Theme.of(context).extension<AppTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  AppTokens copyWith({
    Color? accent,
    Color? accentPressed,
    Color? accentPressedInk,
    Color? accentSoft,
    Color? accentInk,
    Color? infoBase,
    Color? infoSoft,
    Color? infoBorder,
    Color? infoInk,
    Color? overlay,
    Color? skeletonBase,
    Color? skeletonHighlight,
  }) {
    return AppTokens(
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentPressedInk: accentPressedInk ?? this.accentPressedInk,
      accentSoft: accentSoft ?? this.accentSoft,
      accentInk: accentInk ?? this.accentInk,
      infoBase: infoBase ?? this.infoBase,
      infoSoft: infoSoft ?? this.infoSoft,
      infoBorder: infoBorder ?? this.infoBorder,
      infoInk: infoInk ?? this.infoInk,
      overlay: overlay ?? this.overlay,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    );
  }

  @override
  AppTokens lerp(covariant ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      accent: lerpColor(accent, other.accent),
      accentPressed: lerpColor(accentPressed, other.accentPressed),
      accentPressedInk: lerpColor(accentPressedInk, other.accentPressedInk),
      accentSoft: lerpColor(accentSoft, other.accentSoft),
      accentInk: lerpColor(accentInk, other.accentInk),
      infoBase: lerpColor(infoBase, other.infoBase),
      infoSoft: lerpColor(infoSoft, other.infoSoft),
      infoBorder: lerpColor(infoBorder, other.infoBorder),
      infoInk: lerpColor(infoInk, other.infoInk),
      overlay: lerpColor(overlay, other.overlay),
      skeletonBase: lerpColor(skeletonBase, other.skeletonBase),
      skeletonHighlight:
          lerpColor(skeletonHighlight, other.skeletonHighlight),
    );
  }
}
