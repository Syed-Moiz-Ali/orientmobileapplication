import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  testWidgets('AppTheme.dark() provides the full component theme surface', (
    tester,
  ) async {
    const brand = BrandConfig.orient;
    final dark = AppTheme.dark(brand);
    final light = AppTheme.light(brand);

    expect(
      dark.textButtonTheme.style,
      isNotNull,
      reason: 'textButtonTheme missing',
    );
    expect(
      dark.floatingActionButtonTheme.backgroundColor,
      brand.buttonColor,
      reason: 'floatingActionButtonTheme missing or wrong',
    );
    expect(
      dark.bottomNavigationBarTheme.showUnselectedLabels,
      light.bottomNavigationBarTheme.showUnselectedLabels,
      reason: 'bottom nav label parity broken',
    );
    expect(dark.colorScheme.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, isNot(light.scaffoldBackgroundColor));
  });

  test('all app themes use the shared global font family', () {
    final brand = BrandConfig.orient;

    expect(
      AppTheme.light(brand).textTheme.bodyMedium?.fontFamily,
      AppFontFamilies.app,
    );
    expect(
      AppTheme.dark(brand).textTheme.bodyMedium?.fontFamily,
      AppFontFamilies.app,
    );
  });

  test('semantic dimensions keep controls, cards, and modals distinct', () {
    expect(AppDimensions.radiusControl, lessThan(AppDimensions.radiusCard));
    expect(AppDimensions.radiusCard, lessThan(AppDimensions.radiusPanel));
    expect(AppDimensions.radiusPanel, lessThan(AppDimensions.radiusDialog));
    expect(AppDimensions.radiusDialog, lessThan(AppDimensions.radiusSheet));
    expect(AppDimensions.touchTarget, greaterThanOrEqualTo(48));
  });

  test('layout spacing tokens provide structured grid hierarchy', () {
    expect(AppDimensions.screenGutterCompact, 16);
    expect(AppDimensions.screenGutterMedium, 24);
    expect(AppDimensions.screenGutterExpanded, 32);
    expect(AppDimensions.sectionGap, 24);
    expect(AppDimensions.cardGap, 16);
    expect(AppDimensions.shadowCard, isNotEmpty);
    expect(AppDimensions.shadowNavy, isNotEmpty);
  });

  test('motion tokens stay subtle and operational', () {
    expect(AppMotion.fast.inMilliseconds, inInclusiveRange(150, 200));
    expect(AppMotion.standard.inMilliseconds, inInclusiveRange(200, 250));
    expect(AppMotion.emphasized.inMilliseconds, inInclusiveRange(250, 300));
  });

  test('light theme uses restrained bordered surfaces and semantic tokens', () {
    final theme = AppTheme.light(BrandConfig.orient);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.colorScheme.surface, AppColors.surface);
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
    expect(theme.dialogTheme.surfaceTintColor, Colors.transparent);
    expect(theme.bottomSheetTheme.showDragHandle, isTrue);
    expect(theme.navigationBarTheme.elevation, 0);
  });

  test('AppColors preserves legacy aliases mapped to semantic tokens', () {
    expect(AppColors.bg, equals(AppColors.canvas));
    expect(AppColors.border, equals(AppColors.borderDefault));
    expect(AppColors.borderMd, equals(AppColors.borderStrong));
    expect(AppColors.text2, equals(AppColors.textSecondary));
    expect(AppColors.text3, equals(AppColors.textMuted));
    expect(AppColors.primaryBg, equals(AppColors.primarySubtle));
    expect(AppColors.darkNavy, equals(AppColors.navy));
    expect(AppColors.greenAccent, equals(AppColors.success));
    expect(AppColors.red500, equals(AppColors.danger));
    expect(AppColors.amber500, equals(AppColors.warning));
  });

  test('AppTextStyles provides disciplined typographic hierarchy', () {
    final display = AppTextStyles.displayLarge();
    final pageTitle = AppTextStyles.pageTitle();
    final sectionTitle = AppTextStyles.sectionTitle();
    final cardTitle = AppTextStyles.cardTitle();
    final body = AppTextStyles.body();
    final eyebrow = AppTextStyles.eyebrow();
    final metric = AppTextStyles.metric();

    expect(display.fontSize, greaterThan(pageTitle.fontSize!));
    expect(pageTitle.fontSize, greaterThan(sectionTitle.fontSize!));
    expect(sectionTitle.fontSize, greaterThan(cardTitle.fontSize!));
    expect(cardTitle.fontSize, greaterThanOrEqualTo(body.fontSize!));
    expect(eyebrow.letterSpacing, 0.8);
    expect(metric.fontFeatures, isNotEmpty);
  });

  testWidgets(
    'AppIconContainer renders semantic variants with optical sizing',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppIconContainer.primary(icon: Icons.speed_rounded),
                AppIconContainer.success(icon: Icons.check_circle_rounded),
                AppIconContainer.warning(icon: Icons.warning_rounded),
                AppIconContainer.danger(icon: Icons.error_rounded),
                AppIconContainer.navy(icon: Icons.shield_rounded),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppIconContainer), findsNWidgets(5));
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    },
  );

  testWidgets(
    'AppDarkPanel propagates high-contrast inverse theme to children',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppDarkPanel(
              child: Column(
                children: [
                  Text('Active Workshop Bay'),
                  Text('Bay 04 - Brake Service'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppDarkPanel), findsOneWidget);
      expect(find.text('Active Workshop Bay'), findsOneWidget);

      final panelContext = tester.element(find.text('Active Workshop Bay'));
      final inheritedTheme = Theme.of(panelContext);
      expect(inheritedTheme.brightness, equals(Brightness.dark));
    },
  );
}
