import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 — color role completeness.
///
/// Verifies the additive roles frozen in Phase 00 are present, resolve to the
/// approved values, and that every legacy alias still maps to its semantic
/// token (no removed names).
void main() {
  group('Phase 01 color roles', () {
    test('extended semantic roles exist with approved values', () {
      expect(AppColors.overlayScrim, const Color(0x6B0B1526));
      expect(AppColors.onNavySecondary, const Color(0xFFAAB5C8));
      expect(AppColors.focusRing, AppColors.primary);
      expect(AppColors.ratingStar, const Color(0xFFE9AD3A));
    });

    test('dark parity map resolves the approved Phase 00 values', () {
      expect(AppDarkColors.canvas, const Color(0xFF0C1120));
      expect(AppDarkColors.surface, const Color(0xFF151C2E));
      expect(AppDarkColors.surfaceSubtle, const Color(0xFF1A2236));
      expect(AppDarkColors.surfaceSunken, const Color(0xFF101627));
      expect(AppDarkColors.surfaceRaised, const Color(0xFF1B2439));
      expect(AppDarkColors.surfaceStrong, const Color(0xFF14213D));
      expect(AppDarkColors.navySurfaceRaised, const Color(0xFF1C2C50));
      expect(AppDarkColors.textPrimary, const Color(0xFFF2F5FB));
      expect(AppDarkColors.textSecondary, const Color(0xFFC6CEDF));
      expect(AppDarkColors.textMuted, const Color(0xFF8F9AB0));
      expect(AppDarkColors.textDisabled, const Color(0xFF5E6981));
      expect(AppDarkColors.borderSubtle, const Color(0xFF202A40));
      expect(AppDarkColors.borderDefault, const Color(0xFF2A354D));
      expect(AppDarkColors.borderStrong, const Color(0xFF3E4B66));
      expect(AppDarkColors.primary, const Color(0xFF6E8BFF));
      expect(AppDarkColors.primaryHover, const Color(0xFF84A0FF));
      expect(AppDarkColors.primaryPressed, const Color(0xFF5C79F0));
      expect(AppDarkColors.primarySubtle, const Color(0xFF1B2440));
      expect(AppDarkColors.primaryBorder, const Color(0xFF32406E));
      expect(AppDarkColors.selected, const Color(0xFF1D2A4D));
      expect(AppDarkColors.hover, const Color(0xFF1A2440));
      expect(AppDarkColors.focus, const Color(0xFF84A0FF));
      expect(AppDarkColors.success, const Color(0xFF3DC795));
      expect(AppDarkColors.warning, const Color(0xFFF0B34C));
      expect(AppDarkColors.danger, const Color(0xFFF1707F));
      expect(AppDarkColors.info, const Color(0xFF9B8DFF));
      expect(AppDarkColors.overlayScrim, const Color(0xCC0B1526));
    });

    test('dark control inks are the Phase 01.1 accessibility amendment', () {
      // Product-owner sign-off: dark button labels use a dark ink on the
      // bright primary/danger fills instead of white (which was ≈3.1:1).
      expect(AppDarkColors.onPrimary, const Color(0xFF0C1120));
      expect(AppDarkColors.onError, AppDarkColors.onPrimary);
    });

    test('dark map mirrors the light role names (same semantic set)', () {
      // If a role is renamed or dropped on one side, this keeps the parity map
      // honest: every pair below is the same semantic role on both maps.
      expect(AppDarkColors.onNavySecondary, AppColors.onNavySecondary);
      expect(AppDarkColors.ratingStar, AppColors.ratingStar);
      expect(AppDarkColors.focusRing, AppDarkColors.focus);
      expect(AppDarkColors.surfaceStrong, AppColors.surfaceStrong);
      expect(AppDarkColors.navySurfaceRaised, AppColors.navySurfaceRaised);
    });

    test('chart palette exposes six light and six dark series', () {
      expect(AppColors.chartSeries, hasLength(6));
      expect(AppColors.chartSeriesDark, hasLength(6));
      expect(AppColors.chartSeries.toSet(), hasLength(6));
      expect(AppColors.chartSeriesDark.toSet(), hasLength(6));
      expect(AppColors.chartSeries.first, AppColors.primary);
      expect(AppColors.chartSeriesDark.first, AppDarkColors.primary);
    });

    test('every legacy alias still resolves (no removed names)', () {
      expect(AppColors.bg, equals(AppColors.canvas));
      expect(AppColors.border, equals(AppColors.borderDefault));
      expect(AppColors.borderMd, equals(AppColors.borderStrong));
      expect(AppColors.line, equals(AppColors.borderSubtle));
      expect(AppColors.text2, equals(AppColors.textSecondary));
      expect(AppColors.text3, equals(AppColors.textMuted));
      expect(AppColors.text4, equals(AppColors.textDisabled));
      expect(AppColors.primaryBg, equals(AppColors.primarySubtle));
      expect(AppColors.successBg, equals(AppColors.successSubtle));
      expect(AppColors.dangerBg, equals(AppColors.dangerSubtle));
      expect(AppColors.warningBg, equals(AppColors.warningSubtle));
      expect(AppColors.infoBg, equals(AppColors.infoSubtle));
      expect(AppColors.accent, isNotNull);
      expect(AppColors.cyan, isNotNull);
      expect(AppColors.gray50, isNotNull);
      expect(AppColors.gray900, isNotNull);
    });
  });
}
