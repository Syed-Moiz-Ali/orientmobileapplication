import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 — scale-aware primitives.
///
/// Frozen Phase 00 decisions carried into this phase:
/// - `AppKpiCard` is at least 156 px tall at 1.0x and grows with the system
///   text scale (clamped 1.0–2.0x).
/// - `StatusPill` ellipsizes inside flex instead of overflowing.
/// - Shared primitives survive 1.6x text scale without overflow.
void main() {
  group('AppKpiCard scale awareness', () {
    testWidgets('compact tile is at least 156 px at 1.0x text scale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: AppKpiCard.compact(
                label: 'Gross Revenue',
                value: 'AED 42,500',
                supportingText: 'This month',
                icon: Icons.payments_rounded,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(AppKpiCard));
      expect(size.height, greaterThanOrEqualTo(156));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tile grows with text scale and never overflows', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.reset);

      for (final scale in <double>[1.0, 1.3, 1.6, 2.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(BrandConfig.orient),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            ),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.all(12),
                child: AppKpiCard(
                  label: 'Open Job Cards',
                  value: '24',
                  supportingText: '6 due today',
                  icon: Icons.assignment_rounded,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final size = tester.getSize(find.byType(AppKpiCard));
        expect(
          size.height,
          greaterThanOrEqualTo(AppDimensions.kpiTileMinHeight * scale - 1),
          reason: 'tile must grow at ${scale}x',
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('StatusPill inside flex', () {
    testWidgets('ellipsizes in a narrow column instead of overflowing', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: Center(
              // The pill must shrink inside a bounded narrow column (its real
              // usage: flex slots in dense rows and table columns).
              child: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    Flexible(
                      child: StatusPill.warning(
                        'Waiting for customer approval on additional repairs',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final pill = find.byType(StatusPill);
      expect(pill, findsOneWidget);
      expect(tester.getSize(pill).width, lessThanOrEqualTo(120));
      expect(tester.takeException(), isNull);
    });
  });

  group('shared primitives at 1.6x text scale', () {
    testWidgets('core primitives render clean at 1.6x on a narrow phone', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 720);
      addTearDown(tester.view.reset);

      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(BrandConfig.orient),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.6),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppInfoPanel.success(
                    title: 'Synced',
                    message: 'All queued work items have been sent.',
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  AppSearchField(
                    controller: controller,
                    hintText: 'Search jobs',
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  AppTextField(
                    controller: controller,
                    label: 'Internal note',
                    hint: 'Add context for the next shift',
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  PrimaryButton(label: 'Review approval', onPressed: () {}),
                  const SizedBox(height: AppDimensions.s12),
                  SecondaryButton(label: 'Open job card', onPressed: () {}),
                  const SizedBox(height: AppDimensions.s12),
                  const AppRecordRow(
                    title: 'MH 12 AB 4582',
                    subtitle: 'Brake inspection',
                    metadata: StatusPill.success('Completed'),
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  const AppKpiCard.compact(
                    label: 'Active Bays',
                    value: '8 / 10',
                    icon: Icons.build_circle_rounded,
                  ),
                  const SizedBox(height: AppDimensions.s12),
                  const EmptyState(
                    message: 'No jobs match this filter right now.',
                    title: 'Nothing here',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
