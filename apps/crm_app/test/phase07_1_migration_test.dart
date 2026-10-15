import 'dart:io';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 07.1 migration tests — crm_app.
///
/// Proves the bespoke bar/banner/KPI tile are gone (source scan) and the
/// rewired dashboard page renders EN/AR at 320/768/1280 with no overflow.
void main() {
  group('Phase 07.1 source scan (no deleted primitives remain)', () {
    test('deleted bar, banner and tile have zero references', () {
      const deleted = [
        'CrmAppBar',
        'CrmHeaderBanner',
        'CrmKpiCard',
      ];
      final offenders = <String>[];
      final dir = Directory('lib');
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = _stripComments(entity.readAsStringSync());
        for (final name in deleted) {
          if (RegExp('\\b$name\\b').hasMatch(source)) {
            offenders.add('${entity.path} :: $name');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Deleted Phase 07.1 duplicates still referenced:\n'
            '${offenders.join('\n')}',
      );
    });
  });

  group('CrmDashboardPage centralized header + tiles', () {
    for (final width in [320.0, 768.0, 1280.0]) {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        testWidgets(
            'dashboard page renders ${width.toInt()}px (${locale.languageCode})',
            (tester) async {
          await _pumpPage(tester, locale: locale, width: width);
          // Centralized pulse header (was CrmHeaderBanner/GradientBanner).
          expect(find.byType(AppPageHeader), findsOneWidget);
          expect(find.text('CRM Dashboard'), findsOneWidget);
          expect(find.byType(StatusPill), findsNWidgets(2));
          // Centralized KPI tiles (was CrmKpiCard).
          expect(find.byType(AppKpiCard), findsNWidgets(2));
          expect(find.text('128'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

String _stripComments(String source) {
  final withoutBlocks = source.replaceAll(
    RegExp(r'/\*.*?\*/', dotAll: true),
    '',
  );
  return withoutBlocks
      .split('\n')
      .map((line) {
        final index = line.indexOf('//');
        return index < 0 ? line : line.substring(0, index);
      })
      .join('\n');
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required Locale locale,
  required double width,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crmUiProvider.overrideWith(_FakeCrmUiNotifier.new),
        crmLeadProvider.overrideWith(_FakeLeadNotifier.new),
        leadAnalyticsProvider.overrideWith(_FakeAnalyticsNotifier.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: const [
          SharedCoreLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(BrandConfig.orient, locale: locale),
        home: const Scaffold(body: CrmDashboardPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeCrmUiNotifier extends CrmUiNotifier {
  @override
  CrmUiState build() => const CrmUiState(
        selectedIndex: 0,
        period: 'Today',
        salesperson: 'All Salespeople',
        isLoading: false,
        searchQuery: '',
        notificationsEnabled: true,
        darkMode: true,
        autoAssign: true,
      );

  @override
  Future<void> refresh() async {}

  @override
  List<CrmKpiEntity> get kpis => const [
        CrmKpiEntity(
          label: 'New Leads',
          value: '128',
          icon: Icons.person_add_alt_rounded,
          state: KpiSemanticState.info,
          trend: '12%',
          trendUp: true,
        ),
        CrmKpiEntity(
          label: 'Won',
          value: '42',
          icon: Icons.check_circle_outline_rounded,
          state: KpiSemanticState.success,
          trend: '8%',
          trendUp: true,
        ),
      ];

  @override
  List<CrmChannelEntity> get channels => const [];

  @override
  List<IntegrationEntity> get integrations => const [];
}

class _FakeLeadNotifier extends CrmLeadNotifier {
  @override
  List<CrmLeadEntity> build() => const [];
}

class _FakeAnalyticsNotifier extends LeadAnalyticsNotifier {
  @override
  LeadAnalyticsState build() => const LeadAnalyticsState();
}
