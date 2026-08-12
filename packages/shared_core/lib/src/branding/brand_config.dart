import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/theme/app_colors.dart';

class BrandConfig {
  final String appName;
  final String? tagline;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final Color buttonColor;

  const BrandConfig({
    required this.appName,
    this.tagline,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.buttonColor,
  });

  static const BrandConfig orient = BrandConfig(
    appName: 'ORIENT',
    tagline: 'Auto Garage ERP',
    icon: Icons.build_rounded,
    iconColor: AppColors.primary,
    accentColor: AppColors.accent,
    buttonColor: AppColors.primary,
  );
}

/// P3 (audit): per-client white-labeling. Apps/whitelabel builds can override
/// the brand at startup with `overrideBrandConfigProvider.overrideWithValue(...)`
/// (or provide their own Provider) — previously the brand was a hardcoded
/// singleton and could never differ per client.
final overrideBrandConfigProvider = Provider<BrandConfig?>((ref) => null);

final brandConfigProvider = Provider<BrandConfig>((ref) {
  final override = ref.watch(overrideBrandConfigProvider);
  if (override != null) return override;
  return BrandConfig.orient;
});
