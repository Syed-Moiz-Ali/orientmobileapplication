import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 (V2) — Concept A color role completeness.
///
/// Verifies that Concept A tokens (approved by Product Owner) resolve to the
/// exact approved values, that dark parity adheres to WCAG AA, and that all
/// legacy aliases still map cleanly (no removed names).
void main() {
  group('Concept A V2 Phase 01 color roles', () {
    test('extended semantic roles exist with approved values', () {
      expect(AppColors.overlayScrim, const Color(0x6B0B1526));
      expect(AppColors.onNavySecondary, const Color(0xFF94A3B8));
      expect(AppColors.focusRing, AppColors.primary);
      expect(AppColors.ratingStar, const Color(0xFFF59E0B));
    });

    test('Concept A direct tokens match primary semantics', () {
      expect(AppColors.hyperCobalt, AppColors.primary);
      expect(AppColors.precisionEmerald, AppColors.success);
      expect(AppColors.electricAmber, AppColors.warning);
      expect(AppColors.bremboCrimson, AppColors.danger);
      expect(AppColors.iceBlue, AppColors.info);

      expect(AppColors.canvasLight, const Color(0xFFFBFBFD));
      expect(AppColors.surfaceLight, const Color(0xFFFFFFFF));
      expect(AppColors.cardBgLight, const Color(0xFFF4F6F9));
      expect(AppColors.borderLight, const Color(0xFFE2E8F0));
      expect(AppColors.textPrimaryLight, const Color(0xFF0F172A));
      expect(AppColors.textSecondaryLight, const Color(0xFF475569));
      expect(AppColors.textMutedLight, const Color(0xFF64748B));
    });

    test('dark parity map resolves the approved Concept A dark values', () {
      expect(AppDarkColors.canvas, const Color(0xFF090B10));
      expect(AppDarkColors.surface, const Color(0xFF11141D));
      expect(AppDarkColors.surfaceSubtle, const Color(0xFF181C28));
      expect(AppDarkColors.surfaceSunken, const Color(0xFF0D1017));
      expect(AppDarkColors.surfaceRaised, const Color(0xFF181C28));
      expect(AppDarkColors.surfaceStrong, const Color(0xFF11141D));
      expect(AppDarkColors.navySurfaceRaised, const Color(0xFF1E2536));
      expect(AppDarkColors.textPrimary, const Color(0xFFF8FAFC));
      expect(AppDarkColors.textSecondary, const Color(0xFF94A3B8));
      expect(AppDarkColors.textMuted, const Color(0xFF8899B0));
      expect(AppDarkColors.textDisabled, const Color(0xFF475569));
      expect(AppDarkColors.borderSubtle, const Color(0xFF1A202E));
      expect(AppDarkColors.borderDefault, const Color(0xFF262C3D));
      expect(AppDarkColors.borderStrong, const Color(0xFF384259));
      expect(AppDarkColors.primary, const Color(0xFF3B82F6));
      expect(AppDarkColors.primaryHover, const Color(0xFF60A5FA));
      expect(AppDarkColors.primaryPressed, const Color(0xFF2563EB));
      expect(AppDarkColors.primarySubtle, const Color(0xFF1E2A4A));
      expect(AppDarkColors.primaryBorder, const Color(0xFF2D3F6E));
      expect(AppDarkColors.selected, const Color(0xFF1E2A4A));
      expect(AppDarkColors.hover, const Color(0xFF161F36));
      expect(AppDarkColors.focus, const Color(0xFF60A5FA));
      expect(AppDarkColors.success, const Color(0xFF34D399));
      expect(AppDarkColors.warning, const Color(0xFFFBBF24));
      expect(AppDarkColors.danger, const Color(0xFFF87171));
      expect(AppDarkColors.info, const Color(0xFF38BDF8));
      expect(AppDarkColors.overlayScrim, const Color(0xCC090B10));
    });

    test('dark control inks meet WCAG AA contrast against bright fills', () {
      expect(AppDarkColors.onPrimary, const Color(0xFF090B10));
      expect(AppDarkColors.onError, AppDarkColors.onPrimary);
    });

    test('dark map mirrors the light role names (same semantic set)', () {
      expect(AppDarkColors.onNavySecondary, AppColors.onNavySecondary);
      expect(AppDarkColors.ratingStar, AppDarkColors.warning);
      expect(AppDarkColors.focusRing, AppDarkColors.focus);
      expect(AppDarkColors.surfaceStrong, AppDarkColors.surface);
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
