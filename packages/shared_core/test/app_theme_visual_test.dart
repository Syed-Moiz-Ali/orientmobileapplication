import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';
import 'support/theme_font_loader.dart';

void main() {
  setUpAll(() async {
    await loadThemeFonts();
  });

  group('Concept A Theme Foundation Visual Reference', () {
    testWidgets('theme foundation mobile English (Light)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient, locale: const Locale('en')),
          home: const _ConceptAShowcase(arabic: false, isDark: false),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/theme_foundation_mobile_en.png'),
      );
    });

    testWidgets('theme foundation mobile Arabic RTL (Light)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient, locale: const Locale('ar')),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: _ConceptAShowcase(arabic: true, isDark: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/theme_foundation_mobile_ar.png'),
      );
    });

    testWidgets('theme foundation mobile English (Dark)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(BrandConfig.orient, locale: const Locale('en')),
          home: const _ConceptAShowcase(arabic: false, isDark: true),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/theme_foundation_mobile_dark.png'),
      );
    });

    testWidgets('theme foundation tablet English (Light)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(834, 1194);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient, locale: const Locale('en')),
          home: const _ConceptAShowcase(arabic: false, isDark: false, isTablet: true),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/theme_foundation_tablet_en.png'),
      );
    });

    testWidgets('theme foundation desktop English (Light)', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(BrandConfig.orient, locale: const Locale('en')),
          home: const _ConceptAShowcase(arabic: false, isDark: false, isDesktop: true),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/theme_foundation_desktop_en.png'),
      );
    });
  });
}

class _ConceptAShowcase extends StatelessWidget {
  final bool arabic;
  final bool isDark;
  final bool isTablet;
  final bool isDesktop;

  const _ConceptAShowcase({
    required this.arabic,
    required this.isDark,
    this.isTablet = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
              child: Text(
                arabic ? 'أورينت' : 'ORIENT',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                arabic ? 'النموذج أ — نظام التصميم' : 'Concept A — Design System',
                style: AppTextStyles.heading2(
                  color: colors.onSurface,
                  arabic: arabic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppDarkColors.primarySubtle : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  border: Border.all(
                    color: isDark ? AppDarkColors.primaryBorder : AppColors.primaryBorder,
                  ),
                ),
                child: Text(
                  isDark ? 'DARK OBSIDIAN' : 'LIGHT MINIMAL',
                  style: AppTextStyles.telemetry(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.s20),
        children: [
          // 1. Header & Typography Hierarchy
          Text(
            arabic ? 'الهوية البصرية المميزة للمركبات' : 'Premium Minimal Automotive Identity',
            style: AppTextStyles.displayHero(
              color: colors.onSurface,
              arabic: arabic,
            ),
          ),
          const SizedBox(height: AppDimensions.s6),
          Text(
            arabic
                ? 'أنظمة تشغيل ورش الصيانة الاحترافية — واجهات عالية الدقة والتباين'
                : 'Telemetry-driven operational ERP with disciplined surfaces and WCAG AA contrast.',
            style: AppTextStyles.bodyLarge(
              color: colors.onSurfaceVariant,
              arabic: arabic,
            ),
          ),
          const SizedBox(height: AppDimensions.s24),

          // 2. Color Tokens Swatches
          Text(
            arabic ? 'لوحة الألوان المعتمدة' : 'Approved Concept A Color Tokens',
            style: AppTextStyles.heading3(
              color: colors.onSurface,
              arabic: arabic,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Wrap(
            spacing: AppDimensions.s8,
            runSpacing: AppDimensions.s8,
            children: [
              _TokenSwatch(
                label: 'Hyper Cobalt',
                hex: '#2563EB',
                color: colors.primary,
                textColor: Colors.white,
              ),
              _TokenSwatch(
                label: 'Precision Emerald',
                hex: '#10B981',
                color: isDark ? AppDarkColors.success : AppColors.success,
                textColor: Colors.white,
              ),
              _TokenSwatch(
                label: 'Electric Amber',
                hex: '#F59E0B',
                color: isDark ? AppDarkColors.warning : AppColors.warning,
                textColor: Colors.white,
              ),
              _TokenSwatch(
                label: 'Brembo Crimson',
                hex: '#EF4444',
                color: isDark ? AppDarkColors.danger : AppColors.danger,
                textColor: Colors.white,
              ),
              _TokenSwatch(
                label: 'Ice Blue',
                hex: '#0284C7',
                color: isDark ? AppDarkColors.info : AppColors.info,
                textColor: Colors.white,
              ),
              _TokenSwatch(
                label: 'Deep Navy',
                hex: '#0F172A',
                color: isDark ? AppDarkColors.surfaceStrong : AppColors.surfaceStrong,
                textColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s24),

          // 3. Surface & Card Geometry
          Text(
            arabic ? 'هندسة البطاقات والأسطح' : 'Surface Geometry & Chamfers',
            style: AppTextStyles.heading3(
              color: colors.onSurface,
              arabic: arabic,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppDarkColors.surfaceSubtle : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Text(
                          'DXB · A 92481',
                          style: AppTextStyles.mono(color: colors.onSurface),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppDarkColors.successSubtle : AppColors.successSubtle,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: isDark ? AppDarkColors.success : AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              arabic ? 'تم الفحص' : 'INSPECTED',
                              style: AppTextStyles.telemetry(
                                color: isDark ? AppDarkColors.success : AppColors.success,
                                arabic: arabic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  Text(
                    'Porsche 911 Carrera S (992)',
                    style: AppTextStyles.heading2(
                      color: colors.onSurface,
                      arabic: arabic,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    arabic
                        ? 'فحص نظام الفرامل · طلب تبديل وسادات الفرامل معتمدة'
                        : 'Brembo Carbon Ceramic Brake Service · Bay 04',
                    style: AppTextStyles.body(
                      color: colors.onSurfaceVariant,
                      arabic: arabic,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.s16),
                  Divider(color: colors.outline),
                  const SizedBox(height: AppDimensions.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        arabic ? 'قيمة التقدير:' : 'Estimate Total:',
                        style: AppTextStyles.bodySmall(
                          color: colors.onSurfaceVariant,
                          arabic: arabic,
                        ),
                      ),
                      Text(
                        'AED 4,850.00',
                        style: AppTextStyles.displayHero(
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.s20),

          // 4. Form Inputs & Control Primitives
          Text(
            arabic ? 'عناصر الإدخال والأزرار التفاعلية' : 'Input Primitives & Action Buttons',
            style: AppTextStyles.heading3(
              color: colors.onSurface,
              arabic: arabic,
            ),
          ),
          const SizedBox(height: AppDimensions.s12),
          TextField(
            decoration: InputDecoration(
              labelText: arabic ? 'البحث عن مركبة أو بطاقة عمل' : 'Search vehicle VIN, plate or customer',
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded),
                  label: Text(arabic ? 'إنشاء بطاقة عمل' : 'Create Job Card'),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(arabic ? 'عرض سجل الورشة' : 'View Bay Schedule'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TokenSwatch extends StatelessWidget {
  final String label;
  final String hex;
  final Color color;
  final Color textColor;

  const _TokenSwatch({
    required this.label,
    required this.hex,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(AppDimensions.s8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            hex,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontFamily: AppFontFamilies.mono,
            ),
          ),
        ],
      ),
    );
  }
}
