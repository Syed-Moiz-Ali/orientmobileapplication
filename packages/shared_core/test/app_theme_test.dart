import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  // P3 (audit): dark() previously omitted the component themes light() defines
  // (textButton, FAB, bottom-nav labels) — a regression guard that both modes
  // build the same component surface.
  testWidgets('AppTheme.dark() provides the full component theme surface',
      (tester) async {
    const brand = BrandConfig.orient;
    final dark = AppTheme.dark(brand);
    final light = AppTheme.light(brand);

    expect(dark.textButtonTheme.style, isNotNull, reason: 'textButtonTheme missing');
    expect(dark.floatingActionButtonTheme.backgroundColor, brand.buttonColor,
        reason: 'floatingActionButtonTheme missing or wrong');
    expect(
      dark.bottomNavigationBarTheme.showUnselectedLabels,
      light.bottomNavigationBarTheme.showUnselectedLabels,
      reason: 'bottom nav label parity broken',
    );
    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, isNot(light.scaffoldBackgroundColor));
  });
}
