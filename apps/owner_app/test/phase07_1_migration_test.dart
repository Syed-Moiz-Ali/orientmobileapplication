import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_grid.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/pages/job_cards_list_view.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 07.1 migration tests — owner_app.
///
/// Proves the bespoke bars/tiles/filters/skeletons are gone (source scan)
//  and the rewired surfaces render EN/AR at 320/768/1280 with no overflow.
void main() {
  group('Phase 07.1 source scan (no deleted primitives remain)', () {
    test('deleted bars, tiles, filters and skeletons have zero references',
        () {
      const deleted = [
        'OwnerAppBar',
        'HeaderBanner',
        'FilterChipBar',
        '_FilterStrip',
        '_FilterChip',
        '_SummaryPill',
        'OwnerDashboardSkeleton',
        'KpiGridSkeleton',
        'ShimmerBox',
      ];
      // `KpiCard(` with a leading boundary so the shared `AppKpiCard(`
      // compositions never match.
      final cardPattern = RegExp(r'(?<![A-Za-z0-9_])KpiCard\(');
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
        if (cardPattern.hasMatch(source)) {
          offenders.add('${entity.path} :: KpiCard(');
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

  group('KpiGrid centralized tiles', () {
    const kpis = [
      OwnerKpi(
        label: 'Active jobs',
        value: '24',
        icon: Icons.build_circle_outlined,
        state: KpiSemanticState.info,
        sub: '6 due today',
      ),
      OwnerKpi(
        label: 'Revenue',
        value: 'AED 84K',
        icon: Icons.payments_outlined,
        state: KpiSemanticState.success,
        sub: 'This month',
      ),
    ];

    for (final width in [320.0, 768.0, 1280.0]) {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        testWidgets('KpiGrid renders ${width.toInt()}px (${locale.languageCode})',
            (tester) async {
          tester.view.physicalSize = Size(width, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              supportedLocales: AppLocales.supported,
              localizationsDelegates: const [
                SharedCoreLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light(BrandConfig.orient, locale: locale),
              home: const Scaffold(
                body: SingleChildScrollView(child: KpiGrid(kpis: kpis)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(AppKpiCard), findsNWidgets(kpis.length));
          expect(find.byType(KpiGrid), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('JobCardsListView centralized filter', () {
    Future<void> pumpList(
      WidgetTester tester, {
      Locale locale = const Locale('en'),
      double width = 390,
    }) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            jobCardsProvider.overrideWith(_FakeJobCardsNotifier.new),
          ],
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppLocales.supported,
            localizationsDelegates: const [
              OwnerLocalizations.delegate,
              SharedCoreLocalizations.delegate,
              SharedAuthLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(BrandConfig.orient, locale: locale),
            home: const Scaffold(body: JobCardsListView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('filter bar selects + filters rows (EN)', (tester) async {
      await pumpList(tester);
      expect(find.byType(AppFilterBar), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Sara'), findsOneWidget);
      // Phase 14 recomposition: the lifecycle chip for the in-progress
      // status reads "WIP" — tap the filter chip, not a table row.
      final chip = find.descendant(
        of: find.byType(AppFilterBar),
        matching: find.text('WIP'),
      );
      expect(chip, findsOneWidget);
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('Sara'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('list renders AR at 320px without overflow', (tester) async {
      await pumpList(tester, locale: const Locale('ar'), width: 320);
      expect(find.byType(AppFilterBar), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('list renders 1280px without overflow', (tester) async {
      await pumpList(tester, width: 1280);
      expect(tester.takeException(), isNull);
    });
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

class _FakeJobCardsNotifier extends JobCardsNotifier {
  @override
  JobCardsState build() {
    return const JobCardsState(
      isLoading: false,
      all: _cards,
      filtered: _cards,
    );
  }
}

const _cards = [
  JobCard(
    id: 'JC-1',
    customerName: 'Ahmed',
    vehicle: 'Camry',
    plateNumber: 'A 12345',
    services: ['Oil'],
    technician: 'Sam',
    estCompletion: 'Today',
    amount: 250,
    status: JobCardStatus.inProgress,
  ),
  JobCard(
    id: 'JC-2',
    customerName: 'Sara',
    vehicle: 'Patrol',
    plateNumber: 'B 67890',
    services: ['Brakes'],
    technician: 'Alex',
    estCompletion: 'Tomorrow',
    amount: 480,
    status: JobCardStatus.waitingParts,
  ),
];
