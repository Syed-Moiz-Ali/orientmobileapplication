import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/owner_dashboard_page.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 01 (H3) — real-context layout smoke test.
///
/// The real Owner Dashboard composition (header banner, KPI grid, job-card
/// register, analytics split view, quick actions) must build with fake
/// providers at default and 1.3x text scale, on phone / tablet / desktop
/// widths, with no exceptions or RenderFlex overflow after the global
/// text-scale lock removal.
void main() {
  for (final scale in <double>[1.0, 1.3]) {
    testWidgets('OwnerDashboardPage lays out at ${scale}x on phone', (
      tester,
    ) async {
      await _pumpDashboard(
        tester,
        size: const Size(390, 844),
        scale: scale,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Executive Operations Control'), findsOneWidget);
      expect(find.text('KPI Overview'), findsOneWidget);

      final context = tester.element(find.byType(OwnerDashboardPage));
      expect(
        Theme.of(context).textTheme.bodyMedium?.fontFamily,
        AppFontFamilies.app,
      );
    });
  }

  for (final size in <Size>[
    const Size(800, 1024),
    const Size(1280, 800),
  ]) {
    testWidgets(
      'OwnerDashboardPage lays out at ${size.width} px, 1.3x',
      (tester) async {
        await _pumpDashboard(tester, size: size, scale: 1.3);

        expect(tester.takeException(), isNull);
        expect(find.text('Executive Operations Control'), findsOneWidget);
      },
    );
  }

  testWidgets('OwnerDashboardPage survives 320 px at 1.3x', (tester) async {
    await _pumpDashboard(
      tester,
      size: const Size(320, 640),
      scale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Size size,
  required double scale,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardUiProvider.overrideWith(_FakeDashboardUiNotifier.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(BrandConfig.orient),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(body: OwnerDashboardPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeDashboardUiNotifier extends DashboardUiNotifier {
  @override
  DashboardUiState build() => const DashboardUiState();

  @override
  Future<void> refresh() async {}

  @override
  List<OwnerKpi> get kpis => const [
    OwnerKpi(
      label: 'Active jobs',
      value: '24',
      icon: Icons.build_circle_outlined,
      color: Color(0xFF167C80),
      sub: '6 due today',
    ),
    OwnerKpi(
      label: 'Revenue',
      value: 'AED 84K',
      icon: Icons.payments_outlined,
      color: Color(0xFF1A8754),
      sub: 'This month',
    ),
    OwnerKpi(
      label: 'Receivables',
      value: 'AED 19K',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFB7791F),
      sub: '8 outstanding',
    ),
    OwnerKpi(
      label: 'Approvals',
      value: '7',
      icon: Icons.fact_check_outlined,
      color: Color(0xFF6746B8),
      sub: 'Needs attention',
    ),
  ];

  @override
  List<JobCardRegisterItem> get registerItems => const [
    JobCardRegisterItem(
      label: 'In progress',
      open: 12,
      completed: 4,
      total: 28,
    ),
    JobCardRegisterItem(
      label: 'Awaiting approval',
      open: 7,
      completed: 0,
      total: 9,
    ),
  ];

  @override
  List<SalesTrendPoint> get salesTrend => const [
    SalesTrendPoint('Jan', 42),
    SalesTrendPoint('Feb', 56),
    SalesTrendPoint('Mar', 61),
  ];

  @override
  List<SalesTrendPoint> get profitTrend => const [
    SalesTrendPoint('Jan', 18),
    SalesTrendPoint('Feb', 24),
    SalesTrendPoint('Mar', 27),
  ];

  @override
  List<SalesTrendPoint> get expensesTrend => const [
    SalesTrendPoint('Jan', 22),
    SalesTrendPoint('Feb', 26),
    SalesTrendPoint('Mar', 30),
  ];
}
