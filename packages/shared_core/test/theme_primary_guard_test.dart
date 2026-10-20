// Guards the single authorized primary authority (Concept A §1.1).
//
// Light primary is always #215FE6; [BrandConfig] is logo-only and its legacy
// color fields must never change the built theme. Phase-0 foundation decision:
// keep the brand accent, additive tokens only.
//
// ignore_for_file: deprecated_member_use — intentionally exercises the
// retained-for-compatibility fields to prove the theme ignores them.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  test('authorizedPrimaryLight is locked to #215FE6', () {
    expect(AppTheme.authorizedPrimaryLight, const Color(0xFF215FE6));
    expect(AppColors.primary, const Color(0xFF215FE6));
  });

  test('AppTheme.light uses the authorized primary', () {
    final theme = AppTheme.light(BrandConfig.orient);
    expect(theme.colorScheme.primary, AppTheme.authorizedPrimaryLight);
    expect(theme.colorScheme.primary, const Color(0xFF215FE6));
  });

  test('BrandConfig legacy color fields do not change the theme primary', () {
    const custom = BrandConfig(
      appName: 'Custom Client',
      icon: Icons.star,
      iconColor: Color(0xFF123456),
      accentColor: Color(0xFF654321),
      buttonColor: Color(0xFFABCDEF),
    );
    final theme = AppTheme.light(custom);
    expect(theme.colorScheme.primary, const Color(0xFF215FE6));
    expect(theme.colorScheme.secondary, const Color(0xFF215FE6));
  });
}
