import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_scaffold.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/widgets/technician_components.dart';

/// Phase 07.1 migration tests — staff_app.
///
/// Proves the bespoke bars/primitives are gone (source scan) and the rewired
/// surfaces render EN/AR at 320/768/1280 with no overflow.
void main() {
  group('Phase 07.1 source scan (no deleted primitives remain)', () {
    test('deleted bars, tiles and helpers have zero references', () {
      const deleted = [
        'SupervisorAppBar',
        'TechnicianAppBar',
        'SupervisorStatCard',
        'TechnicianSectionHeader',
        'TechnicianStatusPill',
        'TechnicianTaskProgress',
        'TechnicianEmptyState',
        'JobFilterChip',
        'ReportStatCard',
        'JobsMetricPill',
        'AttentionChip',
        'AdvisorMetaPill',
        'SupervisorQueueSkeleton',
        'StaffAttendanceSkeleton',
        'AdvisorDashboardSkeleton',
        'TechnicianHUDSkeleton',
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

    test('no bespoke SearchField class definition remains', () {
      final offenders = <String>[];
      final pattern = RegExp(r'class\s+SearchField\s+extends');
      final dir = Directory('lib');
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (pattern.hasMatch(_stripComments(entity.readAsStringSync()))) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty);
    });
  });

  group('technicianStatusPill mapping', () {
    test('every TechJobStatus maps to a shared StatusPill', () {
      expect(
        technicianStatusPill(TechJobStatus.inProgress),
        isA<StatusPill>(),
      );
      for (final status in TechJobStatus.values) {
        expect(
          technicianStatusPill(status),
          isA<StatusPill>(),
          reason: '$status has no shared-pill mapping',
        );
      }
    });

    testWidgets('mapped pills render with uppercase labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: Scaffold(
            body: Column(
              children: [
                for (final status in TechJobStatus.values)
                  technicianStatusPill(status),
              ],
            ),
          ),
        ),
      );
      expect(find.text('IN PROGRESS'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('QC REVIEW'), findsOneWidget);
      expect(find.text('DELAYED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SupervisorScaffold centralized chrome (Phase 11 greeting shell)', () {
    for (final width in [320.0, 768.0, 1280.0]) {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        final tag = locale.languageCode;
        testWidgets('scaffold renders ${width.toInt()}px ($tag)', (
          tester,
        ) async {
          await _pumpScaffold(tester, locale: locale, width: width);
          // Phase 11 migrated the bespoke bar to a greeting header (advisor
          // home grammar) — no WorkspaceAppBar on the supervisor shell.
          expect(find.byType(SupervisorScaffold), findsOneWidget);
          expect(find.byType(WorkspaceAppBar), findsNothing);
          if (locale.languageCode == 'en') {
            expect(find.textContaining('Floor command'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('scaffold survives 320px at 1.3x text scale', (tester) async {
      await _pumpScaffold(
        tester,
        locale: const Locale('en'),
        width: 320,
        textScale: 1.3,
      );
      expect(find.byType(SupervisorScaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('jobs filter bar renders counts (AR, 320px)', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            SharedCoreLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(
            BrandConfig.orient,
            locale: const Locale('ar'),
          ),
          home: Scaffold(
            body: AppFilterBar(
              options: const ['Pending', 'In Progress'],
              selected: null,
              counts: const {'الكل': 4, 'Pending': 1, 'In Progress': 3},
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
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

Future<void> _pumpScaffold(
  WidgetTester tester, {
  required Locale locale,
  required double width,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supervisorDashboardProvider.overrideWith(
          _MockSupervisorDashboardNotifier.new,
        ),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: const [
            StaffLocalizations.delegate,
            SharedCoreLocalizations.delegate,
            SharedAuthLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(BrandConfig.orient, locale: locale),
          home: const Scaffold(body: SupervisorScaffold()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _MockSupervisorDashboardNotifier extends SupervisorDashboardNotifier {
  @override
  SupervisorDashboardState build() {
    return SupervisorDashboardState(
      isDashboardLoading: false,
      isQueueLoading: false,
      isReviewLoading: false,
      selectedIndex: 0,
      assignmentRows: const [],
    );
  }
}
