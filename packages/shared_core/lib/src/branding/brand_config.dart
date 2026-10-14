import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/theme/app_colors.dart';

/// Logo-only brand identity (Phase 01.2 hardening).
///
/// The brand carries **identity only** — name, tagline and mark. It never
/// carries a primary/button/accent color: the single styling authority for the
/// primary is [AppColors.primary] (`#215FE6`, Concept A §1.1) resolved by
/// `AppTheme`, and a guard test fails the build if any theme is built with a
/// custom primary.
///
/// The legacy color fields are retained for API compatibility so existing
/// callers keep compiling, but they are **ignored by the theme** and marked
/// deprecated. New code must not read them.
class BrandConfig {
  final String appName;
  final String? tagline;
  final IconData icon;

  /// Retained for compatibility; ignored by [AppTheme]. Do not use.
  @Deprecated('Logo-only brand: colors resolve from AppColors.primary')
  final Color iconColor;

  /// Retained for compatibility; ignored by [AppTheme]. Do not use.
  @Deprecated('Logo-only brand: colors resolve from AppColors.primary')
  final Color accentColor;

  /// Retained for compatibility; ignored by [AppTheme]. Do not use.
  @Deprecated('Logo-only brand: colors resolve from AppColors.primary')
  final Color buttonColor;

  const BrandConfig({
    required this.appName,
    this.tagline,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.accentColor = AppColors.accent,
    this.buttonColor = AppColors.primary,
  });

  static const BrandConfig orient = BrandConfig(
    appName: 'ORIENT',
    tagline: 'Auto Garage ERP',
    icon: Icons.build_rounded,
  );

  /// Logo-only copy (identity fields only).
  BrandConfig get logoOnly =>
      BrandConfig(appName: appName, tagline: tagline, icon: icon);
}

/// P3 (audit): per-client white-labeling. Apps/whitelabel builds can override
/// the brand at startup with `overrideBrandConfigProvider.overrideWithValue(...)`
/// (or provide their own Provider) — previously the brand was a hardcoded
/// singleton and could never differ per client.
///
/// White-label overrides may change the logo/name only; the primary stays
/// locked to `#215FE6` (guarded by `theme_primary_guard_test.dart`).
final overrideBrandConfigProvider = Provider<BrandConfig?>((ref) => null);

final brandConfigProvider = Provider<BrandConfig>((ref) {
  final override = ref.watch(overrideBrandConfigProvider);
  if (override != null) return override;
  return BrandConfig.orient;
});
