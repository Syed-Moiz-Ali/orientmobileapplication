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
    iconColor: AppColors.accent,
    accentColor: AppColors.accent,
    buttonColor: AppColors.accent,
  );
}

final brandConfigProvider = Provider<BrandConfig>((ref) {
  return BrandConfig.orient;
});
